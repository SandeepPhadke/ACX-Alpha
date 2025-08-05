@isTest
public class SendGooderEmailActionTest {

    @isTest
    private static void shouldReturnAResult(){
        
        SendGooderEmailRequest req = new SendGooderEmailRequest();
        req.sendToThisOneEmailAddress = 'test@test2.com';
        req.sendToCollectionOfEmailAddresses = new List<String>{'1@2.com', '3@4.com'};
        req.sendCCToJustOneEmailAddress = 'cc@test4.com';
        req.sendCCToCollectionOfEmailAddresses = new List<String>{'cc2@cc.com', 'cc3@cc.com'};
        req.sendBccToThisOneEmailAddress = 'bcc@bcc.com';
        req.sendBccToThisCollectionOfEmailAddresses = new List<String>{'bcc2@bcc.com'};
              
        List<SendGooderEmailResponse> responses;
        
        test.startTest();
        
        responses = SendGooderEmailAction.sendEmails(new List<SendGooderEmailRequest>{req});
        
        test.stopTest();
        
        System.assertEquals(1, responses.size());
        
    }
    
    @isTest
    private static void shouldInvokeService(){
        
        SendGooderEmailRequest req = new SendGooderEmailRequest();
                
        List<SendGooderEmailResponse> responses;
        
        Stub emailStub = new Stub(SendGooderEmail.class);
        emailStub.setReturnValue('sendEmail', new List<SendGooderEmailResponse>());
        
        test.startTest();
        
        responses = SendGooderEmailAction.getResponses(new List<SendGooderEmailRequest>{req}, (SendGooderEmail)emailStub.instance);
        
        test.stopTest();
        
        emailStub.assertInvoked('sendEmail');
        
    }
    
}