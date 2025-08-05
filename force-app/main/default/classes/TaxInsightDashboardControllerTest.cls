@isTest
public with sharing class TaxInsightDashboardControllerTest {
    
   @testSetup
    static void setupTestData() {
        Profile internalAndersenProfile = [SELECT Id FROM Profile WHERE Name = 'Internal Andersen User' LIMIT 1];

        User testUser = new User(
            FirstName = 'TeRaj',
            LastName = 'User',
            Email = 'testusraj@example.com',
            Username = 'testusraj@example.com.salesforce',
            Alias = 'tuser',
            ProfileId = internalAndersenProfile.Id,  
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LinkedIn_URL__c = 'https://www.linkedin.com/in/testuser' 
        );
        insert testUser;

        RecordType affiliateRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Firm' LIMIT 1];

        Account affiliateAccount = new Account(
            Name = 'Andersen Test Firm Account#1',
            RecordTypeId = affiliateRecordType.Id,
            BillingCountry ='United States',
            Id = TestUtility.getFakeId(Account.SObjectType)
        );
        //insert affiliateAccount;

        Contact testContact = new Contact(
            FirstName = 'TeRaj',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            AccountId = affiliateAccount.Id,  
            Country_Location__c = 'USA',
            Country_Supports__c = 'CAN',
            Role__c ='Tax Contact',
            Country_Location_Name__c = 'United States',
            Id = TestUtility.getFakeId(Contact.SObjectType)
        );
        //insert testContact;

        System.runAs(testUser) {
            Work_Record__c wr = new Work_Record__c(
                Name = 'TeRaj WR',
                Tax_Return_Summary__c = 'Test Summary',
                Type__c = 'Tax Return',
                Net_Amount_in_Pocket__c = 10,
                Work_Record_Contact__c = testUser.Id  
            );
            insert wr;

            List<Work_Record_Document__c> wrDocuments = new List<Work_Record_Document__c>{
                new Work_Record_Document__c(Work_Record__c = wr.Id, Type__c = 'Federal_Tax_Return', Settlement_Type__c = 'Refund', Amount__c = 1000.00),
                new Work_Record_Document__c(Work_Record__c = wr.Id, Type__c = 'State_Return', Settlement_Type__c = 'Refund', Amount__c = 500.00,State_Province_Name__c='Alabama',State_Province_Amount__c=788),
                new Work_Record_Document__c(Work_Record__c = wr.Id, Type__c = 'Federal_Tax_Return', Settlement_Type__c = 'Payment', Amount__c = 800.00),
                new Work_Record_Document__c(Work_Record__c = wr.Id, Type__c = 'State_Return', Settlement_Type__c = 'Payment', Amount__c = 300.00,State_Province_Name__c='Alabama',State_Province_Amount__c=6987),
                new Work_Record_Document__c(Work_Record__c = wr.Id, Type__c = 'Equalization', Amount__c = 200.00),
                new Work_Record_Document__c(Work_Record__c = wr.Id, Type__c = 'FBAR')
            };
            insert wrDocuments;
        }
    }

    @isTest
    static void testGetFormattedTaxSummary() {
        Work_Record__c wr = [SELECT Id FROM Work_Record__c LIMIT 1];
        Test.startTest();
        TaxInsightDashboardController.WorkRecordSummaryWrapper result = TaxInsightDashboardController.getFormattedTaxSummary(wr.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Test Summary', result.FormattedSummary, 'Summary should match test data');
    }

    @isTest
    static void testGetWorkRecordDocument() {
        Work_Record_Document__c wrd = [SELECT Id FROM Work_Record_Document__c LIMIT 1];
        Test.startTest();
        Work_Record_Document__c result = TaxInsightDashboardController.getWorkRecordDocument(wrd.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1000.00, result.Amount__c, 'Amount should match test data');
    }

    @isTest
    static void testGetWorkRecordDocumentList() {
        Test.startTest();
        List<Work_Record_Document__c> results = TaxInsightDashboardController.getWorkRecordDocumentList();
        Test.stopTest();
        System.assert(results.size() > 0, 'Document list should not be empty');
    }

    @isTest
    static void testGetTaxReturnBreakdown() {
        Work_Record__c wr = [SELECT Id FROM Work_Record__c LIMIT 1];
        Test.startTest();
        TaxInsightDashboardController.TaxBreakdown result = TaxInsightDashboardController.getTaxReturnBreakdown(wr.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.Returns, 'Returns should not be null');
        System.assertNotEquals(null, result.Payments, 'Payments should not be null');
        
        System.assert(result.Returns.Refunds.Federal.containsKey('FederalF'), 'Federal Refund should exist');
        System.assert(result.Returns.Refunds.State.containsKey('StateS'), 'State Refund should exist');
        System.assert(result.Payments.Federal.containsKey('FederalF'), 'Federal Payment should exist');
        System.assert(result.Payments.State.containsKey('StateS'), 'State Payment should exist');
        System.assert(result.Equalization.size() > 0, 'Equalization should not be empty');
        System.assert(result.FBAR.size() > 0, 'FBAR should not be empty');
    }
}