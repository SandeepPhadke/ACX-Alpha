public without sharing class Consent_Share {
    
    private static final String ROW_CAUSE = 'ConsentSigner__c';
    
    @testVisible
    private List<Id> linkedRecordIds;
    
    @testVisible
    private String accessLevel;
    
    @testVisible
    private ConsentShareDao dao;
    
    public Consent_Share(List<Id> linkedRecordIds, String accessLevel) {
        this.linkedRecordIds = linkedRecordIds;
        this.accessLevel = accessLevel;
        this.dao = new ConsentShareDao();
    }
    
    public List<Consent__Share> createSharesForAccounts(Set<Id> accountIds, String accessLevel) {
        List<Consent__Share> shares = new List<Consent__Share>();
        
        Map<Id, Account> accountsWithUser = dao.fetchAccountsWithUser(accountIds);
        List<Consent__c> accountConsents = dao.fetchConsentsForAccounts(accountIds);
        
        for (Consent__c consent : accountConsents) {
            Account acc = accountsWithUser.get(consent.Individual__c);
            if (acc != null && acc.User__pc != null) {
                shares.add(createConsentShare(consent.Id, acc.User__pc, accessLevel));
            }
        }
        
        return shares;
    }
    
    public List<Consent__Share> createSharesForContacts(Set<Id> contactIds, String accessLevel) {
        List<Consent__Share> shares = new List<Consent__Share>();
        
        Map<Id, Contact> contactsWithUser = dao.fetchContactsWithUser(contactIds);
        List<Consent__c> contactConsents = dao.fetchConsentsForContacts(contactIds);
        
        for (Consent__c consent : contactConsents) {
            Contact con = contactsWithUser.get(consent.Contact__c);
            if (con != null && con.User__c != null) {
                shares.add(createConsentShare(consent.Id, con.User__c, accessLevel));
            }
        }
        
        return shares;
    }
    
    public void saveConsentShares(List<Consent__Share> consentShares) {
        try {
            dao.insertConsentShares(consentShares);
        } catch (DmlException e) {
            System.debug('Consent_Share: Error inserting Consent__Share records: ' + e.getMessage());
            throw e;
        }
    }
    
    @testVisible
    private Consent__Share createConsentShare(Id parentId, Id userOrGroupId, String accessLevel) {
        Consent__Share share = new Consent__Share();
        share.ParentId = parentId;
        share.UserOrGroupId = userOrGroupId;
        share.AccessLevel = accessLevel;
        share.RowCause = ROW_CAUSE;
        return share;
    }
}