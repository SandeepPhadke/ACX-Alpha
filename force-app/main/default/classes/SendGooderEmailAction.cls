public with sharing class SendGooderEmailAction {

    @InvocableMethod(label = 'Send gooder email')
    public static List<SendGooderEmailResponse> sendEmails(List<SendGooderEmailRequest> requests){	  
        return getResponses(requests, new SendGooderEmail());
    }
    
    @testVisible
    private static List<SendGooderEmailResponse> getResponses(List<SendGooderEmailRequest> requests, SendGooderEmail emailInstance){
        List<SendGooderEmailResponse> responses = emailInstance.sendEmail(requests);
        return responses;
    }
}