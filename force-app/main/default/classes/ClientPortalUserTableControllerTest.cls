@isTest
public class ClientPortalUserTableControllerTest {
    @testSetup
    static void setupTestData() {
        // Create an account
        Profile clientProfile = [SELECT Id FROM Profile WHERE Name = 'Client Portal' LIMIT 1];
        //User clientUser = [SELECT Id FROM User WHERE ProfileId =: clientProfile.Id AND IsActive = True LIMIT 1];
        //User assigneeUser = [SELECT Id FROM User WHERE ProfileId =: assigneeProfile.Id AND IsActive = True LIMIT 1];
        // Create Users    
        Id contRecordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client_Contact').getRecordTypeId();    
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Account clientAccount = new Account(
            Name = 'Client Account',
            BillingStreet = '123 William Street',
            BillingCity = 'New York',
            BillingPostalCode = '10038',
            BillingState = 'New York',
            BillingStateCode = 'NY',
            BillingCountryCode = 'US',
            BillingCountry = 'United States',
            RecordTypeId = accRecordTypeId
        );
        insert clientAccount;
        Contact clientContact = new Contact(
            AccountId = clientAccount.Id,
            FirstName = 'ClientFirstName',
            LastName = 'ClientContact',
            RecordTypeId = contRecordTypeId1
        );
        insert clientContact;
        
		String profileId = [SELECT Id FROM Profile WHERE Name = 'Internal Andersen User' LIMIT 1].Id;
        // Create users
        User testUser1 = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            Username = 'testclass0@example.com',
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profileId,
            LanguageLocaleKey = 'en_US',
            Phone = '1234567890',
            Title = 'Manager',
            LinkedIn_URL__c = 'www.linkedin.com/in/johndoe',
            IsActive = true,
            ContactId = null
        );
        insert testUser1;

        User testUser2 = new User(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'janesmith@example.com',
            Username = 'testclass1@example.com',
            Alias = 'jsmith',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profileId,
            LanguageLocaleKey = 'en_US',
            Phone = '9876543210',
            Title = 'Director',
            LinkedIn_URL__c = 'linkedin.com/in/janesmith',
            IsActive = true,
            ContactId = null
        );
        insert testUser2;
        
        User clientUser = new User(
            Alias = 'client',
            Email = 'client@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Client',
            FirstName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = clientProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'client@test.com',
            ContactId = clientContact.Id
        );
        insert clientUser;

        // Create engagements
        Engagement__c engagement = new Engagement__c(
            Client__c = clientAccount.Id,
            Global_Relationship_Director_Manager__c = testUser1.Id,
            Global_Relationship_Partner__c = testUser2.Id
        );
        insert engagement;
    }

    @isTest
    static void testGetEngagementUsers() {
        // Run the method and capture the results
        User clientUser = [SELECT Id FROM User WHERE Username = : 'client@test.com'];
        System.runAs(clientUser) {
            Test.startTest();
            List<ClientPortalUserTableController.UserWrapper> users = ClientPortalUserTableController.getEngagementUsers();
            Test.stopTest();
        
    
            // Verify the results
            System.assertNotEquals(null, users, 'The returned list should not be null.');
            System.assertEquals(2, users.size(), 'The list should contain two users.');
    
            ClientPortalUserTableController.UserWrapper user1 = users[0];
            ClientPortalUserTableController.UserWrapper user2 = users[1];
    
            // Verify user data
            System.assertEquals('John Doe', user1.Name, 'The name of the first user should be John Doe.');
            System.assertEquals('Jane Smith', user2.Name, 'The name of the second user should be Jane Smith.');
    
            System.assertEquals('Manager', user1.Title, 'The title of the first user should be Manager.');
            System.assertEquals('Director', user2.Title, 'The title of the second user should be Director.');
    
            System.assert(user1.LinkedIn_URL.startsWith('https://'), 'The LinkedIn URL for user1 should be formatted with https://');
            System.assert(user2.LinkedIn_URL.startsWith('https://'), 'The LinkedIn URL for user2 should be formatted with https://');
        }
    }
}