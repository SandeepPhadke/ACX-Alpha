@isTest
private class WorkRecordStatusControllerTest {
    @TestSetup
    static void setupTestData() {
        Account testPersonAccount = new Account(
            FirstName = 'Test',
            LastName = 'Person Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId()
        );
        insert testPersonAccount;

        testPersonAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :testPersonAccount.Id];

        Account clientAccount = new Account(Name = 'Test Client Account', 
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId()
        );
        insert clientAccount;

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Username = 'admin.user.' + DateTime.now().getTime() + '@testorg.com',
            FirstName = 'tehunter',
            LastName = 'AdminUser',
            Email = 'admin.user@testorg.com',
            Alias = 'auser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = adminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;

        System.runAs(adminUser) {
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Assignee%' AND UserType LIKE '%Customer%' LIMIT 1];
            User testUser = new User(
                ContactId = testPersonAccount.PersonContactId,
                Username = 'test.user.' + DateTime.now().getTime() + '@testorg.com',
                FirstName = 'TeHunterrec',
                LastName = 'TestUser',
                Email = 'test.user@testorg.com',
                Alias = 'tuser',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = communityProfile.Id,
                LanguageLocaleKey = 'en_US'
            );
            insert testUser;
        }

        Engagement__c engagement = new Engagement__c(
            Engagement_Name_Tag__c = 'Test Engagement',
            Client__c = clientAccount.Id,
            Status__c = 'Active'
        );
        insert engagement;

        Engagement_Assignee__c assignee = new Engagement_Assignee__c(
            Assignee__c = testPersonAccount.Id,
            Engagements__c = engagement.Id
        );
        insert assignee;

