@isTest
public with sharing class Consent_ShareTest {

    private class ConsentShareDaoStub implements System.StubProvider {
        private Boolean throwException = false;
        private String exceptionMethod;

        public void setThrowException(String methodName) {
            this.throwException = true;
            this.exceptionMethod = methodName;
        }

        public Object handleMethodCall(
            Object stub,
            String methodName,
            Type returnType,
            List<Type> paramTypes,
            List<String> paramNames,
            List<Object> paramValues
        ) {
            if (throwException && methodName == exceptionMethod) {
                throw new DmlException('Test DML failure');
            }

            if (methodName == 'fetchAccountsWithUser') {
                Set<Id> accountIds = (Set<Id>)paramValues[0];
                if (accountIds == null || accountIds.isEmpty()) return new Map<Id, Account>();
                Id accountId = accountIds.iterator().next();
                return new Map<Id, Account>{
                    accountId => new Account(
                        Id = accountId,
                        User__pc = TestUtility.getFakeId(User.SObjectType)
                    )
                };
            }
            if (methodName == 'fetchContactsWithUser') {
                Set<Id> contactIds = (Set<Id>)paramValues[0];
                if (contactIds == null || contactIds.isEmpty()) return new Map<Id, Contact>();
                Id contactId = contactIds.iterator().next();
                return new Map<Id, Contact>{
                    contactId => new Contact(
                        Id = contactId,
                        User__c = TestUtility.getFakeId(User.SObjectType)
                    )
                };
            }
            if (methodName == 'fetchConsentsForAccounts') {
                Set<Id> accountIds = (Set<Id>)paramValues[0];
                if (accountIds == null || accountIds.isEmpty()) return new List<Consent__c>();
                Id accountId = accountIds.iterator().next();
                return new List<Consent__c>{
                    new Consent__c(
                        Id = TestUtility.getFakeId(Consent__c.SObjectType),
                        Individual__c = accountId
                    )
                };
            }
            if (methodName == 'fetchConsentsForContacts') {
                Set<Id> contactIds = (Set<Id>)paramValues[0];
                if (contactIds == null || contactIds.isEmpty()) return new List<Consent__c>();
                Id contactId = contactIds.iterator().next();
                return new List<Consent__c>{
                    new Consent__c(
                        Id = TestUtility.getFakeId(Consent__c.SObjectType),
                        Contact__c = contactId
                    )
                };
            }
            if (methodName == 'insertConsentShares') {
                return null;
            }
            return null;
        }
    }

    @isTest
    static void itShouldCreateSharesForAccounts() {
        ConsentShareDao daoStub = (ConsentShareDao)Test.createStub(ConsentShareDao.class, new ConsentShareDaoStub());
        Consent_Share consentShare = new Consent_Share(
            new List<Id>{TestUtility.getFakeId(Account.SObjectType)},
            'Edit'
        );
        consentShare.dao = daoStub;

        Test.startTest();
        List<Consent__Share> shares = consentShare.createSharesForAccounts(
            new Set<Id>{TestUtility.getFakeId(Account.SObjectType)},
            'Edit'
        );
        Test.stopTest();

        System.assertEquals(1, shares.size(), 'One Consent__Share record should be created');
        System.assertEquals('Edit', shares[0].AccessLevel, 'AccessLevel should be Edit');
        System.assertEquals('ConsentSigner__c', shares[0].RowCause, 'RowCause should be ConsentSigner__c');
    }

    @isTest
    static void itShouldCreateSharesForContacts() {
        ConsentShareDao daoStub = (ConsentShareDao)Test.createStub(ConsentShareDao.class, new ConsentShareDaoStub());
        Consent_Share consentShare = new Consent_Share(
            new List<Id>{TestUtility.getFakeId(Contact.SObjectType)},
            'Edit'
        );
        consentShare.dao = daoStub;

        Test.startTest();
        List<Consent__Share> shares = consentShare.createSharesForContacts(
            new Set<Id>{TestUtility.getFakeId(Contact.SObjectType)},
            'Edit'
        );
        Test.stopTest();

        System.assertEquals(1, shares.size(), 'One Consent__Share record should be created');
        System.assertEquals('Edit', shares[0].AccessLevel, 'AccessLevel should be Edit');
        System.assertEquals('ConsentSigner__c', shares[0].RowCause, 'RowCause should be ConsentSigner__c');
    }

    @isTest
    static void itShouldSaveConsentShares() {
        ConsentShareDao daoStub = (ConsentShareDao)Test.createStub(ConsentShareDao.class, new ConsentShareDaoStub());
        Consent_Share consentShare = new Consent_Share(new List<Id>(), 'Edit');
        consentShare.dao = daoStub;

        List<Consent__Share> shares = new List<Consent__Share>{
            new Consent__Share(
                ParentId = TestUtility.getFakeId(Consent__c.SObjectType),
                UserOrGroupId = TestUtility.getFakeId(User.SObjectType),
                AccessLevel = 'Edit',
                RowCause = 'ConsentSigner__c'
            )
        };

        Test.startTest();
        consentShare.saveConsentShares(shares);
        Test.stopTest();

    }

    @isTest
    static void itShouldHandleSaveConsentSharesError() {
        ConsentShareDaoStub stubProvider = new ConsentShareDaoStub();
        stubProvider.setThrowException('insertConsentShares');
        ConsentShareDao daoStub = (ConsentShareDao)Test.createStub(ConsentShareDao.class, stubProvider);
        Consent_Share consentShare = new Consent_Share(new List<Id>(), 'Edit');
        consentShare.dao = daoStub;

        List<Consent__Share> shares = new List<Consent__Share>{
            new Consent__Share(
                ParentId = TestUtility.getFakeId(Consent__c.SObjectType),
                UserOrGroupId = TestUtility.getFakeId(User.SObjectType),
                AccessLevel = 'Edit',
                RowCause = 'ConsentSigner__c'
            )
        };

        Test.startTest();
        try {
            consentShare.saveConsentShares(shares);
            System.assert(false, 'Expected DmlException');
        } catch (DmlException e) {
            System.assertEquals('Test DML failure', e.getMessage(), 'Expected DML exception should be thrown');
        }
        Test.stopTest();
    }

    @isTest
    static void itShouldCreateConsentShare() {
        Consent_Share consentShare = new Consent_Share(new List<Id>(), 'Edit');
        Id parentId = TestUtility.getFakeId(Consent__c.SObjectType);
        Id userOrGroupId = TestUtility.getFakeId(User.SObjectType);
        String accessLevel = 'Edit';

        Test.startTest();
        Consent__Share share = consentShare.createConsentShare(parentId, userOrGroupId, accessLevel);
        Test.stopTest();

        System.assertNotEquals(null, share, 'Consent__Share should not be null');
        System.assertEquals(parentId, share.ParentId, 'ParentId must match Consent Id');
        System.assertEquals(userOrGroupId, share.UserOrGroupId, 'UserOrGroupId must match User lookup Id');
        System.assertEquals(accessLevel, share.AccessLevel, 'AccessLevel must be Edit');
        System.assertEquals('ConsentSigner__c', share.RowCause, 'RowCause must be ConsentSigner__c');
    }
}