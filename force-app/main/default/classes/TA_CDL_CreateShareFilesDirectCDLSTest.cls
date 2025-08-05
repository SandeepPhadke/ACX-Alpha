@isTest
public with sharing class TA_CDL_CreateShareFilesDirectCDLSTest {

    @isTest
    private static void itShouldOnlyRunOnMappedFiles(){
        Stub filesStub = new Stub(Files.class);
        Stub aFilesStub = new Stub(ace_Files.class);

        filesStub.setReturnValue('addNewContentDocumentLinks', null);
        filesStub.setReturnValue('removeContentDocumentLinks', null);
        aFilesStub.setReturnValue('saveNewFiles', null);        
        Id contentdocumentId = TestUtility.getFakeId(ContentDocument.SObjectType);
        Id contentDocumentLinkId = TestUtility.getFakeId(ContentDocumentLink.SObjectType);
        Id recordId = TestUtility.getFakeId(Case.SObjectType);

        ContentDocumentLink cdl = new ContentDocumentLink(Id=ContentDocumentLinkId, ContentDocumentId = contentdocumentId, LinkedEntityId = recordId);
    
        TA_CDL_CreateSharedFilesForDirectCDLS ta = new TA_CDL_CreateSharedFilesForDirectCDLS();
        
        test.startTest();

        ta.afterInsert(new List<ContentDocumentLink>{cdl});

        test.stopTest();

        System.assertEquals(0, ta.inserts.size());
        filesStub.assertNotInvoked('addNewContentDocumentLinks');
    }

    @isTest
    private static void itShouldSetTheAppropriateLookup(){
        Stub filesStub = new Stub(Files.class);
        Stub aFilesStub = new Stub(ace_Files.class);

        filesStub.setReturnValue('addNewContentDocumentLinks', null);
        filesStub.setReturnValue('removeContentDocumentLinks', null);
        aFilesStub.setReturnValue('saveNewFiles', null);        
        Id contentdocumentId = TestUtility.getFakeId(ContentDocument.SObjectType);
        Id contentDocumentLinkId = TestUtility.getFakeId(ContentDocumentLink.SObjectType);
        Id recordId = TestUtility.getFakeId(Engagement__c.SObjectType);

        TA_CDL_CreateSharedFilesForDirectCDLS ta = new TA_CDL_CreateSharedFilesForDirectCDLS();
        ta.files = (Files)filesStub.instance;
        ta.aFiles = (ace_Files)aFilesStub.instance;

        ContentDocumentLink cdl = new ContentDocumentLink(Id=ContentDocumentLinkId, ContentDocumentId = contentdocumentId, LinkedEntityId = recordId);

        test.startTest();

        ta.afterInsert(new List<ContentDocumentLink>{cdl});

        test.stopTest();
        System.assertEquals(1, ta.inserts.size(), 'expect one shared file');
        
        ace_File__c record = ta.inserts[0];
        System.assertEquals(true, record.Engagement__c == cdl.LinkedEntityId, 'expect to be linked to the engagement');
        System.assertEquals(true, record.Work_Record__c == null, 'expect no work record');
        filesStub.assertInvoked('addNewContentDocumentLinks');
        filesStub.assertInvoked('removeContentDocumentLinks');
        afilesStub.assertInvoked('saveNewFiles');
        
    }


}