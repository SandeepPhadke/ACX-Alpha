public class UsersDao {

    public void updateUserRelatedEntities(List<SObject> relatedEntityRecords){
        update relatedEntityRecords;
    }

    public List<Database.SaveResult> insertNewUsers(List<User> users, Boolean sendImmediateNotification){
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = sendImmediateNotification;
        
        List<Database.SaveResult> results = database.insert(users, dlo);
        return results;
    }
    
    public List<Database.SaveResult> updateExistingUsers(List<User> users, Boolean sendImmediateNotification){
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = sendImmediateNotification;
        
        List<Database.SaveResult> results = database.update(users, dlo);
        return results;
    }
}