@isTest
public class TA_UserCEventSetAccEmailTest {
    static Id testUserId;
    static Id testAccountId;

    @testSetup
    static void setupTestData() {
        Profile assigneeProfile = [SELECT Id FROM Profile WHERE Name = 'Assignee Portal' LIMIT 1];

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Id accRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();

        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            RecordTypeId = accRecordTypeId,
            BillingCity = 'Seattle',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '98109',
            BillingState = 'Washington',
            BillingStateCode = 'WA',
            BillingStreet = '440 Terry Avenue North',
            PersonTitle = 'test',
            Phone = '98765',
            PersonMobilePhone = '9876545',
            Primary_Email__pc = 'newemail@example.com'
            
        );
        insert testAccount;

        testAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccount.Id LIMIT 1];
       

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'oldemail@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'tuser',
            ProfileId = assigneeProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            Share_Email_with_Employer__c = true,
            ContactId = testAccount.PersonContactId
           // City = 'Albama',
           // Country = 'United States',
           // CountryCode = 'US',
            //State = 'Washington',
           // StateCode = 'WA',
           // Title = 'Test',
           // Phone = '8765',
           // MobilePhone = '2345'
        );
        insert testUser;
        system.debug('testUser: '+testUser);
        testUserId = testUser.Id;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser.Email = 'newemail@example.com';
            update testUser;
        }
        system.debug('testUser1: '+testUser);
        

        Account clientTestAccount = new Account(
            Name = 'Client Test Account',
            RecordTypeId = accRecordTypeId1
        );
        insert clientTestAccount;

        Engagement__c testEngagement = new Engagement__c(
            Engagement_Name_Tag__c = 'Test Engagement',
            Client__c = clientTestAccount.Id
        );
        insert testEngagement;

        Engagement_Assignee__c engagementAssignee = new Engagement_Assignee__c(
            Assignee__c = testAccount.Id,
            First_Name__c = 'Test',
            Last_Name__c = 'Assignee',
            Email__c = 'newemail@example.com',
            Engagements__c = testEngagement.Id
        );
        insert engagementAssignee;
    }

    @isTest
    static void testHandleUserEmailChange() {
       
        
        if (testAccountId == null) {
            List<Account> accounts = [SELECT Id,Primary_Email__pc FROM Account WHERE RecordType.Name = 'Individual' AND Primary_Email__pc != null LIMIT 1];
            if (!accounts.isEmpty()) {
                testAccountId = accounts[0].Id;
            } else {
                System.assert(false, ' No Account found with RecordType Individual.');
            }
        }
           System.assertNotEquals(null, testAccountId, 'testAccountId should not be null before running assertions');
            List<User> UserList = [SELECT Id FROM User WHERE Email = 'newemail@example.com' LIMIT 1];
        system.debug('UserList ::' +  UserList);
        
        Test.startTest();
        Test.enableChangeDataCapture(); 
        Test.getEventBus().deliver();

        EventBus.ChangeEventHeader changeHeader = new EventBus.ChangeEventHeader();
        changeHeader.entityName = 'User';
        changeHeader.changedFields = new List<String>{'Email'};
        changeHeader.changeType = 'Update';
        changeHeader.commitUser = UserList[0].Id;
        changeHeader.recordIds = new List<String>{ UserList[0].Id};
        
            system.debug('changeHeader :::' +  changeHeader);
            
            

        UserChangeEvent changeEvent = new UserChangeEvent();
        changeEvent.ChangeEventHeader = changeHeader;

TA_UserCEventSetAccEmail handler = new TA_UserCEventSetAccEmail();
handler.handleUserEmailChange(new List<UserChangeEvent>{changeEvent});
        Test.stopTest();

        Account updatedAccount = [SELECT Primary_Email__pc FROM Account WHERE Id = :testAccountId LIMIT 1];
        System.assertEquals('newemail@example.com', updatedAccount.Primary_Email__pc, 'Account email should be updated');

        List<Engagement_Assignee__c> updatedEAs = [
            SELECT Email__c FROM Engagement_Assignee__c 
            WHERE Assignee__c = :testAccountId
        ];
        System.assert(!updatedEAs.isEmpty(), 'No Engagement_Assignee__c record found for Assignee ID: ' + testAccountId);
        if (!updatedEAs.isEmpty()) {
            System.assertEquals('newemail@example.com', updatedEAs[0].Email__c, ' Engagement Assignee email should be updated');
        }
    }
}