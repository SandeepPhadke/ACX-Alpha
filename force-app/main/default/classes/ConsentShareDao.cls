public without sharing class ConsentShareDao {

    public Map<Id, Account> fetchAccountsWithUser(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return new Map<Id, Account>();
        return new Map<Id, Account>(
            [SELECT Id, User__pc FROM Account WHERE Id IN :accountIds]
        );
    }

    public Map<Id, Contact> fetchContactsWithUser(Set<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) return new Map<Id, Contact>();
        return new Map<Id, Contact>(
            [SELECT Id, User__c FROM Contact WHERE Id IN :contactIds]
        );
    }

    public List<Consent__c> fetchConsentsForAccounts(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return new List<Consent__c>();
        return [
            SELECT Id, Individual__c
            FROM Consent__c
            WHERE Individual__c IN :accountIds
        ];
    }

    public List<Consent__c> fetchConsentsForContacts(Set<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) return new List<Consent__c>();
        return [
            SELECT Id, Contact__c
            FROM Consent__c
            WHERE Contact__c IN :contactIds
        ];
    }
    
    public void insertConsentShares(List<Consent__Share> consentShares) {
        if (consentShares == null || consentShares.isEmpty()) return;
        try {
            insert consentShares;
        } catch (DmlException e) {
            System.debug('ConsentShareDao: Error inserting Consent__Share records: ' + e.getMessage());
            throw e;
        }
    }
}