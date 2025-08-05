@isTest
public with sharing class AsyncUpdateAccountRelatedGroupActionTest {

    @isTest
    static void itShouldCreateAsyncJobsWhenGivenValidRequest() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Id fakeGroupId = TestUtility.getFakeId(Group.SObjectType);
        AsyncUpdateAccountRelatedGroupAction.Request req = new AsyncUpdateAccountRelatedGroupAction.Request();
        req.accountId = acc.Id;
        req.groupId = fakeGroupId;

        List<AsyncUpdateAccountRelatedGroupAction.Request> requests = new List<AsyncUpdateAccountRelatedGroupAction.Request>{ req };

        AsyncUpdateAccountRelatedGroupAction.updateAccounts(requests);
        
        System.assertNotEquals(null, AsyncUpdateAccountRelatedGroupAction.asyncJobs, 'asyncJobs list should not be null');
        System.assertEquals(1, AsyncUpdateAccountRelatedGroupAction.asyncJobs.size(), 'There should be exactly one async job created');
    }
}