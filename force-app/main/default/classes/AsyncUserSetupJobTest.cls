@isTest 
public with sharing class AsyncUserSetupJobTest {

    @isTest 
    private static void itShouldCallTheOtherClassesIfTheresSomethingToProcess(){
        Stub consentStub = new Stub(Consents.class);
        Stub userStub = new Stub(Users.class);
		
        consentStub.setReturnValue('getConsentFormsForNewUsers', new List<Consent_Form__c>{
            new Consent_Form__c(Id=TestUtility.getFakeId(Consent_Form__c.SObjectType), Name='Fake Consent Form')});
        consentStub.setReturnValue('getCosentRelatedUser',
            new User(Id=TestUtility.getFakeId(User.SObjectType), FirstName='Joe', LastName='Smith'));
        consentStub.setReturnValue('makeConsentForUser', new Consent__c());
        consentStub.setReturnValue('saveConsents', null);

        userStub.setReturnValue('establishRelationshipBetweenEntitiesAndUsers', null);
        
        List<AsyncUserSetupQueueItem> queueItems = new List<AsyncUserSetupQueueItem>();
        AsyncUserSetupQueueItem item = new AsyncUserSetupQueueItem();
        item.accountId = TestUtility.getFakeId(Account.SObjectType);
        item.userId = TestUtility.getFakeId(User.SObjectType);
        item.userRecord = new User(FirstName='Joe', LastName='Schmoe');
        
        queueItems.add(item);

        AsyncUserSetupJob job = new AsyncUserSetupJob(queueItems);
        job.consents = (Consents)consentStub.instance;
        job.userBso = (Users)userStub.instance;

        test.startTest();
        
        job.execute(null);

        test.stopTest();

        consentStub.assertInvoked('getConsentFormsForNewUsers');
        consentStub.assertInvoked('makeConsentForUser');
        consentStub.assertInvoked('saveConsents');

        userStub.assertInvoked('establishRelationshipBetweenEntitiesAndUsers');
    }

    @isTest 
    private static void itShouldNotDoAnythingIfNothingToProcess(){
        Stub consentStub = new Stub(Consents.class);
        Stub userStub = new Stub(Users.class);

        List<AsyncUserSetupQueueItem> queueItems = new List<AsyncUserSetupQueueItem>();
 
        AsyncUserSetupJob job = new AsyncUserSetupJob(queueItems);
        job.consents = (Consents)consentStub.instance;
        job.userBso = (Users)userStub.instance;

        test.startTest();
        
        job.execute(null);

        test.stopTest();

        consentStub.assertNotInvoked('getConsentFormsForNewUsers');
        consentStub.assertNotInvoked('makeConsentForUser');
        consentStub.assertNotInvoked('saveConsents');

        userStub.assertNotInvoked('establishRelationshipBetweenEntitiesAndUsers');
    }
}