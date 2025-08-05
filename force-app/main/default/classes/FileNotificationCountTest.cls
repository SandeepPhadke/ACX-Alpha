@isTest 
public with sharing class FileNotificationCountTest {
    
    @isTest 
    private static void itShouldSetTheRightUserTypes(){
        List<String> userTypes = new List<String>{'Standard', 'Power CustomerSuccess', 'Standard', 'CustomerSuccess', 'Partner'};
        List<ace_File__c> sharedFiles = new List<ace_File__c>();
        for(String userType : userTypes){
            String userString = new MobilityTestRecordBuilder()
            .withObjectType(User.sObjectType)
            .withFields(new Map<String, String>{'UserType'=>userType})
            .build()
            .getObjectString();
            String sharedFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.sObjectType)
            .withParentRecords('CreatedBy', userString)
            .build()
            .getObjectString();
            ace_File__c sharedFile = (ace_File__c)JSON.deserialize(sharedFileString, ace_File__c.class);

            sharedFiles.add(sharedFile);
        }

        FileNotificationCount count = new FileNotificationCount();

        test.startTest();
        for(ace_File__c file : sharedFiles){
            count.addFile(file);
        }

        test.stopTest();
        
        System.assertEquals(2, count.internallyAdded, 'expect 2');
        System.assertEquals(2, count.externallyAdded, 'expect 2');
    }
}