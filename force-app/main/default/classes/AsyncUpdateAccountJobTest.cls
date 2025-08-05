@isTest
public class AsyncUpdateAccountJobTest {
    @isTest
     static void itShouldCallAccounts(){
		Stub accStub = new Stub(Accounts.class);
        accStub.setReturnValue('saveAccounts', null);
        AsyncUpdateAccountJob accJob = new AsyncUpdateAccountJob(new List<Account>());
        accJob.Accounts = (Accounts)accStub.instance;
        Test.startTest();
		accJob.execute(null); 
		Test.stopTest();
        accStub.assertInvoked('saveAccounts');
    }
}