        List<Work_Record__c> workRecords = new List<Work_Record__c>();
        for (Integer i = 0; i < 3; i++) {
            workRecords.add(new Work_Record__c(
               // Name = 'Test Work Record ' + i,
				RecordTypeId = Schema.SObjectType.Work_Record__c.getRecordTypeInfosByName().get('Tax Return').getRecordTypeId(),
                Status__c = 'Active',
                Milestone__c = 'Data Collection',
                Milestone_for_Client__c = 'In Progress',
                Net_Amount_in_Pocket__c = 10,
                Engagement_Assignee__c = assignee.Id,
                Engagement__c = engagement.Id,
				Individual__c = testPersonAccount.Id
            ));
        }
        insert workRecords;
    }

    @isTest
    static void testGetOpenWorkRecords() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'test.user.%' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        WorkRecordStatusController.setmockIndividualId(testAccount.Id);

        Test.startTest();
        System.runAs(testUser) {
            List<WorkRecordStatusController.WorkRecordWrapper> results = 
                WorkRecordStatusController.getOpenWorkRecords();
            System.assertNotEquals(null, results, 'Results should not be null');

            
        }
        Test.stopTest();
    }
    
    @isTest
    static void testWorkRecordWrapper() {
        Work_Record__c record = [SELECT Id, Name, Milestone_for_Client__c, RecordTypeId FROM Work_Record__c LIMIT 1];
        String recordTypeName = 'Test Record Type';
        List<WorkRecordStatusController.StatusStepWrapper> steps = new List<WorkRecordStatusController.StatusStepWrapper>();
        
        WorkRecordStatusController.WorkRecordWrapper wrapper = 
            new WorkRecordStatusController.WorkRecordWrapper(record, recordTypeName, steps);

        System.assertEquals(record.Id, wrapper.recordId, 'Record ID should match');
        System.assertEquals(record.Milestone_for_Client__c, wrapper.status, 'Status should match');
        System.assertEquals(record.Name, wrapper.workRecordName, 'Work Record Name should match');
        System.assertEquals(recordTypeName, wrapper.recordTypeName, 'Record Type Name should match');
    }

    @isTest
    static void testGetIndividualIdFromUserId() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'test.user.%' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        String assigneeId = WorkRecordStatusController.getIndividualIdFromUserId(testUser.Id);
        Test.stopTest();

        System.assertEquals(testAccount.Id, assigneeId, 
            'Should return correct Assignee ID for the test user');
    }

    @isTest
    static void testErrorHandling() {
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Username = 'standard.user.' + DateTime.now().getTime() + '@testorg.com',
            FirstName = 'testhunter',
            LastName = 'StandardUser',
            Email = 'standard.user@testorg.com',
            Alias = 'stduser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = stdProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Test.startTest();
        System.runAs(testUser) {
            try {
                WorkRecordStatusController.getOpenWorkRecords();
            } catch (AuraHandledException e) {
              
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testGetOpenWorkRecordsSuccess() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'test.user.%' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        WorkRecordStatusController.setmockIndividualId(testAccount.Id);
        
        WorkRecordStatusController.mockResponse = '{"controllerValues":{"Data Collection":0,"Review":1},' +
            '"values":[{"label":"In Progress","value":"In Progress","validFor":[0,1]},' +
            '{"label":"Completed","value":"Completed","validFor":[1]}]}';
        
        Test.startTest();
        System.runAs(testUser) {
            List<WorkRecordStatusController.WorkRecordWrapper> results = 
                WorkRecordStatusController.getOpenWorkRecords();
            
            System.assertNotEquals(null, results, 'Results should not be null');
            System.assert(!results.isEmpty(), 'Should return work records');
            
            WorkRecordStatusController.WorkRecordWrapper wrapper = results[0];
            System.assertNotEquals(null, wrapper.statusSteps, 'Status steps should not be null');
            System.assert(!wrapper.statusSteps.isEmpty(), 'Should have status steps');
            
            System.assertEquals('In Progress', wrapper.statusSteps[0].label, 'First step should be In Progress');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetAssigneeIdFromUserIdNull() {
        User standardUser = createStandardUser();
        
        Test.startTest();
        String result = WorkRecordStatusController.getIndividualIdFromUserId(standardUser.Id);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Should return null for user without contact');
    }

    @isTest
    static void testPicklistProcessing() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        Map<Id, List<WorkRecordStatusController.PicklistEntryWrapper>> result = 
            WorkRecordStatusController.getRecordTypePicklists();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return picklist map');
        System.assert(!result.isEmpty(), 'Should have picklist values');
    }

    @isTest
    static void testHttpCalloutError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());
        
        Test.startTest();
        Map<Id, List<WorkRecordStatusController.PicklistEntryWrapper>> result = 
            WorkRecordStatusController.getRecordTypePicklists();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return empty map on error');
    }

    @isTest
    static void testGetSingleWorkRecord() {
        // Get a test work record
        Work_Record__c testRecord = [SELECT Id FROM Work_Record__c LIMIT 1];
        
        Test.startTest();
        WorkRecordStatusController.WorkRecordWrapper result = 
            WorkRecordStatusController.getSingleWorkRecord(testRecord.Id);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result, 'Should return a work record wrapper');
        System.assertEquals(testRecord.Id, result.recordId, 'Should return correct record');
        System.assertNotEquals(null, result.statusSteps, 'Should have status steps');
        System.assert(!result.statusSteps.isEmpty(), 'Should have at least one status step');
    }

    @isTest
    static void testGetSingleWorkRecordError() {
        Test.startTest();
        try {
            WorkRecordStatusController.getSingleWorkRecord(null);
            System.assert(false, 'Should throw an exception for null record ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 
                'Should throw appropriate error message');
        }
        
        try {
            WorkRecordStatusController.getSingleWorkRecord('invalid-id');
            System.assert(false, 'Should throw an exception for invalid record ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 
                'Should throw appropriate error message');
        }
        Test.stopTest();
    }

    private static User createStandardUser() {
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Username = 'std.user.' + DateTime.now().getTime() + '@test.com',
            FirstName = 'huntest',
            LastName = 'TestUser',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = stdProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        return testUser;
    }

    // Mock class for successful HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"controllerValues":{"Record Created":0,"In Progress":1,"Completed":2},' +
                       '"values":[{"label":"In Progress","value":"In Progress","validFor":[1]},' +
                       '{"label":"Completed","value":"Completed","validFor":[2]}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock class for error HTTP response
    private class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            res.setBody('Not Found');
            return res;
        }
    }
}