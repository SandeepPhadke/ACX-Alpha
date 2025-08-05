@isTest
public class CreateUserRecordsActionTest {
    
    @isTest
    private static void itShouldCallTheBsoClass(){
        Stub userStub = new Stub(Users.class);
        userStub.setReturnValue('createNewUsers', new List<Database.SaveResult>());
        
        List<CreateUserRecordsAction.Request> requests = new List<CreateUserRecordsAction.Request>();
        requests.add(new CreateUserRecordsAction.Request());
        
        CreateUserRecordsAction.userBso = (Users)userStub.instance;
        
        test.startTest();
        
        CreateUserRecordsAction.createNewUsers(requests);
            
        test.stopTest();
        
        userStub.assertInvoked('createNewUsers');
    }
    
    @isTest
    private static void itShouldHandleErrors(){
        Database.SaveResult sr = (DataBase.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
		
        Stub userStub = new Stub(Users.class);
        userStub.setReturnValue('createNewUsers', new List<Database.SaveResult>{sr});
        
        List<CreateUserRecordsAction.Request> requests = new List<CreateUserRecordsAction.Request>();
        
        requests.add(new CreateUserRecordsAction.Request());
        
        CreateUserRecordsAction.userBso = (Users)userStub.instance;
        List<CreateUserRecordsAction.Result> results;
        
        test.startTest();
        
        results = CreateUserRecordsAction.createNewUsers(requests);
            
        test.stopTest();
        
        userStub.assertInvoked('createNewUsers');

        CreateUserRecordsAction.Result result = results[0];
        System.assertEquals(true, result.hasErrors, 'expect an error');
        
    }
}