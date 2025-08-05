public without sharing class ContactUserTableController {
    @AuraEnabled
 public static List<UserWrapper> getTopUsers(Integer numberOfUsers) {
     Id currentAccountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
     List<Work_Record__c> workRecords = [
         SELECT Work_Record_Contact__c, toLabel(Country__c), Type__c
         FROM Work_Record__c
         WHERE Individual__c = :currentAccountId AND Work_Record_Contact__c != null
         AND Status__c = 'Active'
         ORDER BY CreatedDate DESC
     ];
     system.debug('workRecords: ' +workRecords+ 'workRecords.size: ' +workRecords.size());

     List<Id> userIds = new List<Id>();
     Map<String, User> countryOfServiceToUserMap = new Map<String, User>();
     Map<String, String> wrCountryToUserMap = new Map<String, String>();
     Map<Id, String> userIdToRecordTypeMap = new Map<Id, String>();
     Map<Id, String> userIdToCountryMap = new Map<Id, String>();
     List<User> showUser = new List<User>();

     for (Work_Record__c record : workRecords) {
         if (record.Country__c != null && record.Work_Record_Contact__c != null) {
             if(!wrCountryToUserMap.containsKey(record.Country__c)){
                 wrCountryToUserMap.put(record.Country__c, record.Work_Record_Contact__c);
                 system.debug('wrCountryToUserMap' +wrCountryToUserMap);
                 userIds.add(record.Work_Record_Contact__c);
             }
             system.debug('record 1' +record);


             if (record.Type__c != null) {
                 userIdToRecordTypeMap.put(record.Work_Record_Contact__c, record.Type__c);
                 system.debug('record 2' +record);

             }
             userIdToCountryMap.put(record.Work_Record_Contact__c, record.Country__c);
             system.debug('record 3' +record);

         }
         system.debug('record' +record);
     }
     system.debug('wrCountryToUserMap.values() : ' + wrCountryToUserMap.values());

     List<User> usersList = [
         SELECT Id, Name, Email, Phone, FirstName, LastName, Title, TimeZoneSidKey,
         toLabel(Country_of_Service__c), LinkedIn_URL__c, SmallPhotoUrl
         FROM User
         WHERE Id IN :wrCountryToUserMap.values()
     ];
     system.debug('usersList: '+usersList.size()+ '@@@' +usersList);
     for (User user : usersList) {
         showUser.add(user);
         if (showUser.size() == numberOfUsers) {
             break;
         }
     }

     List<UserWrapper> userList = new List<UserWrapper>();
     for (User user : showUser) {
         String formattedLinkedInUrl = formatLinkedInUrl(user.LinkedIn_URL__c);
         String workRecordType = userIdToRecordTypeMap.get(user.Id);
         String workRecordCountry = userIdToCountryMap.get(user.Id);
         String contactHeader;
         if (workRecordType == 'Tax Return') {
             contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeTaxReturnContact;
         } else if (workRecordType == 'Certificate of Coverage') {
             contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeCertificateofCoverageContact;
         } else if (workRecordType == 'Consultation') {
             contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeConsultationContact;
         } else if (workRecordType == 'Other'){
             contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeOtherContact;
         } else {
             contactHeader = '';
         }
         String country = workRecordCountry != null ? workRecordCountry : '';
         contactHeader = contactHeader.replace('{0}', country);
         
         userList.add(new UserWrapper(
             user.Id, user.FirstName + ' ' + user.LastName, user.Email, user.Title,
             user.Phone, country,
             user.TimeZoneSidKey != null ? user.TimeZoneSidKey.replaceAll('_', ' ') : null,
             formattedLinkedInUrl, getPhotoUrl(user.SmallPhotoUrl), workRecordType,contactHeader
         ));
     }
     system.debug('userList: ' +userList+ '$$$' +userList.size());
     return userList;
     
 }
     @AuraEnabled
     public static List<UserWrapper> getEngagementUsers() {
         Id currentUserAccountId;
         try {
             currentUserAccountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
         } catch (Exception e) {
             return new List<UserWrapper>();
         }
         List<UserWrapper> results = new List<UserWrapper>();
         Set<String> userIds = new Set<String>();
         for (Engagement__c engagement : [
             SELECT Global_Relationship_Director_Manager__c, Global_Relationship_Partner__c
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
         if (userIds.isEmpty()) {
             return results;
         }
         for (User u : [
             SELECT Id, FirstName, LastName, Email, Phone, Title, LinkedIn_URL__c, TimeZoneSidKey, SmallPhotoUrl,toLabel(Country_of_Service__c)
             FROM User WHERE Id IN :userIds
         ]) {
             results.add(new UserWrapper(
                 u.Id, u.FirstName + ' ' + u.LastName, u.Email, u.Title, u.Phone, u.Country_of_Service__c,
                 u.TimeZoneSidKey != null ? u.TimeZoneSidKey.replaceAll('_', ' ') : null,
                formatLinkedInUrl(u.LinkedIn_URL__c), getPhotoUrl(u.SmallPhotoUrl), null, null
             ));
         }
         return results;
     }
     @AuraEnabled
     public static List<UserWrapper> getUsers(String userId, Integer numberOfUsers, String workRecordType, String workRecordCountry) {
        // System.debug('Original Contact Header for getUsers: ' + contactHeader);
         System.debug('Input Work Record Country: ' + workRecordCountry);
     
         System.debug('getUsers Initiate1');
         System.debug('Input UserId: ' + userId);
         System.debug('Work Record Type: ' + workRecordType);
         System.debug('getUsers Initiate2');
     
         List<UserWrapper> results = new List<UserWrapper>();
         List<User> users = [
             SELECT Id, FirstName, LastName, Email, Phone, Title, LinkedIn_URL__c, TimeZoneSidKey,
             SmallPhotoUrl, toLabel(Country_of_Service__c)
             FROM User WHERE Id = :userId
         ];
     
         System.debug('getUsers Initiate3');
         System.debug('Fetched Users Count: ' + users.size());
     
         for (User u : users) {
             String contactHeader;
             if (workRecordType == 'Tax Return') {
                 contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeTaxReturnContact;
             } else if (workRecordType == 'Certificate of Coverage') {
                 contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeCertificateofCoverageContact;
             } else if (workRecordType == 'Consultation') {
                 contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeConsultationContact;
             } else if (workRecordType == 'Other') {
                 contactHeader = System.Label.ace_contactUserTabelLWC_AssigneeOtherContact;
             } else {
                 contactHeader = '';
             }
     
             // Ensure workRecordCountry is not null
             String country = String.isNotBlank(workRecordCountry) ? workRecordCountry : '';
     
             if (String.isNotBlank(contactHeader)) {
                 contactHeader = contactHeader.replace('{0}', country);
             }
     
             System.debug('Generated Contact Header: ' + contactHeader);
     
             results.add(new UserWrapper(
                 u.Id, u.FirstName + ' ' + u.LastName, u.Email, u.Title, u.Phone, country,
                 u.TimeZoneSidKey != null ? u.TimeZoneSidKey.replaceAll('_', ' ') : null,
                 formatLinkedInUrl(u.LinkedIn_URL__c), getPhotoUrl(u.SmallPhotoUrl), workRecordType, contactHeader
             ));
         }
     
         System.debug('Final UserWrapper List: ' + JSON.serialize(results));
         return results;
     }

     private static String formatLinkedInUrl(String linkedInUrl) {
         if (String.isNotBlank(linkedInUrl) && !linkedInUrl.startsWithIgnoreCase('http')) {
             linkedInUrl = 'https://' + linkedInUrl;
         }
         return linkedInUrl;
     }
     private static String getPhotoUrl(String photoUrl) {
         if (String.isNotBlank(photoUrl) && photoUrl.contains('/005/')) {
             String labelValue = System.Label.ace_contactUserTabelLWC_AssigneeContentAsset;
             ContentAsset logoAsset = [SELECT Id, ContentDocumentId FROM ContentAsset WHERE DeveloperName = :labelValue LIMIT 1];
             if (logoAsset != null) {
                 return '/file-asset-public/' + logoAsset.Id + '?oid=' + UserInfo.getOrganizationId();
             } else {
                 return photoUrl;
             }
         }
         return photoUrl;
     }
     public class UserWrapper {
         @AuraEnabled public String Id;
         @AuraEnabled public String Name;
         @AuraEnabled public String Email;
         @AuraEnabled public String Title;
         @AuraEnabled public String Phone;
         @AuraEnabled public String Country;
         @AuraEnabled public String TimeZone;
         @AuraEnabled public String LinkedinUrl;
         @AuraEnabled public String ProfilePhoto;
         @AuraEnabled public String WorkRecordType;
         @AuraEnabled public String ContactHeader;
         
         public UserWrapper(String Id, String Name, String Email, String Title, String Phone,
                            String Country, String TimeZone, String LinkedinUrl, String ProfilePhoto,
                            String WorkRecordType, String ContactHeader) {
             this.Id = Id;
             this.Name = Name;
             this.Email = Email;
             this.Title = Title;
             this.Phone = Phone;
             this.Country = Country;
             this.TimeZone = TimeZone;
             this.LinkedinUrl = LinkedinUrl;
             this.ProfilePhoto = ProfilePhoto;
             this.WorkRecordType = WorkRecordType;
             this.ContactHeader = ContactHeader;
            
         }
     }
 }