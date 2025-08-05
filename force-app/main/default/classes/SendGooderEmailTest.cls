@isTest
public with sharing class SendGooderEmailTest {

    @isTest
    private static void shouldParseAddresses(){
        SendGooderEmailRequest req = new SendGooderEmailRequest();
        req.sendToThisOneEmailAddress = 'test@test2.com';
        req.sendToCollectionOfEmailAddresses = new List<String>{'1@2.com', '3@4.com'};
        req.sendCCToJustOneEmailAddress = 'cc@test4.com';
        req.sendCCToCollectionOfEmailAddresses = new List<String>{'cc2@cc.com', 'cc3@cc.com'};
        req.sendBccToThisOneEmailAddress = 'bcc@bcc.com';
        req.sendBccToThisCollectionOfEmailAddresses = new List<String>{'bcc2@bcc.com'};

        SendGooderEmail svc = new SendGooderEmail();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        test.startTest();

        email = svc.setRecipients(email, req);

        test.stopTest();
        
        System.assertEquals(3, email.getToAddresses().size());
        System.assertEquals(3, email.getCCAddresses().size());
        System.assertEquals(2, email.getBCCAddresses().size());
    }
    
    @isTest
    private static void shouldErrorDueToTemplateAndBody(){
        SendGooderEmailRequest req = new SendGooderEmailRequest();
        req.sendToThisOneEmailAddress = 'test@test2.com';
        req.plainTextBody = 'test';
        req.templateId = TestUtility.getFakeId(EmailTemplate.SObjectType);
        req.bcc = false;

        SendGooderEmail svc = new SendGooderEmail();
        Stub emailStub = new Stub(Emails.class);
        emailStub.setReturnValue('getEmailTemplatesById', new EmailTemplate(Id = req.templateId, Name='Test Template'));
        
        List<SendGooderEmailResponse> responses;
        
        test.startTest();
       	
		responses = svc.sendEmail(new List<SendGooderEmailRequest>{req});
        
        test.stopTest();
		
        System.assertEquals(1, responses.size());
        
        SendGooderEmailResponse response = responses[0];
        
        System.assertEquals(false, response.isSuccess);
        System.assert(response.errors.contains('template'));
		        
    }
    
    @isTest
    private static void shouldBeAsync(){
        SendGooderEmailRequest req = new SendGooderEmailRequest();
        req.sendToThisOneEmailAddress = 'test@test2.com';
        req.plainTextBody = 'test';
        req.sendAsync = true;
        req.bcc = false;

        SendGooderEmail svc = new SendGooderEmail();
        List<SendGooderEmailResponse> responses;
        
        test.startTest();
       	
		responses = svc.sendEmail(new List<SendGooderEmailRequest>{req});
        
        test.stopTest();
		
        System.assertEquals(1, responses.size());
        
        SendGooderEmailResponse response = responses[0];
        
        System.assertEquals(true, response.isSuccess);
        System.assert(response.message.contains('enqueued for sending'));
		        
    }
    
    @isTest
    private static void shouldSendNormalEmail(){
        SendGooderEmailRequest req = new SendGooderEmailRequest();
        req.sendToThisOneEmailAddress = 'test@test2.com';
        req.plainTextBody = 'test';
        req.htmlBody = '<h2>test</h2>';
        req.subject = 'testing';
        req.sendAsync = false;
        req.bcc = false;

        SendGooderEmail svc = new SendGooderEmail();
        List<SendGooderEmailResponse> responses;
        
        test.startTest();
       	
		responses = svc.sendEmail(new List<SendGooderEmailRequest>{req});
        
        test.stopTest();
		
        System.assertEquals(1, responses.size());
        
        SendGooderEmailResponse response = responses[0];
        System.assertEquals(true, response.isSuccess);		        
    }
}