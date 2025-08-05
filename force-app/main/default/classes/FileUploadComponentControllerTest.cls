@isTest
public class FileUploadComponentControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a test ContentDocument and ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert contentVersion;
    }

    @isTest
    static void testDeleteFileWithValidId() {
        // Query the ContentDocument created in test setup
        ContentDocument contentDocument = [
            SELECT Id 
            FROM ContentDocument
            WHERE LatestPublishedVersionId IN (
                SELECT Id FROM ContentVersion WHERE Title = 'Test File'
            ) LIMIT 1
        ];

        Test.startTest();
        // Call the deleteFile method with a valid ContentDocumentId
        FileUploadComponentController.deleteFile(contentDocument.Id);
        Test.stopTest();

        // Verify that the ContentDocument is deleted
        Integer count = [SELECT Count() FROM ContentDocument WHERE Id = :contentDocument.Id];
        System.assertEquals(0, count, 'The ContentDocument should have been deleted.');
    }
}