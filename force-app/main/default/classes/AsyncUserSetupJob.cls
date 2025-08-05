public with sharing class AsyncUserSetupJob implements Queueable {
  
    @testVisible
    private List<AsyncUserSetupQueueItem> queueItems;

    @testVisible
    private Consents consents;

    @testVisible
    private Users userBso;
    //@testVisible
    
    public AsyncUserSetupJob(List<AsyncUserSetupQueueItem> queueItems) {
        this.consents = new Consents();
        this.userBso = new Users();
        this.queueItems = queueItems;
    }

    //TODO: this seems like an atomic process, so maybe put a try/catch or savepoints around this in the event that it fails.
    //TODO: when this fails asynchronously, it might be good to notify someone proactively..  maybe call send better email? We don't know the running user but could do that..

    public void execute(QueueableContext qc){
        if(this.queueItems.isEmpty()) return;
     
        setUserLookupsOnRelatedRecords();
        createConsentsForNewUsers();
        enqueueUserActivation();

    }

    private void setUserLookupsOnRelatedRecords(){
        Map<Id, Id> userIdsByRelatedEntityId = new Map<Id, Id>();
        
        for(AsyncUserSetupQueueItem item : this.queueItems){
            
            Id relatedEntityId = item.getLinkedRecordId();
            Id userId = item.userId;
        
            userIdsByRelatedEntityId.put(relatedEntityId, userId);
        }

        this.userBso.establishRelationshipBetweenEntitiesAndUsers(userIdsByRelatedEntityId);
    }

    //maybe this could also be delegated?   is Consents responsible for the queue items or just the creation/retrieval logic..  what is easier for someone to understand?
    private void createConsentsForNewUsers(){
        List<Consent__c> newConsents = new List<Consent__c>();

        List<Consent_Form__c> consentForms = this.consents.getConsentFormsForNewUsers();
        
		User userRecord = this.consents.getCosentRelatedUser(this.queueItems[0].userId);
        
        for(AsyncUserSetupQueueItem item : this.queueItems){
            Id linkedRecordId = item.getLinkedRecordId(); 

            for(Consent_Form__c form : consentForms){
                newConsents.add(this.consents.makeConsentForUser(linkedRecordId, userRecord, form));
            }
        }

        this.consents.saveConsents(newConsents);
     
    }

    private void enqueueUserActivation(){
        List<User> newUsers = new List<User>();
        for(AsyncUserSetupQueueItem item : this.queueItems){
            newUsers.add(item.userRecord);
        }

        enqueueUserActivationJob(newUsers, queueItems);
    }

    private void enqueueUserActivationJob(List<User> users , List<AsyncUserSetupQueueItem> queueItems){
        AsyncUserActivationJob job = new AsyncUserActivationJob(users , queueItems);

        Id jobId = Test.isRunningTest() ? null : System.enqueueJob(job);
    }

}