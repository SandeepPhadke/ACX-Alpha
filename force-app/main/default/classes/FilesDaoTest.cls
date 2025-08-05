@isTest 
public with sharing class FilesDaoTest {
   @isTest 
   private static void itShouldExecuteQueries(){
    FilesDao dao = new FilesDao();

    List<Database.DeleteResult> delResults;
    List<Database.SaveResult> inserts;
    List<ContentDocumentLink> fetchResults;

    test.startTest();

    delResults = dao.deleteContentDocumentLinks(new Set<Id>());
    inserts = dao.insertContentDocumentLinks(new List<ContentDocumentLink>());
    fetchResults = dao.fetchContentDocumentLinksForDocumentAndObjectType(new Set<Id>(), 'Case');

    test.stopTest();

    System.assertEquals(0, delResults.size(), 'expect no rows');
    System.assertEquals(0, inserts.size(), 'expect no rows');
    System.assertEquals(0, fetchResults.size(), 'expect no rows');

   }
}