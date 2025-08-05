@isTest 
public with sharing class SubscribedOfficeFromCountryActionTest {
    
    @isTest
    private static void itShouldReturnTheResult(){
        Id expected = TestUtility.getFakeId(Subscribed_Offices__c.SObjectType);
        
        String contactString = new MobilityTestRecordBuilder()
            .withObjectType(Contact.SobjectType)
            .build()
            .getObjectString();
        
        String accountString = new MobilityTestRecordBuilder()
            .withObjectType(Account.SObjectType)
            .withChildRecords('Contacts', new List<String>{contactString})
            .build()
            .getObjectString();
        
        String usOfficeString = new MobilityTestRecordBuilder()
            .withObjectType(Subscribed_Offices__c.sObjectType)
            .withRecordId(expected)
            .withParentRecords('Account__r', accountString)
            .withFields(new Map<String, String>{'Country__c'=>'AMERICA'})
            .build()
            .getObjectString();        
        
        String frOfficeString = new MobilityTestRecordBuilder()
            .withObjectType(Subscribed_Offices__c.sObjectType)
            .withRecordId(TestUtility.getFakeId(Subscribed_Offices__c.SObjectType))
            .withFields(new Map<String, String>{'Country__c'=>'FRANCE'})
            .build()
            .getObjectString();        
        
        
        List<Subscribed_Offices__c> offices = new List<Subscribed_Offices__c>(); 
        offices.add((Subscribed_Offices__c)JSON.deserialize(usOfficeString, Subscribed_Offices__c.class));
        offices.add((Subscribed_Offices__c)JSON.deserialize(frOfficeString, Subscribed_Offices__c.class));    
        
        Id actual;
        
        SubscribedOfficeFromCountryAction.Request req = new SubscribedOfficeFromCountryAction.Request();
        req.offices = offices;
        req.countryName = 'AMERICA';
        
        test.startTest();
        List<SubscribedOfficeFromCountryAction.Response> responses  = SubscribedOfficeFromCountryAction.SubscribedOfficeFromCountryAction(new List<SubscribedOfficeFromCountryAction.Request>{req});
        test.stopTest();
        
        System.assertEquals(1, responses.size(), 'expect one response');
        actual  = responses[0].subscribedOfficeId;
        System.assertEquals(expected, actual, 'expect the right ID to be returned');
    }
    
    @isTest
    private static void itShouldReturnNullWhenNoResult(){
        Id expected = null;
        
        String usOfficeString = new MobilityTestRecordBuilder()
            .withObjectType(Subscribed_Offices__c.sObjectType)
            .withRecordId(expected)
            .withFields(new Map<String, String>{'Country__c'=>'AMERICA'})
            .build()
            .getObjectString();        
        
        String frOfficeString = new MobilityTestRecordBuilder()
            .withObjectType(Subscribed_Offices__c.sObjectType)
            .withRecordId(TestUtility.getFakeId(Subscribed_Offices__c.SObjectType))
            .withFields(new Map<String, String>{'Country__c'=>'FRANCE'})
            .build()
            .getObjectString();        
        
        
        List<Subscribed_Offices__c> offices = new List<Subscribed_Offices__c>(); 
        offices.add((Subscribed_Offices__c)JSON.deserialize(usOfficeString, Subscribed_Offices__c.class));
        offices.add((Subscribed_Offices__c)JSON.deserialize(frOfficeString, Subscribed_Offices__c.class));    
        
        Id actual;
        
        SubscribedOfficeFromCountryAction.Request req = new SubscribedOfficeFromCountryAction.Request();
        req.offices = offices;
        req.countryName = 'AUSTRALIA';
        
        test.startTest();
        List<SubscribedOfficeFromCountryAction.Response> responses  = SubscribedOfficeFromCountryAction.SubscribedOfficeFromCountryAction(new List<SubscribedOfficeFromCountryAction.Request>{req});
        test.stopTest();
        
        System.assertEquals(1, responses.size(), 'expect one response');
        actual  = responses[0].subscribedOfficeId;
        System.assertEquals(expected, actual, 'expected a null result');
    }
}