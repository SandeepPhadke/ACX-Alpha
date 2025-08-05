public with sharing class ConsentsDao {
    
    public void insertConsents(List<Consent__c> consents){
        insert consents;
    }

    public List<Consent_Form__c> fetchActiveUniversalConsentForms(){
        return [SELECT Id, Name FROM Consent_Form__C WHERE Status__c= 'Active' and Applicable_To_All__c = true];
    }
    
    public User fetchCosentRelatedUser(Id userId){
        return [SELECT Id, FirstName, LastName FROM User WHERE Id =: userId LIMIT 1];
    }
    
}