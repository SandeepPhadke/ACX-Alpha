@isTest
public class MobilitySharingTestDataFactory {
    
    
    @isTest
    private static void makeObjects(){
		String jsonString = new MobilityTestRecordBuilder()
            .withObjectType(Account.SObjectType)
            .build()
            .getObjectString();
        
        System.debug(jsonString);
    }
    
    @isTest
    private static void makeObjectWithChildRecords(){
        Id fakeId = TestUtility.getFakeId(Account.SObjectType);
        List<String> contactStrings = new List<String>();
        for(Integer i = 1; i<2; i++){
            Map<String, String> fields = new Map<String, String>();
            fields.put('FirstName', 'TestContact');
            fields.put('LastName', String.valueOf(i));
            contactStrings.add(new MobilityTestRecordBuilder().withObjectType(Contact.SObjectType).withFields(fields).build().getObjectString());
        }
        System.debug('contact Strings  '+contactStrings);
        String jsonString = new MobilityTestRecordBuilder()
            .withObjectType(Account.SObjectType)
            .withChildRecords('Contacts', contactStrings)
            .build()
            .getObjectString();
        
        System.debug(jsonString);
        Account a = (Account)JSON.deserialize(jsonString, Account.class);
        System.debug(JSON.serialize(a));
    }
    
    @isTest
    private static void makeObjectWithParentRecords(){
        Map<String, String> accountFields = new Map<String, String>();
        accountFields.put('Name','TEST');
        accountFields.put('BillingPostalCode','14221');
        String accountString = new MobilityTestRecordbuilder().withObjectType(Account.SobjectType).withFields(accountFields).build().getObjectString();
        
        Map<String, String> engagementFields = new Map<String, String>();
        engagementFields.put('Engagement_Name_Tag__c', 'TEST ENGAGEMENT');
        String jsonString = new MobilityTestRecordBuilder().withObjectType(Engagement__c.SobjectType).withParentRecords('Client__r', accountString).build().getObjectString();
        System.debug('jsonstring: '+jsonString);
		Engagement__c eng = (Engagement__c)JSON.deserialize(jsonString, Engagement__c.class); 
system.debug(JSON.serialize(eng));        
    }
}