@isTest
public class UsersTest {

    @isTest 
    private static void itShouldTryToSaveTheRelatedRecords(){
        Stub daoStub = new Stub(UsersDao.class);
        daoStub.setReturnValue('updateUserRelatedEntities', null);

        Map<Id, Id> entityToUserMap = new Map<Id, Id>();
        entityToUserMap.put(TestUtility.getFakeId(Account.SObjectType), TestUtility.getFakeId(User.SObjectType));
        entityToUserMap.put(TestUtility.getFakeId(Contact.SObjectType), TestUtility.getFakeId(User.SObjectType));

        Users userBso = new Users();
        userBso.dao = (UsersDao)daoStub.instance;

        test.startTest();

        userBso.establishRelationshipBetweenEntitiesAndUsers(entityToUserMap);

        
        test.stopTest();

        daoStub.assertInvoked('updateUserRelatedEntities');
    }

    @isTest 
    private static void itShouldEstablishTheRightKindOfObject(){
        SObject account_result;
        SObject contact_result;

        Id fakeAccountId = TestUtility.getFakeId(Account.SObjectType);
        Id fakeContactId = TestUtility.getFakeId(Contact.SObjectType);
        Id fakeUserId = TestUtility.getFakeId(User.SObjectType);

        Users userBso = new Users();

        test.startTest();
        
        account_result = userBso.createLinkageBetweenRelatedRecordAndUser(fakeAccountId, fakeUserId);
        contact_result = userBso.createLinkageBetweenRelatedRecordAndUser(fakeContactId, fakeUserId);

        test.stopTest();

        System.assert(account_result instanceof Account);
        System.assert(contact_result instanceof Contact);
        

    }

    @isTest
    private static void itShouldCallTheDao(){
        Stub daoStub = new Stub(UsersDao.class);
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        
        daoStub.setReturnValue('insertNewUsers', results);
        daoStub.setReturnValue('updateExistingUsers', results);
        
        Users users = new Users();
        users.dao = (UsersDao)daoStub.instance;
        
        test.startTest();
        
        users.createNewUsers(new List<User>(), false);
        users.updateExistingUsers(new List<User>(), false);
        
        test.stopTest();
        
        daoStub.assertInvoked('insertNewUsers');
    }
}