@isTest
public with sharing class ContentDocumentLinkTriggerTest {

    @isTest
    private static void itShouldExecuteTheTrigger(){
		ContentVersion cv = new ContentVersion();
        cv.VersionData = blob.valueOf('test');
        cv.Title = 'test';
        cv.PathOnClient = 'file.csv';
        insert cv;
       
        
    }
}