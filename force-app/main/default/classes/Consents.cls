public with sharing class Consents {

    private static final String LINKED_ID_ACCOUNT_TYPE = 'Account';
    private static final String LINKED_ID_CONTACT_TYPE = 'Contact';
    private static final String DEFAULT_CONSENT_STATUS = 'Open';

    @testVisible
    private ConsentsDao dao;

    public Consents() {
        this.dao = new ConsentsDao();
    }

    public List<Consent_Form__c> getConsentFormsForNewUsers(){
        return this.dao.fetchActiveUniversalConsentForms();
    }
    
    public User getCosentRelatedUser(Id userId){
        return this.dao.fetchCosentRelatedUser(userId);
    }
    
    public void saveConsents(List<Consent__c> consents){
        //TODO error handling/try catch logging etc..
        this.dao.insertConsents(consents);
    }

    public Consent__c makeConsentForUser(Id linkedRecordId, User consentUser, Consent_Form__c consentForm){
        Consent__c consent = new Consent__c();
        consent.Name = getConsentName(consentUser, consentForm.Name);
        consent.Consent_Form__c = consentForm.Id;
        consent.Status__c = DEFAULT_CONSENT_STATUS;
        consent.User__c = consentUser.Id;
        consent = linkConsentToSObjectRecord(consent, linkedRecordId);
        
        return consent;
    }

    private Consent__c linkConsentToSObjectRecord(Consent__c consent, Id LinkedRecordId){
        String linkedIdType = linkedRecordId.getSobjectType().toString();

        if(linkedIdType.equals(LINKED_ID_ACCOUNT_TYPE)){
            consent.Individual__c = linkedRecordId;
        }
        if(linkedIdType.equals(LINKED_ID_CONTACT_TYPE)){
            consent.Contact__c = linkedRecordId;
        }

        return consent;
    }

    private String getConsentName(User consentUser, String consentFormName){
        String consentName = consentUser.FirstName+''+consentUser.LastName+''+consentFormName;
        return  (consentUser.FirstName != null ? consentUser.FirstName : '') +
                (consentUser.LastName != null ? consentUser.LastName : '') +
                (consentFormName != null ? consentFormName : '');
    }
}