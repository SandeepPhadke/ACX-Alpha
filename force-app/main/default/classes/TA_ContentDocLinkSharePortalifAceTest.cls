@isTest
public with sharing class TA_ContentDocLinkSharePortalifAceTest {

    @isTest
    private static void shouldRun(){
        Boolean itRan = false;
        
        test.startTest();
            
        try{
            new TA_ContentDocLink_ShareWithPortalIfAce().BeforeInsert(new List<ContentDocumentLink>());
            itRan = true;
        } catch (Exception ex){
            itRan = false;
        }
        
        test.stopTest();
        
        System.assertEquals(true, itRan, 'expect it to just run!');
    }

    @isTest
    private static void shouldReturnTrueIfAceLinked(){
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = TestUtility.getFakeId(Account.SObjectType);

        TA_ContentDocLink_ShareWithPortalIfAce ta = new TA_ContentDocLink_ShareWithPortalIfAce();

        Boolean result;

        Test.startTest();

        result = ta.isLinkedToAceFile(cdl);

        Test.stopTest();

        System.assertEquals(false, result, 'expect to return false');

    }


    @isTest
    private static void shouldReturnFalseIfNotAceLinked(){
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = TestUtility.getFakeId(ace_File__c.SObjectType);

        TA_ContentDocLink_ShareWithPortalIfAce ta = new TA_ContentDocLink_ShareWithPortalIfAce();

        Boolean result;

        Test.startTest();

        result = ta.isLinkedToAceFile(cdl);

        Test.stopTest();

        System.assertEquals(true, result, 'expect to return true');

    }

    @isTest
    private static void testSetVisibilityWhenAppropriate(){
        TA_ContentDocLink_ShareWithPortalIfAce ta = new TA_ContentDocLink_ShareWithPortalIfAce();

        ContentDocumentLink cdl_true = new ContentDocumentLink();
        cdl_true.LinkedEntityId = TestUtility.getFakeId(ace_File__c.SObjectType);
        cdl_true.Id = TestUtility.getFakeId(ContentDocumentLink.SObjectType);

        ContentDocumentLink cdl_false = new ContentDocumentLink();
        cdl_false.LinkedEntityId = TestUtility.getFakeId(Account.SObjectType);
        cdl_false.Id = TestUtility.getFakeId(ContentDocumentLink.SObjectType);

        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>{cdl_true, cdl_false};


        test.startTest();
        
        cdls = ta.reviewFilesAndSetToVisibleIfLinkedToAceFile(cdls); 

        test.stopTest();
		
        Map<Id, ContentDocumentLink> mappedCdls = new Map<Id, ContentDocumentLink>(cdls);
        System.assertEquals('AllUsers', mappedCdls.get(cdl_true.Id).Visibility, 'Expect this record to be visible to all');
        System.assertNotEquals('AllUsers', mappedCdls.get(cdl_false.Id).Visibility, 'Expect this record to not be visible to all');
    }
}