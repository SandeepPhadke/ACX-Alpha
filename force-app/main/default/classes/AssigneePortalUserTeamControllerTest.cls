@IsTest(SeeAllData=false)
public class AssigneePortalUserTeamControllerTest {
    @IsTest
    static void testGetTopUsers() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        Account a = new Account();
        
        a.FirstName = 'Test';
        
        a.LastName = 'Person Account';
        
        a.RecordTypeId = accRecordTypeId;
        
        insert a;
        
        Account testAccount = [SELECT Id,IsPersonAccount, PersonContactId FROM Account WHERE Id =: a.Id];
        
        System.assertEquals(true, testAccount.isPersonAccount);
        Id contRecordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client_Contact').getRecordTypeId();
		Id accRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
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

        Engagement_Assignee__c testEngagementAssignee = new Engagement_Assignee__c(
           // Name = 'Test Engagement Assignee',
            First_Name__c = 'Test',
            Last_Name__c = 'Assignee',
            Assignee__c = testAccount.Id,
            Engagements__c = testEngagement.Id
        );
        insert testEngagementAssignee;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            RecordTypeId = contRecordTypeId1,
            AccountId = clientTestAccount.Id
        );
        insert testContact;
		
        Id wrRecordTypeId = Schema.SObjectType.Work_Record__c.getRecordTypeInfosByName().get('Tax Return').getRecordTypeId();
        Work_Record__c workRecord1 = new Work_Record__c(
            Individual__c = testAccount.Id,
            Work_Record_Contact__c = null, // Will update later after User creation
            Status__c = 'Active',
            RecordTypeId = wrRecordTypeId,
            Country__c = 'USA',
            Engagement_Assignee__c = testEngagementAssignee.Id,
            Net_Amount_in_Pocket__c = 1234
        );

        Work_Record__c workRecord2 = new Work_Record__c(
            Individual__c = testAccount.Id,
            Work_Record_Contact__c = null, // Will update later after User creation
            Status__c = 'Active',
            Country__c = 'URY',
            RecordTypeId = wrRecordTypeId,
            Engagement_Assignee__c = testEngagementAssignee.Id,
            Net_Amount_in_Pocket__c = 1234
        );

        insert new List<Work_Record__c>{workRecord1, workRecord2};

        // Step 2: Create UserRole and User inside System.runAs
        

        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Assignee Portal' LIMIT 1];
		Profile internalUserProfile = [SELECT Id FROM Profile WHERE Name = 'Internal Andersen User' LIMIT 1];
        
		List<User> listOfUsers = new List<User>();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User internalUser1 = new User(
            	FirstName = 'Test',
                LastName = 'User',
                Alias = 'tuser',
                Email = 'testuser@example.com',
                Username = 'testuser' + DateTime.now().getTime() + '@example.com',
                ProfileId = internalUserProfile.Id,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Country_of_Service__c = 'URY',
                LinkedIn_URL__c = 'google.com'
            );
            listOfUsers.add(internalUser1);
            
            User internalUser2 = new User(
            	FirstName = 'Test',
                LastName = 'User',
                Alias = 'tuser',
                Email = 'testuser@example.com',
                Username = 'testuser1' + DateTime.now().getTime() + '@example.com',
                ProfileId = internalUserProfile.Id,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Country_of_Service__c = 'USA',
                LinkedIn_URL__c = 'google.com'
            );
            listOfUsers.add(internalUser2);
            User portalUser = new User(
                FirstName = 'Test',
                LastName = 'User',
                Alias = 'tuser',
                Email = 'testuser@example.com',
                Username = 'testuser' + DateTime.now().getTime() + '@example.com',
                ProfileId = portalProfile.Id,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ContactId = testAccount.PersonContactId,
                LinkedIn_URL__c = 'google.com'
            );	
            listOfUsers.add(portalUser);
            insert listOfUsers;
        }

        // Update Work_Record__c with portalUser.Id
        workRecord1.Work_Record_Contact__c = listOfUsers[0].Id;
        workRecord2.Work_Record_Contact__c = listOfUsers[1].Id;
        update new List<Work_Record__c>{workRecord1, workRecord2};
		
        //User internalUser = new User(Id = listOfUsers[1].Id);
        // Step 3: Execute the method under test
        System.runAs(listOfUsers[2]) {
            Test.startTest();
            List<AssigneePortalUserTeamController.UserWrapper> userList = AssigneePortalUserTeamController.getTopUsers(2);
            Test.stopTest();

            // Step 4: Verify the results
            System.assertNotEquals(0, userList.size(), 'User list should not be empty');
            System.assertEquals(2, userList.size(), 'The user list size should match the number of unique countries');
            System.assertEquals('Test User', userList[0].Name, 'User name should match the created test user');
        }
    }
}