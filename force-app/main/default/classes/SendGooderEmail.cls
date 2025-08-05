public with sharing class SendGooderEmail {
    
    private static final String ERRORS_KEY = 'errors';
    private static final String ASYNCS_KEY = 'asyncs';
    private static final String SENDS_KEY = 'sends';

    private static final String TO_RECIPIENT_TYPE = 'TO';
    private static final String CC_RECIPIENT_TYPE = 'CC';
    private static final String BCC_RECIPIENT_TYPE = 'BCC';

    private static final String TEMPLATE_MISSING_ERR = 'An Email template with the specified template name could not be found';
    private static final String TEMPLATE_OR_BODY_ERR = 'You\'re trying to pass in both a plaintext/html body and a template ID. Gotta pick one or the other. Make sure you\'re not confusing the Text Template resources in Flow, (which you can pass into either the HTMLBody or the plainTextBody) with the templateID, which represents a Salesforce Email Template (either Classic or Lightning).';
    private static final String HAS_BODY_ERR = 'Body text must be provided to Send Gooder Email Action, either via HTMLbody, plainTextBody, or a templateID';
    private static final String WHATID_ERR =  'In order to log this email send as a task, you need to pass in a recordId';

    @testVisible
    private List<Queueable> asyncJobs;
	
    @testVisible
    private Emails emails;
    
    @testVisible
    private Map<Id, EmailTemplate> emailTemplatesById;
    
    private Boolean isAsync;

    private static final Set<String> TO_RECIPIENTS_KEYS = new Set<String>{
        'SendTOthisOneEmailAddress',
        'SendTOthisStringCollectionOfEmailAddresses'
    };

    private static final Set<String> CC_RECIPIENT_KEYS= new Set<String>{
        'SendCCthisOneEmailAddress',
        'SendCCthisStringCollectionOfEmailAddresses'
    };

    private static final Set<String> BCC_RECIPIENT_KEYS = new Set<String>{
        'SendBCCthisOneEmailAddress',
        'SendBCCthisStringCollectionOfEmailAddresses'
    };

   
    public SendGooderEmail() {
        this.asyncJobs = new List<Queueable>();
        this.emails = new Emails();
    }

    
    public List<SendGooderEmailResponse> sendEmail(List<SendGooderEmailRequest> requests){
        this.isAsync = System.isQueueable();
      	mapEmailTemplates(requests);
        
        List<SendGooderEmailResponse> responses = new List<SendGooderEmailResponse>();
        Map<String, List<SendGooderEmailResponse>> responseMap = getEmailResponses(requests);
        responses.addAll(responseMap.get(ERRORS_KEY));
        responses.addAll(responsemap.get(ASYNCS_KEY));
        responses.addAll(responseMap.get(SENDS_KEY));
      
        if(responseMap.get(ASYNCS_KEY).size() > 0){
            addAsyncJob(new SendGooderEmailAsync(getRequestsFromResponses(responseMap.get(ASYNCS_KEY))));
            enqueueAsyncJobs();
        }
        //TODO: handle tasks
        	//create tasks based on sends

        return responses;
    }

    @testVisible
    private Map<String, List<SendGooderEmailResponse>> getEmailResponses(List<SendGooderEmailRequest> requests){
        Map<String, List<SendGooderEmailResponse>> responseMap = new Map<String, List<SendGooderEmailResponse>>{
            ERRORS_KEY => new List<SendGooderEmailResponse>(),
            ASYNCS_KEY => new List<SendGooderEmailResponse>(),
            SENDS_KEY => new List<SendGooderEmailResponse>()
        };

        List<SendGooderEmailRequest> sendRequests = new List<SendGooderEmailRequest>();

        for(SendGooderEmailRequest request : requests){
            SendGooderEmailResponse response = getErrorResponse(request);
            if(response != null){
                responseMap.get(ERRORS_KEY).add(response);
                continue;
            }
            
            response = getAsyncResponse(request);
            if(response != null){
                responseMap.get(ASYNCS_KEY).add(response);
                continue;
            }

            if(response == null){
                sendRequests.add(request);
            }
            
        }

        if(sendRequests.size() > 0){
            responseMap.get(SENDS_KEY).addAll(getSendResponses(sendRequests));
        }

        return responseMap;
    }

    private List<SendGooderEmailRequest> getRequestsFromResponses(List<SendGooderEmailResponse> responses){
        List<SendGooderEmailRequest> requests = new List<SendGooderEmailRequest>();

        for(SendGooderEmailResponse response: responses){
            requests.add(response.request);
        }

        return requests;
    }

    private void addAsyncJob(Queueable job){
        this.asyncJobs.add(job);
    }
    
    @testVisible
    private void enqueueAsyncJobs(){
        for(Queueable job : this.asyncJobs){
            Id jobId =  this.isAsync == false 
            && this.asyncJobs.size() > 0 
            && Test.isRunningTest() ?  null : System.enqueueJob(job);
        }
    }

    @testVisible
    private List<SendGooderEmailResponse> getSendResponses(List<SendGooderEmailRequest> requests){
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        List<Messaging.SingleEmailMessage> emails = makeEmailList(requests);
        List<SendGooderEmailResponse> responses = makeSendResponseList(requests);

        try {
            results = Messaging.sendEmail(emails, false);
        } catch(Exception ex){
            for(SendGooderEmailResponse response : responses){
                response.isSuccess = false;
                response.errors = ex.getMessage() + '\n';
            }
        }

        responses = processSendResults(responses, results);
        // responses = saveTasks(responses);

        return responses;
    }

    @testVisible
    private List<SendGooderEmailResponse> processSendResults(List<SendGooderEmailResponse> responses, List<Messaging.SendEmailResult> results){
        for(Integer i = 0; i< results.size();i++){
            Messaging.SendEmailResult result = results[i];
            SendGooderEmailResponse response = responses[i];
                if(isGoodResult(result)){
                    response.isSuccess = true;
                } else {
                    response.isSuccess = false;
                    response.errors = getErrors(result.getErrors());
                }
        }

        return responses;
    }

    @testVisible
    private Boolean isGoodResult(Messaging.SendEmailResult result){
        return result.isSuccess();
    }   
    

    @testVisible
    private List<SendGooderEmailResponse> makeSendResponseList(List<SendGooderEmailRequest> requests){
        List<SendGooderEmailResponse> responses = new List<SendGooderEmailResponse>();
        for(SendGooderEmailRequest request : requests){
            responses.add(new SendGooderEmailResponse(request));
        }

        return responses;
    }

    @testVisible
    private List<Messaging.SingleEmailMessage> makeEmailList(List<SendGooderEmailRequest> requests){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for(SendGooderEmailRequest request : requests){
            emails.add(makeEmail(request));
        }

        return emails;
    }

    @testVisible
    private SendGooderEmailResponse getErrorResponse(SendGooderEmailRequest request){
        SendGooderEmailResponse errorResponse = new SendGooderEmailResponse();
        errorResponse.errors = '';
		
        if(!templateExists(request)){
            errorResponse.errors += TEMPLATE_MISSING_ERR+' \n';
        }
        if(hasBothTemplateOrBody(request)){
            errorResponse.errors += TEMPLATE_OR_BODY_ERR+' \n';
        }
        if(missingBody(request)){
            errorResponse.errors += HAS_BODY_ERR+' \n';
        }  
      
        if(errorResponse.errors.length() > 1){
            errorResponse.isSuccess = false;
            return errorResponse;
        }

        return null;
    }

    @testVisible
    private SendGooderEmailResponse getAsyncResponse(SendGooderEmailRequest request){
        if(this.isAsync == false && request.sendAsync == true){
            SendGooderEmailResponse asyncResponse = new SendGooderEmailResponse(request);
        
            asyncResponse.isSuccess = true;
            asyncResponse.message = 'enqueued for sending';

            return asyncResponse;
        }

        return null;
    }


    @testVisible
    private SendGooderEmailResponse getSendResponse(SendGooderEmailRequest request){
        SendGooderEmailResponse sendResponse;

        return null;
    }

	@testVisible
    private void mapEmailTemplates(List<SendGooderEmailRequest> requests){
        Map<Id, EmailTemplate> emailTemplatesById = new Map<Id, EmailTemplate>();
        Set<String> emailTemplateIds = new Set<String>();
        
        for(SendGooderEmailRequest request : requests){
            if(request.templateId != null && String.isNotBlank(request.templateId)){
                emailTemplateIds.add(request.templateId);
            }    
        }
        
        if(emailTemplateIds.size() > 0){
            emailTemplatesById = this.emails.getEmailTemplatesById(emailTemplateIds);
        }
        
        this.emailTemplatesById = emailTemplatesById;
    }


    @testVisible
    private Boolean templateExists(SendGooderEmailRequest request){
        if(String.isNotEmpty(request.templateId) && ! emailTemplatesById.containsKey(request.templateId)){
            return false;
        } 
        
        return true;
    }

    @testVisible
    private  Boolean hasBothTemplateOrBody (SendGooderEmailRequest request){
        return  ((request.templateID != null && request.templateId.length() > 0) &&
        ((request.htmlBody != null) || (request.plainTextBody != null)));
    }

    @testVisible
    private Boolean missingBody(SendGooderEmailRequest request){
        return (request.templateID == null && request.htmlBody == null && request.plainTextBody == null);
    }

    @testVisible
    private Messaging.SingleEmailMessage makeEmail(SendGooderEmailRequest request){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email = setSender(email, request);
        email = setRecipients(email, request);
        email = addAttachments(email, request);
        email = setBody(email, request);
        email = setTargets(email, request);
        email.setReplyTo(request.replyTo);
        email.setSubject(request.subject); //not specified?
        email.setBccSender(request.bcc);

       
        return email;
    }

    @testVisible
    private Messaging.SingleEmailMessage setSender(Messaging.SingleEmailMessage email, SendGooderEmailRequest request){
        if (request.OrgWideEmailId != null && request.OrgWideEmailId.length() > 0) {
            email.setOrgWideEmailAddressId(request.OrgWideEmailId);
        } else {
            email.setSenderDisplayName(request.senderDisplayName);
        }  

        return email;
    }

    @testVisible
    private Messaging.SingleEmailMessage setTargets(Messaging.SingleEmailMessage email, SendGooderEmailRequest request){
        if(request.templateTargetObjectId != null && request.templateTargetObjectId.length() > 0){
            email.setTargetObjectId(request.templateTargetObjectId);
            if(request.templateTargetObjectIsRecipient == true){
                email.setTreatTargetObjectAsRecipient(request.templateTargetObjectIsRecipient);
            }
        }
        if(request.recordId != null && request.recordId.length() > 0 ){
            email.setWhatId(Id.valueOf(request.recordId));
        }

        return email;
    }

    @testVisible
    private Messaging.SingleEmailMessage setRecipients(Messaging.SingleEmailMessage email, SendGooderEmailRequest request){
        Map<String, Object> recipientsMap = mapRecipients(request);
        
        email.setToAddresses(buildAddressList(TO_RECIPIENT_TYPE, recipientsMap));
        email.setCcAddresses(buildAddressList(CC_RECIPIENT_TYPE, recipientsMap));
        email.setBccAddresses(buildAddressList(BCC_RECIPIENT_TYPE, recipientsMap));

        return email;
    }

    @testVisible
    private Messaging.SingleEmailMessage setBody(Messaging.SingleEmailMessage email, SendGooderEmailRequest request){
        if (request.templateId != null){
            email.setTemplateId(request.templateId);
        }
        if (request.plainTextBody != null) {
            email.setPlainTextBody(request.plainTextBody);
        }

        if (request.htmlBody != null) {
            email.setHtmlBody(request.htmlBody);
        }

        return email;
    }

    @testVisible 
    private Map<String, Object> mapRecipients(SendGooderEmailRequest request){
        return new Map<String, Object>{
            'SendTOthisOneEmailAddress' => request.SendTOthisOneEmailAddress,
            'SendTOthisStringCollectionOfEmailAddresses' => request.sendToCollectionOfEmailAddresses,
            'SendCCthisOneEmailAddress' => request.sendCCToJustOneEmailAddress,
            'SendCCthisStringCollectionOfEmailAddresses' => request.sendCCToCollectionOfEmailAddresses,
            'SendBCCthisOneEmailAddress' => request.sendBccToThisOneEmailAddress,
            'SendBCCthisStringCollectionOfEmailAddresses' => request.sendBccToThisCollectionOfEmailAddresses
          };
    }

    @testVisible
    private List<String> buildAddressList(String recipientType, Map<String, Object> recipientsMap){
        List<String> addresses = new List<String>();

        if(recipientType == TO_RECIPIENT_TYPE){
            addresses = getAddresses(TO_RECIPIENTS_KEYS, recipientsMap);
        }
        if(recipientType == CC_RECIPIENT_TYPE){
            addresses = getAddresses(CC_RECIPIENT_KEYS, recipientsMap);
        }
        if(recipientType == BCC_RECIPIENT_TYPE){
            addresses = getAddresses(BCC_RECIPIENT_KEYS, recipientsMap);
        }

        return addresses;
    }

    private List<String> getAddresses(Set<String> recipientKeys, Map<String, Object> recipientsMap){
        List<String> addresses = new List<String>();

        for(String recipientKey : recipientKeys){
            if(recipientsMap.containsKey(recipientKey)){
                Object recipient_or_recipients = recipientsMap.get(recipientKey);
                
                if(isCollection(recipient_or_recipients)){
                    List<String> addressList = getListFromObject(recipient_or_recipients);
                    if(addressList != null && addressList.size() > 0){
                        addresses.addAll(addressList);
                    }
                } else {
                    String address = (String)JSON.deserialize(JSON.serialize(recipient_or_recipients), String.class);
                    if(address != null){
                        addresses.add(address);
                    }
                }
            }
        }

        return addresses;
    }

    @testVisible
    private String getErrors(List<Messaging.SendEmailError> errors){
        String errorString = '';
        for(Messaging.SendEmailError error : errors) {
            errorString =  errorString + 'Error Code:' + error.getStatusCode() + ' - ' + error.getMessage() +'\n';
        }

        return errorString;
    }

    @testVisible
    private Messaging.SingleEmailMessage addAttachments(Messaging.SingleEmailMessage email, SendGooderEmailRequest request){
        List<Id> contentVersionIds = request.attachments != null ? request.attachments : new List<Id>();
        
        if (contentVersionIds.size() > 0) {
            email.setEntityAttachments(new List<Id>(contentVersionIds));
        }

        return email;
    }

    private List<String> getListfromObject(Object listObj){
        return (List<String>)listObj;
    }
    
    
    private  Boolean isCollection(Object input){
        Object test;
         try{
            test = (List<Object>)input;
            return true;
        } catch(System.TypeException ex){}
    
        return false;
    }
}