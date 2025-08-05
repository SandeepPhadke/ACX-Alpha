public class Users {

    //todo: this happens ina  few places..  relocate to common class ?
    private static final String LINKED_ID_ACCOUNT_TYPE = 'Account';
    private static final String LINKED_ID_CONTACT_TYPE = 'Contact';
    
    @testVisible
    private UsersDao dao;
    
    public Users(){
        this.dao = new UsersDao();
    }

    
    public void establishRelationshipBetweenEntitiesAndUsers(Map<Id, Id> entityToUserMap){
        List<SObject> recordsToUpdate = new List<SObject>();

        for(Id entityId : entityToUserMap.keySet()){
            recordsToUpdate.add(createLinkageBetweenRelatedRecordAndUser(entityId, entityToUserMap.get(entityId)));
        }

        this.dao.updateUserRelatedEntities(recordsToUpdate);

    }
    
    public List<Database.SaveResult> createNewUsers(List<User> users, Boolean sendImmediateNotification){
    	return this.dao.insertNewUsers(users, sendImmediateNotification);
    }
    
    public List<Database.SaveResult> updateExistingUsers(List<User> users, Boolean sendImmediateNotification){
    	return this.dao.updateExistingUsers(users, sendImmediateNotification);
    }

    @testVisible
    private SObject createLinkageBetweenRelatedRecordAndUser(Id relatedRecordId, Id userId){
        SObject record;
        String relatedRecordObjectType = relatedRecordId.getSobjectType().toString();

        if(relatedRecordObjectType.equals(LINKED_ID_ACCOUNT_TYPE)){
           record = new Account(Id=relatedRecordId, User__pc = userId);
        }
        else if(relatedRecordObjectType.equals(LINKED_ID_CONTACT_TYPE)){
            record = new Contact(Id=relatedRecordId, User__c = userId);
        } else {
            Logger.error('SOMEHOW A REQUEST WAS ADDED WITHOUT ALL THE DETAILS. Or the wrong type of Id was passed.  The object type of the Id was: '+relatedRecordObjectType);
            Logger.saveLog();
        }

        return record;
    }
}