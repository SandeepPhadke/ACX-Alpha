@isTest
public class TA_ContentVersion_SetFileDetailsTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test user
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserforace@example.com'
        );
        insert testUser;

        // Create an Ace_File__c record
        ace_File__c aceFile = new ace_File__c();
        insert aceFile;

        // Create a ContentVersion record linked to the Ace File
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test Data'),
            FirstPublishLocationId = aceFile.Id
        );
        insert cv;
    }

    @isTest
    static void testAfterInsert() {
        Test.startTest();
        
        // Fetch the inserted ContentVersion
        ContentVersion insertedCV = [SELECT Id, FirstPublishLocationId, FileType, Title, CreatedById, CreatedDate, ContentSize  FROM ContentVersion LIMIT 1];

        // Instantiate the class and call AfterInsert
        TA_ContentVersion_SetFileDetails fileDetailsHandler = new TA_ContentVersion_SetFileDetails();
        fileDetailsHandler.AfterInsert(new List<ContentVersion>{insertedCV});

        Test.stopTest();
        
        // Assertions to validate logic
        System.assertNotEquals(null, insertedCV.FirstPublishLocationId, 'FirstPublishLocationId should not be null');
        System.assertEquals(true, fileDetailsHandler.isLinkedToAceFile(insertedCV), 'ContentVersion should be linked to an Ace File');
    }
}