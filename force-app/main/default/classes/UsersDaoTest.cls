@isTest
public class UsersDaoTest {

    @isTest
    private static void itShouldTryToInsertUsers(){
        List<User> users = new List<User>();
        
        
        List<Database.SaveResult> results;
        
        test.startTest();
        
        results = new UsersDao().insertNewUsers(users, false);
        results = new UsersDao().updateExistingUsers(users, false);
        
        test.stopTest();
        
        System.assertEquals(0, users.size());
        
    }
}