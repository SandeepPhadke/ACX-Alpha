@isTest
public with sharing class FilesTest {

    @isTest 
    public static void itShouldReallyDoNothing(){
        Stub daoStub = new Stub(FilesDao.class);

        daoStub.setReturnValue('fetchContentDocumentLinksForDocumentAndObjectType', new List<ContentDocumentLink>());
        daoStub.setReturnValue('insertContentDocumentLinks', new List<Database.SaveResult>());
        daoStub.setReturnValue('deleteContentDocumentLinks', new List<Database.DeleteResult>());
        Files files = new Files();

        files.dao = (FilesDao)daoStub.instance;

        List<Database.DeleteResult> delResults;
        List<Database.SaveResult> inserts;
        List<ContentDocumentLink> fetchResults;

        test.startTest();

        inserts = files.addNewContentDocumentLinks(new List<ContentDocumentLink>());
        delResults = files.removeContentDocumentLinks(new Set<Id>());
        fetchResults = files.getContentDocsLinkedToSObject(new Set<Id>(), 'Case');


        test.stopTest();

        System.assertNotEquals(null, delResults);
        System.assertNotEquals(null, inserts);
        System.assertNotEquals(null, fetchResults);


    }
}