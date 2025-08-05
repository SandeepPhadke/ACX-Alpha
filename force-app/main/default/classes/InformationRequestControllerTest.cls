@isTest
public class InformationRequestControllerTest {
    @testSetup
    static void setupTestData() {
        // Create Profile for Assignee Portal
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        Account acc = new Account();
        
        acc.FirstName = 'Test';
        
        acc.LastName = 'Person Account';
        
        acc.RecordTypeId = accRecordTypeId;
        
        insert acc;
        
        Account assigneeAccount = [SELECT Id,IsPersonAccount, PersonContactId FROM Account WHERE Id =: acc.Id];
        
        System.assertEquals(true, assigneeAccount.isPersonAccount);
 
        Profile assigneeProfile = [SELECT Id FROM Profile WHERE Name = 'Assignee Portal' LIMIT 1];
        Profile clientProfile = [SELECT Id FROM Profile WHERE Name = 'Client Portal' LIMIT 1];
        //User clientUser = [SELECT Id FROM User WHERE ProfileId =: clientProfile.Id AND IsActive = True LIMIT 1];
        //User assigneeUser = [SELECT Id FROM User WHERE ProfileId =: assigneeProfile.Id AND IsActive = True LIMIT 1];
        // Create Users
        
        system.debug('ispersonAccount : ' + assigneeAccount.IsPersonAccount);
        system.debug('ispersonAccount : ' + assigneeAccount.PersonContactId);
        
        Id accRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
		Id contRecordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client_Contact').getRecordTypeId();
        Account clientAccount = new Account(
            Name = 'Client Account',
            BillingStreet = '123 William Street',
            BillingCity = 'New York',
            BillingPostalCode = '10038',
            BillingState = 'New York',
            BillingStateCode = 'NY',
            BillingCountryCode = 'US',
            BillingCountry = 'United States',
            RecordTypeId = accRecordTypeId1
        );
        insert clientAccount;

        Contact clientContact = new Contact(
            AccountId = clientAccount.Id,
            LastName = 'ClientContact',
            FirstName = 'ClientFirstName',
            RecordTypeId = contRecordTypeId1
        );
        insert clientContact;
        
        system.debug('assigneeAccount.PersonContactId:'+assigneeAccount.PersonContactId);
        User assigneeUser = new User(
            Alias = 'assignee',
            Email = 'assignee@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            FirstName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = assigneeProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'assignee@test.com',
            ContactId = assigneeAccount.PersonContactId
        );
        insert assigneeUser;
        
        User clientUser = new User(
            Alias = 'client',
            Email = 'client@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Client',
            FirstName = 'ClientTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = clientProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'client@test.com',
            ContactId = clientContact.Id
        );
        insert clientUser;

        Engagement__c engagement = new Engagement__c(
            Engagement_Name_Tag__c = 'Test Engagement',
            Client__c = clientAccount.Id
        );
        insert engagement;

        Work_Record__c workRecord = new Work_Record__c(
           // Name = 'Test Work Record',
            Engagement__c = engagement.Id,
            Net_Amount_in_Pocket__c = 1234
        );
        insert workRecord;

        // Create Information Request records
        Information_Request__c request1 = new Information_Request__c(
           // Name = 'Request 1',
            Due_Date__c = Date.today().addDays(5),
            Status__c = 'Action Required',
            Assigned_To__c = 'Mobile Employee'
        );

        Information_Request__c request2 = new Information_Request__c(
          //  Name = 'Request 2',
            Due_Date__c = Date.today().addDays(10),
            Status__c = 'Action Required',
            Client_Contact__c = clientContact.Id,
            Assigned_To__c = 'Client',
            Work_Record__c = workRecord.Id
        );
        insert new List<Information_Request__c>{request1, request2};
    }

    @isTest
    static void testGetInformationRequestsForAssigneeProfile() {
        User assigneeUser = [SELECT Id FROM User WHERE Alias = 'assignee' LIMIT 1];
        System.runAs(assigneeUser) {
            List<Information_Request__c> requests = InformationRequestController.getInformationRequests(10, 0);
        }
    }

    @isTest
    static void testGetInformationRequestsForClientProfile() {
        User clientUser = [SELECT Id FROM User WHERE Alias = 'client' LIMIT 1];
        System.runAs(clientUser) {
            List<Information_Request__c> requests = InformationRequestController.getInformationRequests(10, 0);
        }
    }

    @isTest
    static void testGetInformationRequestCountForAssigneeProfile() {
        User assigneeUser = [SELECT Id FROM User WHERE Alias = 'assignee' LIMIT 1];
        System.runAs(assigneeUser) {
            Integer count = InformationRequestController.getInformationRequestCount();
        }
    }

    @isTest
    static void testGetInformationRequestCountForClientProfile() {
        User clientUser = [SELECT Id FROM User WHERE Alias = 'client' LIMIT 1];
        System.runAs(clientUser) {
            Integer count = InformationRequestController.getInformationRequestCount();
        }
    }
}