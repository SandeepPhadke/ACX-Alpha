@isTest
public class PdfViewerControllerTest {
    @isTest
    static void testGetPdfUrl() {
        // Step 1: Create Test Data

        // Create a test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create a Work Record linked to the Account
        ACE_File__c file = new ACE_File__c(
        );
        insert file;

        // Create a ContentDocument and ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Retrieve the ContentDocument Id
        ContentDocument contentDocument = [
            SELECT Id FROM ContentDocument WHERE Id IN (
                SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id
            ) LIMIT 1
        ];

        // Link the ContentDocument to the Work Record
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = file.Id,
            ContentDocumentId = contentDocument.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Step 2: Call the method
        Test.startTest();
        String pdfUrl = PdfViewerController.getPdfUrl(file.Id);
        Test.stopTest();

        // Step 3: Assertions
        System.assertNotEquals(null, pdfUrl, 'PDF URL should not be null');
        System.assert(pdfUrl.contains(contentDocument.Id), 'PDF URL should contain the ContentDocumentId');
        
        // Test for a workRecordId with no linked ContentDocument
        /*Test.startTest();
        String emptyUrl = PdfViewerController.getPdfUrl(null);
        Test.stopTest();
        System.assertEquals(null, emptyUrl, 'PDF URL should be null when workRecordId is null');*/
    }
}