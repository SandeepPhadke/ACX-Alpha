public without sharing class GlobalMobileUserMapController {
    
    private static Id getCurrentUserAccountId() {
        Id userId = UserInfo.getUserId();
        User currentUser = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1];
        
        if (currentUser.ContactId != null) {
            List<Contact> userAccount = [
                SELECT AccountId 
                FROM Contact 
                WHERE Id = :currentUser.ContactId 
                LIMIT 1
            ];
            return !userAccount.isEmpty() ? userAccount[0].AccountId : null;
        }
        return null;
    }

    private static Map<String, String> getCountryPicklistLabels() {
        Map<String, String> picklistLabels = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Engagement_Assignee__c.Assignment_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry entry : ple) {
            picklistLabels.put(entry.getValue(), entry.getLabel());
        }
        return picklistLabels;
    }
    
    @AuraEnabled(cacheable=true)
    public static GeoJSONWrapper getUserLocations() {
        Id accountId = getCurrentUserAccountId();
        if (accountId == null) {
            return new GeoJSONWrapper(new List<FeatureWrapper>());
        }

        Map<String, Integer> countryCount = new Map<String, Integer>();
        Map<String, String> countryLabels = getCountryPicklistLabels();
        
        for(Engagement_Assignee__c assignee : [
            SELECT Assignment_Country__c 
            FROM Engagement_Assignee__c 
            WHERE Assignment_Country__c != null
            AND Engagements__r.Client__c = :accountId
        ]) {
            String countryCode = assignee.Assignment_Country__c;
            countryCount.put(
                countryCode, 
                countryCount.containsKey(countryCode) ? countryCount.get(countryCode) + 1 : 1
            );
        }
        
        List<FeatureWrapper> features = new List<FeatureWrapper>();
        for(String countryCode : countryCount.keySet()) {
            String countryLabel = countryLabels.get(countryCode) ?? countryCode;
            features.add(new FeatureWrapper(
                countryCode,  // Use the ISO code directly
                countryLabel,
                countryCount.get(countryCode)
            ));
        }
        
        return new GeoJSONWrapper(features);
    }
    
    public class GeoJSONWrapper {
        @AuraEnabled public String type;
        @AuraEnabled public List<FeatureWrapper> features;
        
        public GeoJSONWrapper(List<FeatureWrapper> features) {
            this.type = 'FeatureCollection';
            this.features = features;
        }
    }
    
    public class FeatureWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public PropertiesWrapper properties;
        
        public FeatureWrapper(String id, String name, Integer count) {
            this.id = id;
            this.properties = new PropertiesWrapper(name, count);
        }
    }
    
    public class PropertiesWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Integer count;
        
        public PropertiesWrapper(String name, Integer count) {
            this.name = name;
            this.count = count;
        }
    }
}