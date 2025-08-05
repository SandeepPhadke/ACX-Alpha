@isTest
public with sharing class ConsentShareJobTest {

    @isTest
    private static void itShouldCallConsentShareMethodsIfThereAreRecordsToProcess() {
        Stub consentShareStub = new Stub(Consent_Share.class);

        consentShareStub.setReturnValue('createSharesForAccounts', new List<Consent__Share>{
            new Consent__Share(
                ParentId = TestUtility.getFakeId(Consent__c.SObjectType), 
                UserOrGroupId = TestUtility.getFakeId(User.SObjectType), 
                AccessLevel = 'Edit', 
                RowCause = 'consentSigner__c'
            )
        });
        consentShareStub.setReturnValue('createSharesForContacts', new List<Consent__Share>());
        consentShareStub.setReturnValue('saveConsentShares', null);

        List<Id> linkedRecordIds = new List<Id>{
            TestUtility.getFakeId(Account.SObjectType),
            TestUtility.getFakeId(Contact.SObjectType)
        };

        ConsentShareJob job = new ConsentShareJob(linkedRecordIds, 'Edit');
        job.consentShare = (Consent_Share)consentShareStub.instance;

        Test.startTest();
        job.execute(null);
        Test.stopTest();

        consentShareStub.assertInvoked('createSharesForAccounts');
        consentShareStub.assertInvoked('createSharesForContacts');
        consentShareStub.assertInvoked('saveConsentShares');
    }

    @isTest
    private static void itShouldNotCallConsentShareMethodsIfNoRecordsToProcess() {
        Stub consentShareStub = new Stub(Consent_Share.class);

        List<Id> linkedRecordIds = new List<Id>();

        ConsentShareJob job = new ConsentShareJob(linkedRecordIds, 'Edit');
        job.consentShare = (Consent_Share)consentShareStub.instance;

        Test.startTest();
        job.execute(null);
        Test.stopTest();

        consentShareStub.assertNotInvoked('createSharesForAccounts');
        consentShareStub.assertNotInvoked('createSharesForContacts');
        consentShareStub.assertNotInvoked('saveConsentShares');
    }
}