@isTest 
public with sharing class ConsentsTest {

    @isTest 
    private static void itShouldFetchForms(){
        Stub daoStub = new Stub(ConsentsDao.class);
        daoStub.setReturnValue('fetchActiveUniversalConsentForms', new List<Consent_Form__c>());

        Consents bso = new Consents();
        bso.dao = (ConsentsDao)daoStub.instance;

        List<Consent_Form__c> results;

        test.startTest();

        results = bso.getConsentFormsForNewUsers();

        test.stopTest();
        
        daoStub.assertInvoked('fetchActiveUniversalConsentForms');
        System.assert(results.isEmpty());

    }
    
    @isTest 
    private static void itShouldFetchUser(){
        Stub daoStub = new Stub(ConsentsDao.class);
        daoStub.setReturnValue('fetchCosentRelatedUser', new User());

        Consents bso = new Consents();
        bso.dao = (ConsentsDao)daoStub.instance;
        
		User fakeUser = new User(Id=TestUtility.getFakeId(User.SObjectType), FirstName='Joe', LastName='Smith');
        
        User results;

        test.startTest();

        results = bso.getCosentRelatedUser(fakeUser.Id);

        test.stopTest();
        
        daoStub.assertInvoked('fetchCosentRelatedUser');
        //System.assert(results.isEmpty());

    }

    @isTest 
    private static void itShouldSaveforms(){
        Stub daoStub = new Stub(ConsentsDao.class);
        daoStub.setReturnValue('insertConsents', null);

        Consents bso = new Consents();
        bso.dao = (ConsentsDao)daoStub.instance;

        test.startTest();

        bso.saveConsents(new List<Consent__c>());

        test.stopTest();
        
        daoStub.assertInvoked('insertConsents');
    }

    @isTest
    private static void itSHouldMakeAConsentFormForAContact(){
        User fakeUser = new User(Id=TestUtility.getFakeId(User.SObjectType), FirstName='Joe', LastName='Smith');
        Id linkedRecordId = TestUtility.getFakeId(Contact.sObjectType);
        Consent_Form__c form = new Consent_Form__c(Name='Fake Consent', Id=TestUtility.getFakeId(Consent_Form__c.SObjecttype));

        Consent__c result;

        test.startTest();
        
        result = new Consents().makeConsentForUser(linkedRecordId, fakeUser, form);

        test.stopTest();

        System.assertEquals(null, result.Individual__c);
        System.assertEquals(linkedRecordId, result.Contact__c);

    }

    @isTest 
    private static void itShouldMakeAConsentFormForAPersonAccount(){
        User fakeUser = new User(Id=TestUtility.getFakeId(User.SObjectType), FirstName='Joe', LastName='Smith');
        Id linkedRecordId = TestUtility.getFakeId(Account.sObjectType);
        Consent_Form__c form = new Consent_Form__c(Name='Fake Consent', Id=TestUtility.getFakeId(Consent_Form__c.SObjecttype));

        Consent__c result;

        test.startTest();
        
        result = new Consents().makeConsentForUser(linkedRecordId, fakeUser, form);

        test.stopTest();

        System.assertEquals(null, result.Contact__c);
        System.assertEquals(linkedRecordId, result.Individual__c);

    }
}