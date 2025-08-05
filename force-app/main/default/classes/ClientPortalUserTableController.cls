public without sharing class ClientPortalUserTableController {
    @AuraEnabled(cacheable=true)
    public static List<UserWrapper> getEngagementUsers() {
        Id currentUserAccountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
        System.debug('Current User Account ID: ' + currentUserAccountId);

        List<UserWrapper> results = new List<UserWrapper>();
        List<String> userIds = new List<String>();

        for (Engagement__c engagement : [
            SELECT Id, Global_Relationship_Director_Manager__c, Global_Relationship_Partner__c
            FROM Engagement__c
            WHERE Client__c = :currentUserAccountId
        ]) {
            if (engagement.Global_Relationship_Director_Manager__c != null) {
                userIds.add(engagement.Global_Relationship_Director_Manager__c);
            }
            if (engagement.Global_Relationship_Partner__c != null) {
                userIds.add(engagement.Global_Relationship_Partner__c);
            }
        }

        System.debug('User IDs from Engagements: ' + userIds);

        for (User u : [
            SELECT Id, Name, FirstName, LastName, Email, Phone, Title, LinkedIn_URL__c, TimeZoneSidKey
            FROM User WHERE Id IN :userIds
        ]) {
            String formattedLinkedInUrl = formatLinkedInUrl(u.LinkedIn_URL__c);
            results.add(new UserWrapper(
                u.Id, u.Name, u.TimeZoneSidKey != null ? u.TimeZoneSidKey.replaceAll('_', ' ') : null, u.Email, 
                u.FirstName, u.LastName, u.Phone, u.Title, formattedLinkedInUrl
            ));
        }

        System.debug('User Data: ' + results);
        return results;
    }

    private static String formatLinkedInUrl(String linkedInUrl) {
        if (String.isNotBlank(linkedInUrl)) {
            if (!linkedInUrl.startsWithIgnoreCase('http')) {
                linkedInUrl = 'https://' + linkedInUrl;
            }
        }
        return linkedInUrl;
    }

    public class UserWrapper {
        @AuraEnabled public String userId;
        @AuraEnabled public String Name;
        @AuraEnabled public String TimeZone;
        @AuraEnabled public String Email;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String Phone;
        @AuraEnabled public String Title;
        @AuraEnabled public String LinkedIn_URL;

        public UserWrapper(
            String userId, String Name, String TimeZone, String Email,
            String FirstName, String LastName, String Phone, String Title, String LinkedIn_URL
        ) {
            this.userId = userId;
            this.Name = FirstName + ' ' + LastName;
            this.TimeZone = TimeZone;
            this.Email = Email;
            this.FirstName = FirstName;
            this.LastName = LastName;
            this.Phone = Phone;
            this.Title = Title;
            this.LinkedIn_URL = LinkedIn_URL;
        }
    }
}