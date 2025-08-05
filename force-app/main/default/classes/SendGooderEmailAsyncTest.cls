@isTest
public class SendGooderEmailAsyncTest {

    @isTest
    private static void testSendAsync(){
        Stub emailStub = new Stub(SendGooderEmail.class);
        
        SendGooderEmailRequest req = new SendGooderEmailRequest();
        req.sendToThisOneEmailAddress = 'test@test2.com';
        req.sendToCollectionOfEmailAddresses = new List<String>{'1@2.com', '3@4.com'};
        req.sendCCToJustOneEmailAddress = 'cc@test4.com';
        req.sendCCToCollectionOfEmailAddresses = new List<String>{'cc2@cc.com', 'cc3@cc.com'};
        req.sendBccToThisOneEmailAddress = 'bcc@bcc.com';
        req.sendBccToThisCollectionOfEmailAddresses = new List<String>{'bcc2@bcc.com'};
            
        SendGooderEmailAsync async = new SendGooderEmailAsync(new List<SendGooderEmailRequest>{req});
        
        emailStub.setReturnValue('sendEmail', null);
        
        async.emailInstance = (SendGooderEmail)emailStub.instance;
        
        test.startTest();
        
        async.execute(null);
        
        test.stopTest();
        
        emailStub.assertInvoked('sendEmail');
    }
}