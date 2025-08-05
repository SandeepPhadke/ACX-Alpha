public with sharing class AsyncUserActivationJob implements Queueable{
    
    private static final Boolean SEND_IMMEDIATE_NOTIFICATION = true;
    @testVisible
    private List<User> newUsers;
    @testVisible
    private Users userBso;
    @testVisible
    List<String> errors;
     @testVisible
    private List<AsyncUserSetupQueueItem> queueItems;
   
   
    public AsyncUserActivationJob(List<User> users , List<AsyncUserSetupQueueItem> queueItems) {
        this.newUsers = users;
        this.userBso = new Users();
        this.errors = new List<String>();
        this.queueItems = queueItems != null ? queueItems : new List<AsyncUserSetupQueueItem>();
    }
    public AsyncUserActivationJob(List<User> users) {
                this(users, new List<AsyncUserSetupQueueItem>());

    }

    public void execute(QueueableContext qc){
        activateUsers();

        if (queueItems == null || queueItems.isEmpty()) {
            return;
        }

        Set<Id> linkedRecordIds = new Set<Id>();

        for (AsyncUserSetupQueueItem item : queueItems) {
            Id linkedId = item.getLinkedRecordId();
            if (linkedId != null) {
                linkedRecordIds.add(linkedId);
            }
        }

        if (!linkedRecordIds.isEmpty()) {
           System.enqueueJob(new ConsentShareJob(new List<Id>(linkedRecordIds), 'edit'));
        } else {
            System.debug('AsyncUserActivationJob: No valid linkedRecordIds found, skipping Consent_Share.');
        }
    }

    @testVisible
    private void activateUsers(){
        setUsersToActive();
        updateUsers();
 
    }

    @testVisible
    private void updateUsers(){
         List<Database.SaveResult> saveResults;
        
        try {
            saveResults = this.userBso.updateExistingUsers(this.newUsers, SEND_IMMEDIATE_NOTIFICATION);
        } catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            Logger.error(ex.getMessage());
            Logger.saveLog();
        }
        
        for(DataBase.SaveResult sr : saveResults){
            if(!sr.isSuccess()){
                String errMsg= getErrorString(sr.getErrors());
                this.errors.add(errMsg);
            }   
        }

        if(this.errors.isEmpty() == false){
                logger.error(String.join(this.errors, ','));
                Logger.saveLog();
        }
    }

    @testVisible
    private void setUsersToActive(){
        for(User u : this.newUsers){
            u.IsActive = true;
        }
    }

    @testVisible
    private String getErrorString(List<DataBase.Error> errs){
        String errorString = '';
        
        for(Database.Error err : errs) {
            errorString+= ('The following error has occurred: ');                    
            errorString+=(err.getStatusCode() + ': ' + err.getMessage());
            errorString+=('User fields that affected this error: ' + err.getFields());
        }
        
        return errorString;
    }
  
}