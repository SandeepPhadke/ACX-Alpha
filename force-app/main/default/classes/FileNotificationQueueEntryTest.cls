@isTest 
public with sharing class FileNotificationQueueEntryTest {
    
    @isTest 
    public static void isShouldAddEngagementfiles() {
            String userString = new MobilityTestRecordBuilder()
                .withObjectType(User.sObjectType)
                .withFields(new Map<String, String>{'UserType'=>'Standard'})
                .build()
                .getObjectString();
            String engagementString = new MobilityTestRecordBuilder()
                .withObjectType(Engagement__c.SObjectType)
                .withFields(new Map<String, String>{'Name'=>'Super Engagement'})
                .build()
                .getObjectString();
            String sharedFileString = new MobilityTestRecordBuilder()
                .withObjectType(ace_File__c.sObjectType)
                .withParentRecords('CreatedBy', userString)
                .withParentRecords('Engagement__r', engagementString)
                .withFields(new Map<String, String>{'Engagement__c'=>TestUtility.getFakeId(Engagement__c.sObjectType), 'Work_Record__c'=>null, 'Individual__c'=>null})
                .build()
                .getObjectString();

            ace_File__c sharedFile = (ace_File__c)JSON.deserialize(sharedFileString, ace_File__c.class);

            FileNotificationQueueEntry queueEntry;

        test.startTest();

        queueEntry = new FileNotificationQueueEntry(TestUtility.getFakeId(Group.SObjectType), sharedFile);
        test.stopTest();

        System.assertEquals(1, queueEntry.engagementFiles.keySet().size(), 'expect to see one file here');

    }

    @isTest 
    public static void isShouldAddIndividualfiles() {
    String userString = new MobilityTestRecordBuilder()
                .withObjectType(User.sObjectType)
                .withFields(new Map<String, String>{'UserType'=>'Standard'})
                .build()
                .getObjectString();
            String accountString = new MobilityTestRecordBuilder()
                .withObjectType(Account.SObjectType)
                .withFields(new Map<String, String>{'Name'=>'Super Person'})
                .build()
                .getObjectString();
            String sharedFileString = new MobilityTestRecordBuilder()
                .withObjectType(ace_File__c.sObjectType)
                .withParentRecords('CreatedBy', userString)
                .withParentRecords('Individual__r', accountString)
                .withFields(new Map<String, String>{'Engagement__c'=>null, 'Work_Record__c'=>null, 'Individual__c'=>TestUtility.getFakeId(Account.SObjectType)})
                .build()
                .getObjectString();

            ace_File__c sharedFile = (ace_File__c)JSON.deserialize(sharedFileString, ace_File__c.class);

            FileNotificationQueueEntry queueEntry;

        test.startTest();

        queueEntry = new FileNotificationQueueEntry(TestUtility.getFakeId(Group.SObjectType), sharedFile);
        
        test.stopTest();

        System.assertEquals(1, queueEntry.individualFiles.keySet().size(), 'expect to see one file here');
    }

     @isTest 
    public static void isShouldDoNothing() {
            String userString = new MobilityTestRecordBuilder()
                .withObjectType(User.sObjectType)
                .withFields(new Map<String, String>{'UserType'=>'Standard'})
                .build()
                .getObjectString();
            String engagementString = new MobilityTestRecordBuilder()
                .withObjectType(Engagement__c.SObjectType)
                .withFields(new Map<String, String>{'Name'=>'Super Engagement'})
                .build()
                .getObjectString();
            String sharedFileString = new MobilityTestRecordBuilder()
                .withObjectType(ace_File__c.sObjectType)
                .withParentRecords('CreatedBy', userString)
                .withParentRecords('Engagement__r', engagementString)
                .withFields(new Map<String, String>{'Engagement__c'=>TestUtility.getFakeId(Engagement__c.sObjectType), 'Work_Record__c'=>TestUtility.getFakeId(Work_Record__c.sObjectType), 'Individual__c'=>null})
                .build()
                .getObjectString();

         ace_File__c sharedFile = (ace_File__c)JSON.deserialize(sharedFileString, ace_File__c.class);

        FileNotificationQueueEntry queueEntry;

        test.startTest();

        queueEntry = new FileNotificationQueueEntry(TestUtility.getFakeId(Group.SObjectType), sharedFile);

        test.stopTest();

        System.assertEquals(0, queueEntry.individualFiles.keySet().size(), 'should not map into the individual files bucket');
        System.assertEquals(0, queueEntry.engagementFiles.keySet().size(), 'should not map into the engagement files bucket');
    }
    
}