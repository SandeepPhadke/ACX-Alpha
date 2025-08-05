@isTest
public with sharing class AccountsDaoTest {
    @isTest
    static void updateAccounts(){
        List<Account> accountsToUpdate = new List<Account>();        
        AccountsDao accDao = new AccountsDao();  
        String message;
        Test.startTest();
        try{
            accDao.updateAccounts(accountsToUpdate);
        } catch (Exception e) {
            message = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, String.isEmpty(message));
    }
    
    @isTest
    private static void itShouldFetchNothing(){
        Map<Id, Account> results;
        
        test.startTest();
        
        results = new AccountsDao().fetchFirmAccountsById(new Set<Id>());
        
        test.stopTest();
        
        System.assertEquals(0, results.keySet().size(), 'nothing should be getting returned here');
    }
}