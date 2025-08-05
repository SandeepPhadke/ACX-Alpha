public without sharing class AssigneePortalTaxConsultantController {
    @AuraEnabled
    public static List<UserWrapper> getTopUsers(String informationRequestId) {
        List<Information_Request__c> infoRequests = [
            SELECT Id, 
                   Work_Record__r.Work_Record_Contact_Email__c, 
                   Work_Record__r.Work_Record_Contact_Phone__c, 
                   Work_Record__r.Work_Record_Contact_Name__c 
            FROM Information_Request__c 
            WHERE Id = :informationRequestId
        ];
        
        List<UserWrapper> userList = new List<UserWrapper>();
        
        for (Information_Request__c record : infoRequests) {
            userList.add(new UserWrapper(
                record.Work_Record__r.Work_Record_Contact_Name__c,
                record.Work_Record__r.Work_Record_Contact_Email__c,
                record.Work_Record__r.Work_Record_Contact_Phone__c
            ));
        }

        return userList;
    }

    public class UserWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String Email;
        @AuraEnabled public String Phone;

        public UserWrapper(String Name, String Email, String Phone) {
            this.Name = Name;
            this.Email = Email;
            this.Phone = Phone;
        }
    }

}