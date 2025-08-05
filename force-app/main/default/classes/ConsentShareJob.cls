public without sharing class ConsentShareJob implements Queueable {
    
    @testVisible
    private List<Id> linkedRecordIds;
    
    @testVisible
    private String accessLevel;
    
    @testVisible
    private Consent_Share consentShare;
    
    public ConsentShareJob(List<Id> linkedRecordIds, String accessLevel) {
        this.linkedRecordIds = linkedRecordIds;
        this.accessLevel = accessLevel;
        this.consentShare = new Consent_Share(linkedRecordIds, accessLevel);
    }
    
    public void execute(QueueableContext qc) {
        if (linkedRecordIds == null || linkedRecordIds.isEmpty()) return;
        
        Savepoint sp = Database.setSavepoint();
        try {
            createConsentShares();
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('ConsentShareJob: Error processing consent shares: ' + e.getMessage());
            
        }
    }
    
    private void createConsentShares() {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for (Id recId : linkedRecordIds) {
            if (recId.getSObjectType() == Account.SObjectType) {
                accountIds.add(recId);
            } else if (recId.getSObjectType() == Contact.SObjectType) {
                contactIds.add(recId);
            }
        }
        
        List<Consent__Share> sharesToInsert = new List<Consent__Share>();
        
        if (!accountIds.isEmpty()) {
            sharesToInsert.addAll(consentShare.createSharesForAccounts(accountIds, accessLevel));
        }
        
        if (!contactIds.isEmpty()) {
            sharesToInsert.addAll(consentShare.createSharesForContacts(contactIds, accessLevel));
        }
        
        if (!sharesToInsert.isEmpty()) {
            consentShare.saveConsentShares(sharesToInsert);
        }
    }
}