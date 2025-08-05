@isTest
public class PortalTaxConsultantControllerTest {
    @testSetup
    static void setupTestData() {
        Work_Record__c workRecord = new Work_Record__c(Net_Amount_in_Pocket__c = 1234);
        insert workRecord;

        Information_Request__c infoRequest = new Information_Request__c(
            Work_Record__c = workRecord.Id
        );
        insert infoRequest;
    }

    @isTest
    static void testGetTopUsers_Success() {
        Information_Request__c infoRequest = [SELECT Id, Work_Record__c FROM Information_Request__c LIMIT 1];

        Test.startTest();
        List<AssigneePortalTaxConsultantController.UserWrapper> users = 
            AssigneePortalTaxConsultantController.getTopUsers(infoRequest.Id);
        Test.stopTest();

        System.assertNotEquals(users, null, 'User list should not be null');
        System.assertEquals(1, users.size(), 'User list size should be 1');
    }

    @isTest
    static void testGetTopUsers_NoWorkRecord() {
        Information_Request__c infoRequest = new Information_Request__c();
        insert infoRequest;

        Test.startTest();
        List<AssigneePortalTaxConsultantController.UserWrapper> users = 
            AssigneePortalTaxConsultantController.getTopUsers(infoRequest.Id);
        Test.stopTest();

        System.assertNotEquals(users, null, 'User list should not be null');       
    }

    @isTest
    static void testGetTopUsers_InvalidId() {
        Test.startTest();
        List<AssigneePortalTaxConsultantController.UserWrapper> users = 
            AssigneePortalTaxConsultantController.getTopUsers('InvalidId');
        Test.stopTest();

        System.assertNotEquals(users, null, 'User list should not be null');
        System.assertEquals(0, users.size(), 'User list should be empty for an invalid ID');
    }
}