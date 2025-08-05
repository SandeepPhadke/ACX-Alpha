public with sharing class AsyncUserSetupQueueItem {
   
        @AuraEnabled @InvocableVariable(label='User Record' required=true)
        public User userRecord;
        @AuraEnabled @InvocableVariable(label='User Id'  required=true)
        public Id userId;
        @AuraEnabled @InvocableVariable(label='Contact Id' description='only include if the user is NOT a person account. Either Contact Id or Account Id must be included or it will fail.' required=false)
        public Id contactId;
        @AuraEnabled @InvocableVariable(label='Account Id' description='only include if the user IS a person account. Either Contact Id or Account Id must be included or it will fail.' required=false)
        public Id accountId;
        @AuraEnabled @InvocableVariable(label='Executing User Id' required=true)
        public Id executingUserId;
 
        public AsyncUserSetupQueueItem(){}
        public Id getLinkedRecordId(){
                Id linkedRecordId = this.accountId != null ? this.accountId : this.contactId;

                return linkedRecordId;
        }

        public Boolean isValid(){
                return this.userRecord != null && this.userId != null && (this.accountId !=null ^ this.contactId != null);
        }
}