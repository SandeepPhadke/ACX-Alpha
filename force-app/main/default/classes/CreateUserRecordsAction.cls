public class CreateUserRecordsAction {

    @testVisible
    private static Users userBso = null;
    
    @InvocableMethod
    public static List<Result> createNewUsers(List<Request> requests){
    	List<Result> results = new List<Result>();
        for(Request r: requests){
            results.add(getResults(r.users, r.sendImmediateNotification));
        }
                        
        return results;
    }
    
    @testVisible
    private static Result getResults(List<User> newUsers, Boolean sendImmediateNotification){
        Result result = new Result();
        
        List<Database.SaveResult> saveResults;
        
        try {
            saveResults = getUserBso().createNewUsers(newUsers, sendImmediateNotification);
        } catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            Logger.error(ex.getMessage());
            Logger.saveLog();
        }
        
        for(DataBase.SaveResult sr : saveResults){
            if(!sr.isSuccess()){
               result.hasErrors = true;
               result.errors.add(getErrorString(sr.getErrors()));
            }
        }
        
        return result;
        
    }
   
    @testVisible
    private static String getErrorString(List<DataBase.Error> errs){
        String errorString = '';
        
        for(Database.Error err : errs) {
            errorString+= ('The following error has occurred: ');                    
            errorString+=(err.getStatusCode() + ': ' + err.getMessage());
            errorString+=('User fields that affected this error: ' + err.getFields());
        }
        
        return errorString;
    }
    
    private static Users getUserBso(){
        if(userBso == null){
            userBso = new Users();
        } 
        return userBso;
    }
    
    public class Request {
       @InvocableVariable(label='users' required=true)
       public List<User> users;
       @InvocableVariable(label='send immediate notification' required=false)
       public Boolean sendImmediateNotification;
        
        public Request(){
            this.users = new List<User>();
            this.sendImmediateNotification = false;
        }
    }
    
    public class Result {
       @InvocableVariable(label='Has Errors')
        public Boolean hasErrors;
        @InvocableVariable
        public List<String> errors;
        
        public Result(){
            this.hasErrors = false;
            this.errors = new List<String>();
        }
    }
}