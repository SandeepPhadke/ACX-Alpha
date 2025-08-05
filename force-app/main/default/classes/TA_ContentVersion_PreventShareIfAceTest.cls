@isTest
public with sharing class TA_ContentVersion_PreventShareIfAceTest {
   
    @isTest
    private static void itShouldRun(){
        Boolean itRan = false;
        
        test.startTest();
            
        try{
            new TA_ContentVersion_PreventShareIfAce().BeforeInsert(new List<ContentVersion>());
            itRan = true;
        } catch (Exception ex){
            itRan = false;
        }
        
        test.stopTest();
        
        System.assertEquals(true, itRan, 'expect it to just run!');
    }

    @isTest
    private static void shouldReturnTrueIfAceLinked(){
        ContentVersion cv = new ContentVersion();
        cv.FirstPublishLocationId = TestUtility.getFakeId(Account.SObjectType);

        TA_ContentVersion_PreventShareIfAce ta = new TA_ContentVersion_PreventShareIfAce();

        Boolean result;

        Test.startTest();

        result = ta.isLinkedToAceFile(cv);

        Test.stopTest();

        System.assertEquals(false, result, 'expect to return false');

    }


    @isTest
    private static void shouldReturnFalseIfNotAceLinked(){
        ContentVersion cv = new ContentVersion();
        cv.FirstPublishLocationId = TestUtility.getFakeId(ace_File__c.SObjectType);

        TA_ContentVersion_PreventShareIfAce ta = new TA_ContentVersion_PreventShareIfAce();

        Boolean result;

        Test.startTest();

        result = ta.isLinkedToAceFile(cv);

        Test.stopTest();

        System.assertEquals(true, result, 'expect to return true');

    }

    @isTest
    private static void testSetVisibilityWhenAppropriate(){
        TA_ContentVersion_PreventShareIfAce ta = new TA_ContentVersion_PreventShareIfAce();

        ContentVersion cv_true = new ContentVersion();
        cv_true.FirstPublishLocationId = TestUtility.getFakeId(ace_File__c.SObjectType);
        cv_true.Id = TestUtility.getFakeId(ContentVersion.SObjectType);

        ContentVersion cv_false = new ContentVersion();
        cv_false.FirstPublishLocationId = TestUtility.getFakeId(Account.SObjectType);
        cv_false.Id = TestUtility.getFakeId(ContentVersion.SObjectType);

        List<ContentVersion> cvs = new List<ContentVersion>{cv_true, cv_false};


        test.startTest();
        
        cvs = ta.reviewFilesAndPreventFurtherSharingIfLinkedToAceFile(cvs); 

        test.stopTest();
		
        Map<Id, ContentVersion> mappedcvs = new Map<Id, ContentVersion>(cvs);
        System.assertEquals('R', mappedcvs.get(cv_true.Id).SharingOption, 'Expect this record to be visible to all');
        System.assertNotEquals('A', mappedcvs.get(cv_false.Id).SharingOption, 'Expect this record to not be visible to all');
    }
}