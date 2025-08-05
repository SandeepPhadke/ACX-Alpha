@isTest 
public with sharing class FileNotificationQueueTest {
    
    @isTest 
    private static void itShouldAddFiles(){
        Id groupId = TestUtility.getFakeId(Group.sObjectType);
        
        ace_File__c sharedFile = makeFakeSharedFile();
        
        FileNotificationQueue queue = new FileNotificationQueue();
        
        test.startTest();
        
        queue.addFile(sharedFile, groupId);
        queue.addFile(sharedFile, groupId);
        
        test.stopTest();
        
        System.assertEquals(true, queue.hasItems(), 'expect items in the queue!');
        System.assertEquals(1, queue.notificationQueueItems.keySet().size(), 'only one group, so should be only one queue');
    }
    
    @isTest
    private static void itShouldGetItems(){
        
        Id groupId = TestUtility.getFakeId(Group.sObjectType);
        ace_File__c sharedFile = makeFakeSharedFile();
        
        FileNotificationQueue queue = new FileNotificationQueue();
        FileNotificationQueueEntry entry;
        queue.addFile(sharedFile, groupId);
        queue.addFile(sharedFile, groupId);
        
        test.startTest();
        
        entry = queue.getNextQueueItem();
        
        test.stopTest();
        
        System.assertEquals(true, queue.hasItems(), 'expect items in the queue!');
        System.assertEquals(false, queue.hasMoreItems());
       	System.assert(entry != null, 'expected to get an entry back');
        System.assertEquals(0, queue.queueIndex, 'expected index to be at zero, after a single request');
    }
    
    @isTest
    private static void itShouldClearlyIndicateWhenOutOfItems(){
        Id groupId = TestUtility.getFakeId(Group.sObjectType);
        ace_File__c sharedFile = makeFakeSharedFile();
        
        FileNotificationQueue queue = new FileNotificationQueue();
        queue.addFile(sharedFile, groupId);
        queue.addFile(sharedFile, TestUtility.getFakeId(Group.sObjectType));
        queue.addFile(sharedFile, TestUtility.getFakeId(Group.sObjectType));
        
        
        test.startTest();
		
        for(Integer i = 0; i<4; i++){
            if(queue.hasMoreItems()){
                FileNotificationQueueEntry queueEntry = queue.getNextQueueItem();
            } else {
                continue;
            }
        }
        
        test.stopTest();
        
        System.assertEquals(false, queue.hasMoreItems(), 'expect false!');
        System.assertEquals(2, queue.queueIndex, 'expect index to be on last row');
    }
    
    @isTest
    private static void itShouldReturnTheQueueAsList(){
       
        Id groupId = TestUtility.getFakeId(Group.sObjectType);
        ace_File__c sharedFile = makeFakeSharedFile();
        
        FileNotificationQueue queue = new FileNotificationQueue();
        queue.addFile(sharedFile, groupId);
        queue.addFile(sharedFile, groupId);
        
        List<FileNotificationQueueEntry> queueEntries;
        
        test.startTest();
        
        queueEntries = queue.getQueue();       
        
        test.stopTest();
		
		System.assertEquals(1, queueEntries.size());        
    }
    
    private static ace_File__c makeFakeSharedFile(){
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
        
        Id groupId = TestUtility.getFakeId(Group.sObjectType);
        ace_File__c sharedFile = (ace_File__c)JSON.deserialize(sharedFileString, ace_File__c.class);
        
        return sharedFile;
    }
}