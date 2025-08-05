@isTest 
public with sharing class AccountsTest {

    @isTest 
    private static void itShouldCallTheDao(){
        Stub daoStub = new Stub(AccountsDao.class);

        daoStub.setReturnValue('updateAccounts', null);
        daoStub.setReturnValue('fetchFirmAccountsById', new Map<Id, Account>());

        Accounts instance = new Accounts();
        instance.dao = (AccountsDao)daoStub.instance;

        test.startTest();

        instance.saveAccounts(new List<Account>());
        instance.getFirmAccountsById(new Set<Id>());

        test.stopTest();
    
        daoStub.assertInvoked('updateAccounts');
        daoStub.assertInvoked('fetchFirmAccountsById');
    }
}