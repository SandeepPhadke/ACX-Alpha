@isTest 
public with sharing class UserSetupAndActivationActionTest {

    @isTest
    private static void itShouldCheckBeforeItQueues(){
        AsyncUserSetupQueueItem item = new AsyncUserSetupQueueItem();
        item.userId = TestUtility.getFakeId(User.SObjectType);
        item.accountId = TestUtility.getFakeId(Account.SObjectType);
        item.contactId = TestUtility.getFakeId(Contact.SObjectType);
        item.userRecord = new User();
        
        UserSetupAndActivationAction.Request req = new UserSetupAndActivationAction.Request();
        req.queueItems.add(item);

        List<UserSetupAndActivationAction.Response> results;
        List<Queueable> asyncjobs;

        test.startTest();

        results = UserSetupAndActivationAction.enqueueUserSetupAndActivation(new List<UserSetupAndActivationAction.Request>{req});
        asyncJobs = UserSetupAndActivationAction.asyncJobs;

        test.stopTest();

        System.assertEquals(0, asyncJobs.size(), 'no jobs should have been enqueued!');
        System.assertEquals(1, results.size(), 'expected one result for one list');
        
        UserSetupAndActivationAction.Response response = results[0];

        System.assert(response.msg.contains('NOTHING'));

    }

    @isTest 
    private static void itShouldEnqueueTheJob(){
 		AsyncUserSetupQueueItem item = new AsyncUserSetupQueueItem();
        item.userId = TestUtility.getFakeId(User.SObjectType);
        item.contactId = TestUtility.getFakeId(Contact.SObjectType);
        item.userRecord = new User();
        
        UserSetupAndActivationAction.Request req = new UserSetupAndActivationAction.Request();
        req.queueItems.add(item);

        List<UserSetupAndActivationAction.Response> results;
        List<Queueable> asyncjobs;

        test.startTest();

        results = UserSetupAndActivationAction.enqueueUserSetupAndActivation(new List<UserSetupAndActivationAction.Request>{req});
        asyncJobs = UserSetupAndActivationAction.asyncJobs;

        test.stopTest();

        System.assertEquals(1, asyncJobs.size(), 'one job should have been enqueued!');
        System.assertEquals(1, results.size(), 'expected one result for one list');
        
        UserSetupAndActivationAction.Response response = results[0];

        System.assert(!response.msg.contains('NOTHING'));

    }
}