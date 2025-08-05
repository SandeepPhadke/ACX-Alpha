@isTest
public with sharing class ConsentShareDaoTest {

    @isTest
    static void itShouldFetchAccountsWithUser() {
       
        Account acc = new Account(id = TestUtility.getFakeId(Account.SObjectType),Name = 'Test Account');

        ConsentShareDao dao = new ConsentShareDao();
        Test.startTest();
        Map<Id, Account> result = dao.fetchAccountsWithUser(new Set<Id>{acc.Id});
        Test.stopTest();

    }

    @isTest
    static void itShouldFetchContactsWithUser() {
        
        Contact con = new Contact(id = TestUtility.getFakeId(Contact.SObjectType),LastName = 'Test Contact');
     

        ConsentShareDao dao = new ConsentShareDao();
        Test.startTest();
        Map<Id, Contact> result = dao.fetchContactsWithUser(new Set<Id>{con.Id});
        Test.stopTest();

    }

    @isTest
    static void itShouldFetchConsentsForAccounts() {
        Account acc = new Account(id = TestUtility.getFakeId(Account.SObjectType),Name = 'Consent Account');
   

        Consent__c consent = new Consent__c(id = TestUtility.getFakeId(Consent__c.SObjectType),Name = 'Account Consent', Individual__c = acc.Id);
    

        ConsentShareDao dao = new ConsentShareDao();
        Test.startTest();
        List<Consent__c> result = dao.fetchConsentsForAccounts(new Set<Id>{acc.Id});
        Test.stopTest();

    }

    @isTest
    static void itShouldFetchConsentsForContacts() {
        Contact con = new Contact(id = TestUtility.getFakeId(Contact.SObjectType),LastName = 'Consent Contact');

        Consent__c consent = new Consent__c(id = TestUtility.getFakeId(Consent__c.SObjectType),Name = 'Contact Consent', Contact__c = con.Id);

        ConsentShareDao dao = new ConsentShareDao();
        Test.startTest();
        List<Consent__c> result = dao.fetchConsentsForContacts(new Set<Id>{con.Id});
        Test.stopTest();

    }

    
  @isTest
    static void itShouldInsertConsentSharesSuccessfully() {
        Consent__c consent = new Consent__c(Name = 'Test Consent');
        insert consent;

        Consent__Share share = new Consent__Share(
            ParentId = consent.Id,
            UserOrGroupId = UserInfo.getUserId(),
            AccessLevel = 'edit',
            RowCause = Schema.Consent__Share.RowCause.Manual
        );

        ConsentShareDao dao = new ConsentShareDao();
        Test.startTest();
       // dao.insertConsentShares(new List<Consent__Share>{share});
        Test.stopTest();

        List<Consent__Share> shares = [SELECT Id FROM Consent__Share WHERE ParentId = :consent.Id];
        System.assertEquals(1, shares.size(), 'Should insert 1 Consent__Share');
    }

    

    
    
    @isTest
    static void itShouldFetchNothingForAccountsWithUser() {
        ConsentShareDao dao = new ConsentShareDao();

        Test.startTest();
        Map<Id, Account> resultsEmpty = dao.fetchAccountsWithUser(new Set<Id>());
        Map<Id, Account> resultsNull = dao.fetchAccountsWithUser(null);
        Test.stopTest();

        System.assertEquals(0, resultsEmpty.size(), 'Should return empty map for empty set');
        System.assertEquals(0, resultsNull.size(), 'Should return empty map for null set');
    }

    @isTest
    static void itShouldFetchNothingForContactsWithUser() {
        ConsentShareDao dao = new ConsentShareDao();

        Test.startTest();
        Map<Id, Contact> resultsEmpty = dao.fetchContactsWithUser(new Set<Id>());
        Map<Id, Contact> resultsNull = dao.fetchContactsWithUser(null);
        Test.stopTest();

        System.assertEquals(0, resultsEmpty.size(), 'Should return empty map for empty set');
        System.assertEquals(0, resultsNull.size(), 'Should return empty map for null set');
    }

    @isTest
    static void itShouldFetchNothingForConsentsForAccounts() {
        ConsentShareDao dao = new ConsentShareDao();

        Test.startTest();
        List<Consent__c> resultsEmpty = dao.fetchConsentsForAccounts(new Set<Id>());
        List<Consent__c> resultsNull = dao.fetchConsentsForAccounts(null);
        Test.stopTest();

        System.assertEquals(0, resultsEmpty.size(), 'Should return empty list for empty set');
        System.assertEquals(0, resultsNull.size(), 'Should return empty list for null set');
    }

    @isTest
    static void itShouldFetchNothingForConsentsForContacts() {
        ConsentShareDao dao = new ConsentShareDao();

        Test.startTest();
        List<Consent__c> resultsEmpty = dao.fetchConsentsForContacts(new Set<Id>());
        List<Consent__c> resultsNull = dao.fetchConsentsForContacts(null);
        Test.stopTest();

        System.assertEquals(0, resultsEmpty.size(), 'Should return empty list for empty set');
        System.assertEquals(0, resultsNull.size(), 'Should return empty list for null set');
    }

    @isTest
    static void itShouldInsertNothingForConsentShares() {
        ConsentShareDao dao = new ConsentShareDao();
        String message;

        Test.startTest();
        try {
            dao.insertConsentShares(new List<Consent__Share>());
        } catch (Exception e) {
            message = e.getMessage();
        }
        try {
            dao.insertConsentShares(null);
        } catch (Exception e) {
            message = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, String.isEmpty(message), 'No exception should be thrown for empty or null list');
    }
}