@isTest 
public with sharing class AsyncUserActivationJobTest {

    @isTest 
    private static void itShouldCallTheBso() {
       
        Stub userStub = new Stub(Users.class);
        userStub.setReturnValue('updateExistingUsers', new List<Database.SaveResult>());

        // Fake user
        User fakeUser = new User(Id = TestUtility.getFakeId(User.SObjectType), IsActive = false);
        
        // create queueItem
        AsyncUserSetupQueueItem queueItem = new AsyncUserSetupQueueItem();
        queueItem.userId = fakeUser.Id;
        queueItem.contactId = TestUtility.getFakeId(Contact.SObjectType);
        queueItem.userRecord = fakeUser;
        queueItem.executingUserId = UserInfo.getUserId(); // required field

        // Create job
        AsyncUserActivationJob job = new AsyncUserActivationJob(
            new List<User>{ fakeUser },
            new List<AsyncUserSetupQueueItem>{ queueItem }
        );
        job.userBso = (Users)userStub.instance;

        Test.startTest();
        job.execute(null);
        Test.stopTest();

        userStub.assertInvoked('updateExistingUsers');
    }

    @isTest 
    public static void isShouldHandleErrors() {
       
        Database.SaveResult sr = (Database.SaveResult) JSON.deserialize(
            '{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
            Database.SaveResult.class
        );

        Stub userStub = new Stub(Users.class);
        userStub.setReturnValue('updateExistingUsers', new List<Database.SaveResult>{ sr });

        User fakeUser = new User(Id = TestUtility.getFakeId(User.SObjectType), IsActive = false);
        
        
        AsyncUserSetupQueueItem queueItem = new AsyncUserSetupQueueItem();
        queueItem.userId = fakeUser.Id;
        queueItem.contactId = TestUtility.getFakeId(Contact.SObjectType);
        queueItem.userRecord = fakeUser;
        queueItem.executingUserId = UserInfo.getUserId();

        AsyncUserActivationJob job = new AsyncUserActivationJob(
            new List<User>{ fakeUser },
            new List<AsyncUserSetupQueueItem>{ queueItem }
        );
        job.userBso = (Users)userStub.instance;

        Test.startTest();
        job.execute(null);
        Test.stopTest();

        userStub.assertInvoked('updateExistingUsers');
        System.assertEquals(true, job.errors.size() > 0, 'Expected error was not captured.');
    }
}