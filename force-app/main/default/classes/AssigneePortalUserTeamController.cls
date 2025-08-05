public without sharing class AssigneePortalUserTeamController {
    @AuraEnabled
    public static List<UserWrapper> getTopUsers(Integer numberOfUsers) {
        Id currentAccountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
        System.debug('number : ' + numberOfUsers);
        
        System.debug(
            'Current Account ID: ' +
            currentAccountId);
        // Fetch user details
        List<Work_Record__c> workRecords =[
            SELECT Work_Record_Contact__c, Country__c
            FROM Work_Record__c
            WHERE Individual__c = :currentAccountId AND Work_Record_Contact__c != null 
            AND Status__c = 'Active' ORDER BY CreatedDate DESC
        ];

        List<Id> userIds = new List<Id>();
        Map<String, User> countryToUserMap = new Map<String, User>();
        for (Work_Record__c record : workRecords) {
            if (record.Country__c != null && record.Work_Record_Contact__c != null) {
                userIds.add(record.Work_Record_Contact__c);
                /*if (!countryToUserMap.containsKey(record.Country__c)) {
                    User user = [
                        SELECT Id, Name, Email, Phone, FirstName, LastName, Title, TimeZoneSidKey , Country_of_Service__c, Linkedin_URL__c
                        FROM User 
                        WHERE Id = :record.Work_Record_Contact__c 
                        LIMIT 1
                    ];
                    //if (user.Country == record.Country__c) {
                        countryToUserMap.put(record.Country__c, user);                    //}
                }*/
            }            
        }

        List<User> usersList = [
                        SELECT Id, Name, Email, Phone, FirstName, LastName, Title, TimeZoneSidKey , Country_of_Service__c, Linkedin_URL__c
                        FROM User 
                        WHERE Id IN :userIds
                    ];
        
        Map<String, User> countryOfServiceToUserMap = new Map<String, User>();
        
        for (User user : usersList) {
            if (!countryOfServiceToUserMap.containsKey(user.Country_of_Service__c)) {
                countryOfServiceToUserMap.put(user.Country_of_Service__c, user);
            }
            if(countryToUserMap.keySet().size() == numberOfUsers){
                break;
            }
        }
            
        System.debug('UserIds : ' + userIds);
        List<UserWrapper> userList = new List<UserWrapper>();
        for (User user : countryOfServiceToUserMap.values()) {
            String formattedLinkedInUrl = formatLinkedInUrl(user.LinkedIn_URL__c);
            userList.add(new UserWrapper(
                user.Id,
                user.Name,
                user.Email,
                user.Title,
                user.Phone,
                user.FirstName,
                user.LastName,
                user.Country_of_Service__c,
                user.TimeZoneSidKey != null ? user.TimeZoneSidKey.replaceAll('_', ' ') : null,
                formattedLinkedInUrl
            ));
        }

        System.debug(
            'User Data: ' +
            userList);

        return userList;
    }

    private static String formatLinkedInUrl(String linkedInUrl) {
        if (String.isNotBlank(linkedInUrl)) {
            // Check if URL starts with 'http' or 'https'
            if (!linkedInUrl.startsWithIgnoreCase('http')) {
                linkedInUrl = 'https://' + linkedInUrl;
            }
        }
        return linkedInUrl;
    }
	
    public class UserWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Email;
        @AuraEnabled public String Title;
        @AuraEnabled public String Phone;
        @AuraEnabled public String TimeZone;
        @AuraEnabled public String Country;
        @AuraEnabled public String LinkedinUrl;

        public UserWrapper(String Id, String Name, String Email, String Title, String Phone, String FirstName, String LastName, String Country, String TimeZone, String LinkedinUrl) {
            this.Id = Id;
            this.Name = FirstName + ' ' + LastName;
            this.Email = Email;
            this.Title = Title;
            this.Phone = Phone;
            this.TimeZone = TimeZone;
            this.Country = Country;
            this.LinkedinUrl = LinkedinUrl;
        }
    }
}