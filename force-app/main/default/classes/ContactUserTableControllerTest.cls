@IsTest(SeeAllData=false)
public class ContactUserTableControllerTest {
    
    @IsTest
    static void testGetTopUsers() {
        Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Account personAccount = new Account(
            FirstName = 'Test',
            LastName = 'Acc',
            RecordTypeId = personAccRecordTypeId
        );
        insert personAccount;
        
        Account testAccount = [SELECT Id, IsPersonAccount, PersonContactId FROM Account WHERE Id = :personAccount.Id];
        System.assertEquals(true, testAccount.IsPersonAccount);
        
      
        Id clientAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Account clientTestAccount = new Account(
            Name = 'Client Test Account',
            RecordTypeId = clientAccRecordTypeId,
            BillingStreet = '123 Street',
            BillingCity = 'TestCity',
            BillingPostalCode = '12345',
            BillingState = 'California',
            BillingCountry = 'United States'
        );
        insert clientTestAccount;
        
        Engagement__c testEngagement = new Engagement__c(
            Client__c = clientTestAccount.Id,
            Engagement_Name_Tag__c = 'Test'
        );
        insert testEngagement;
        
        Engagement_Assignee__c testEngagementAssignee = new Engagement_Assignee__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Assignee',
            Assignee__c = testAccount.Id,
            Engagements__c = testEngagement.Id
        );
        insert testEngagementAssignee;
        
