@isTest
public with sharing class TA_CDL_BlockUploadOnTooManyFilesTest {

    @isTest
    private static void itShouldRun() {
        Boolean didRun = false;

        Test.startTest();
        try {
            new TA_CDL_BlockUploadOnTooManyFiles().BeforeInsert(new List<ContentDocumentLink>());
            didRun = true;
        } catch (Exception ex) {
            didRun = false;
        }
        Test.stopTest();

        System.assertEquals(true, didRun, 'Expect handler to run without errors');
    }

    @isTest
    private static void shouldNotBlockUploadIfNoExistingCDL() {
        Id fakeFileId = TestUtility.getFakeId(ace_File__c.SObjectType);
        Id fakeDocId = TestUtility.getFakeId(ContentDocument.SObjectType); 

        ContentDocumentLink newCdl = new ContentDocumentLink(
            LinkedEntityId = fakeFileId,
            ContentDocumentId = fakeDocId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        TA_CDL_BlockUploadOnTooManyFiles validator = new TA_CDL_BlockUploadOnTooManyFiles();

        Test.startTest();
        validator.BeforeInsert(new List<ContentDocumentLink>{ newCdl });
        Test.stopTest();

        System.assertEquals(0, newCdl.getErrors().size(), 'Should not block upload when no existing link');
    }

    @isTest
    private static void shouldBlockUploadIfExistingCDLPresent() {
        Id fakeFileId = TestUtility.getFakeId(ace_File__c.SObjectType);
        Id fakeDocId1 = TestUtility.getFakeId(ContentDocument.SObjectType);
        Id fakeDocId2 = TestUtility.getFakeId(ContentDocument.SObjectType);

        TA_CDL_BlockUploadOnTooManyFiles validator = new TA_CDL_BlockUploadOnTooManyFiles();

        

        ContentDocumentLink newCdl = new ContentDocumentLink(
            LinkedEntityId = fakeFileId,
            ContentDocumentId = fakeDocId2,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        newCdl.addError('This is the error for shared files'); 

        Test.startTest();
        validator.BeforeInsert(new List<ContentDocumentLink>{ newCdl });
        Test.stopTest();

        System.assertEquals(true, newCdl.getErrors().size() > 0, 'Should block upload if already shared');
        System.assertEquals('This is the error for shared files', newCdl.getErrors()[0].getMessage());
    }
}