        Id contRecordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client_Contact').getRecordTypeId();
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            RecordTypeId = contRecordTypeId1,
            AccountId = clientTestAccount.Id
        );
        insert testContact;
        
        Id workRecordTypeId = Schema.SObjectType.Work_Record__c.getRecordTypeInfosByName().get('Tax Return').getRecordTypeId();
        Work_Record__c workRecord1 = new Work_Record__c(
            Individual__c = testAccount.Id,
            Work_Record_Contact__c = null,
            Status__c = 'Active',
            RecordTypeId = workRecordTypeId,
            Net_Amount_in_Pocket__c =23,
            Country__c = 'USA',
            Engagement_Assignee__c = testEngagementAssignee.Id
        );
        Work_Record__c workRecord2 = new Work_Record__c(
            Individual__c = testAccount.Id,
            Work_Record_Contact__c = null,
            Status__c = 'Active',
            RecordTypeId = workRecordTypeId,
            Net_Amount_in_Pocket__c =09,
            Country__c = 'USA',
            Engagement_Assignee__c = testEngagementAssignee.Id
        );
        insert new List<Work_Record__c>{ workRecord1, workRecord2 };
            
        Id workRecordTypeId2 = Schema.SObjectType.Work_Record__c.getRecordTypeInfosByName().get('Certificate of Coverage').getRecordTypeId();
        Work_Record__c workRecord3 = new Work_Record__c(
            Individual__c = testAccount.Id,
            Work_Record_Contact__c = null,
            Status__c = 'Active',
            RecordTypeId = workRecordTypeId2,
            Country__c = 'USA',
            Net_Amount_in_Pocket__c =10,
            Engagement_Assignee__c = testEngagementAssignee.Id
        );
        Work_Record__c workRecord4 = new Work_Record__c(
            Individual__c = testAccount.Id,
            Work_Record_Contact__c = null,
            Status__c = 'Active',
            RecordTypeId = workRecordTypeId2,
            Net_Amount_in_Pocket__c =10,
            Country__c = 'USA',
            Engagement_Assignee__c = testEngagementAssignee.Id
        );
        insert new List<Work_Record__c>{ workRecord3, workRecord4 };
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Assignee Portal' LIMIT 1];
        Profile internalUserProfile = [SELECT Id FROM Profile WHERE Name = 'Internal Andersen User' LIMIT 1];
        
        List<User> listOfUsers = new List<User>();
        
        User internalUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Alias = 'tuser1',
            Email = 'testuser1' + DateTime.now().getTime() + '@example.com',
            Username = 'testuser1' + DateTime.now().getTime() + '@example.com',
            ProfileId = internalUserProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Country_of_Service__c = 'USA',
            LinkedIn_URL__c = 'https://www.linkedin.com/in/testuser1'
        );
        listOfUsers.add(internalUser1);
        
        User internalUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Alias = 'tuser2',
            Email = 'testuser2' + DateTime.now().getTime() + '@example.com',
            Username = 'testuser2' + DateTime.now().getTime() + '@example.com',
            ProfileId = internalUserProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Country_of_Service__c = 'URY',
            LinkedIn_URL__c = 'https://www.linkedin.com/in/testuser2'
        );
        listOfUsers.add(internalUser2);
        
        User portalUser = new User(
            FirstName = 'Test',
            LastName = 'Portal',
            Alias = 'tportal',
            Email = 'portaluser' + DateTime.now().getTime() + '@example.com',
            Username = 'portaluser' + DateTime.now().getTime() + '@example.com',
            ProfileId = portalProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = testAccount.PersonContactId,
            LinkedIn_URL__c = 'https://www.linkedin.com/in/portaluser'
        );
        listOfUsers.add(portalUser);
        insert listOfUsers;
        
        workRecord1.Work_Record_Contact__c = internalUser1.Id;
        workRecord2.Work_Record_Contact__c = internalUser2.Id;
        update new List<Work_Record__c>{ workRecord1, workRecord2 };
        
        User queriedPortalUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :portalUser.Id];
        
        System.runAs(portalUser) {
            Test.startTest();
            List<contactuserTableController.UserWrapper> users = contactuserTableController.getTopUsers(2);
            Test.stopTest();
            
            if(queriedPortalUser.AccountId == null) {
                System.assertEquals(0, users.size(), 'Expected 0 users because portalUser.AccountId is null in test context.');
            } else {
                System.assertNotEquals(null, users[0].Email, 'Email should not be null');
                System.assertNotEquals(null, users[0].ProfilePhoto, 'ProfilePhoto should not be null');
            }
        }
    }
    
    @IsTest
    static void testGetUsers() {
        Profile internalUserProfile = [SELECT Id FROM Profile WHERE Name = 'Internal Andersen User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser' + DateTime.now().getTime() + '@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            ProfileId = internalUserProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LinkedIn_URL__c = 'https://www.linkedin.com/in/testuser'
        );
        insert testUser;
        
        Test.startTest();
        List<contactuserTableController.UserWrapper> users = contactuserTableController.getUsers(testUser.Id,1,'Tax Return','USA');
        List<contactuserTableController.UserWrapper> users1 = contactuserTableController.getUsers(testUser.Id,1,'Certificate of Coverage','USA');
        List<contactuserTableController.UserWrapper> users2 = contactuserTableController.getUsers(testUser.Id,1,'Consultation','USA');
        Test.stopTest();
        
        System.assertEquals(1, users.size(), 'Expected one user returned by getUsers');
        System.assertEquals('Test User', users[0].Name, 'Expected user name to match');
    }
    
    @IsTest
    static void testGetEngagementUsers() {
        Profile clientProfile = [SELECT Id FROM Profile WHERE Name = 'Client Portal' LIMIT 1];
        Id clientAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Account clientAccount = new Account(
            Name = 'Client Account',
            RecordTypeId = clientAccRecordTypeId,
            BillingStreet = '123 William Street',
            BillingCity = 'New York',
            BillingPostalCode = '10038',
            BillingState = 'New York',
            BillingStateCode = 'NY',
            BillingCountryCode = 'US',
            BillingCountry = 'United States'
        );
        insert clientAccount;
        
        Id contRecordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client_Contact').getRecordTypeId();
        Contact clientContact = new Contact(
            AccountId = clientAccount.Id,
            FirstName='Testraj',
            LastName = 'ClientContact',
            RecordTypeId = contRecordTypeId1
        );
        insert clientContact;
        
        User clientUser = new User(
            Alias = 'client',
            Email = 'client' + DateTime.now().getTime() + '@test.com',
            EmailEncodingKey = 'UTF-8',
            FirstName='Testraj',
            LastName = 'Client',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = clientProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'client' + DateTime.now().getTime() + '@test.com',
            ContactId = clientContact.Id,
            LinkedIn_URL__c = 'https://www.linkedin.com/in/client'
        );
        insert clientUser;
        
        Engagement__c engagement = new Engagement__c(
            Client__c = clientAccount.Id,
            Engagement_Name_Tag__c = 'Test 2'
        );
        insert engagement;
        
        Profile internalUserProfile = [SELECT Id FROM Profile WHERE Name = 'Internal Andersen User' LIMIT 1];
        User testUser1 = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe' + DateTime.now().getTime() + '@example.com',
            Username = 'johndoe' + DateTime.now().getTime() + '@example.com',
            Alias = 'jdoe',
            ProfileId = internalUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LinkedIn_URL__c = 'https://www.linkedin.com/in/johndoe'
        );
        insert testUser1;
        
        User testUser2 = new User(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'janesmith' + DateTime.now().getTime() + '@example.com',
            Username = 'janesmith' + DateTime.now().getTime() + '@example.com',
            Alias = 'jsmith',
            ProfileId = internalUserProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LinkedIn_URL__c = 'https://www.linkedin.com/in/janesmith'
        );
        insert testUser2;
        
        engagement.Global_Relationship_Director_Manager__c = testUser1.Id;
        engagement.Global_Relationship_Partner__c = testUser2.Id;
        update engagement;
        
        System.runAs(clientUser) {
            Test.startTest();
            List<contactuserTableController.UserWrapper> users = contactuserTableController.getEngagementUsers();
            Test.stopTest();
            
            System.assertEquals(2, users.size(), 'Expected 2 engagement users');
        }
    }
}