@isTest 
public with sharing class FileNotificationAlertComposerTest {

    @isTest 
    private static void itShouldComposeTheEmailMessageWithEngagementsAndIndividuals(){

        Account individualAccount = new Account(Name='Person');
        String engagementString = new MobilityTestRecordBuilder()
                                        .withObjectType(Engagement__c.SObjectType)
                                        .withFields(new Map<String, String>{'Name'=>'Test'})
                                        .build()
                                        .getObjectString();

        String individualAccountString = JSON.serialize(individualAccount);
        String internalUserString = new MobilityTestRecordBuilder()
            .withObjectType(User.sObjectType)
            .withFields(new Map<String, String>{'UserType'=>'Standard'})
            .build()
            .getObjectString();
        String externalUserString = new MobilityTestRecordBuilder()
            .withObjectType(User.sObjectType)
            .withFields(new Map<String, String>{'UserType'=>'CustomerSuccess'})
            .build()
            .getObjectString();
        String internallyCreatedEngagementFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.SObjectType)
            .withFields(new Map<String, String>{'Work_Record__c'=>null, 'Individual__c'=>null, 'Engagement__c'=>TestUtility.getFakeId(Engagement__c.SObjectType)})
            .withParentRecords('Engagement__r', engagementString)
            .withParentRecords('CreatedBy', internalUserString)
            .build()
            .getObjectString();
        String externallyCreatedEngagementFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.SObjectType)
            .withParentRecords('Engagement__r', engagementString)
            .withFields(new Map<String, String>{'Work_Record__c'=>null, 'Individual__c'=>null, 'Engagement__c'=>TestUtility.getFakeId(Engagement__c.SObjectType)})
            .withParentRecords('CreatedBy', externalUserString)
            .build()
            .getObjectString();
        String externallyCreatedIndividualFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.SObjectType).withParentRecords('Individual__r', individualAccountString).withParentRecords('CreatedBy', externalUserString)
            .withFields(new Map<String, String>{'Work_Record__c'=>null, 'Individual__c'=>TestUtility.getFakeId(Account.SObjectType), 'Engagement__c'=>null})
            .build()
            .getObjectString();

        FileNotificationQueueEntry queueEntry = new FileNotificationQueueEntry(TestUtility.getFakeId(Group.SObjectType),(ace_File__c)JSON.deserialize(internallyCreatedEngagementFileString, ace_File__c.class));
        queueEntry.addFile((ace_File__c)JSON.deserialize(internallyCreatedEngagementFileString, ace_File__c.class));
        queueEntry.addFile((ace_File__c)JSON.deserialize(externallyCreatedEngagementFileString, ace_File__c.class));       
        queueEntry.addFile((ace_File__c)JSON.deserialize(externallyCreatedIndividualFileString, ace_File__c.class));
        queueEntry.addFile((ace_File__c)JSON.deserialize(externallyCreatedIndividualFileString, ace_File__c.class));
        queueEntry.addFile((ace_File__c)JSON.deserialize(externallyCreatedIndividualFileString, ace_File__c.class));
        
        System.debug(JSON.serialize(queueEntry));
        
        FileNotificationAlertComposer composer = new FileNotificationAlertComposer();
        String resultMessage;

        test.startTest();

        resultMessage = composer.getAlertMessage(queueEntry, 10);

        test.stopTest();


        System.assert(resultMessage.contains(FileNotificationAlertComposer.ALERT_INTRO));
        System.assert(resultMessage.contains(FileNotificationAlertComposer.ENGAGEMENT_HEADER));
        System.assert(resultMessage.contains(FileNotificationAlertComposer.INDIVIDUAL_HEADER));
        System.assert(resultMessage.contains(FileNotificationAlertComposer.ENGAGEMENT_FILES_INTERNAL));
        System.assert(resultMessage.contains(FileNotificationAlertComposer.ENGAGEMENT_FILES_EXTERNAL));
        System.assert(resultMessage.contains(FileNotificationAlertComposer.INDIVIDUAL_FILES_EXTERNAL));
        System.assert(resultMessage.contains(FileNotificationAlertComposer.INDIVIDUAL_FILES_INTERNAL));
    }

    @isTest 
    private static void itShouldNotIncludeIndividualHeaders(){
        String engagementString = new MobilityTestRecordBuilder()
                                        .withObjectType(Engagement__c.SObjectType)
                                        .withFields(new Map<String, String>{'Name'=>'Test'})
                                        .build()
                                        .getObjectString();

        String internalUserString = new MobilityTestRecordBuilder()
            .withObjectType(User.sObjectType)
            .withFields(new Map<String, String>{'UserType'=>'Standard'})
            .build()
            .getObjectString();
        String externalUserString = new MobilityTestRecordBuilder()
            .withObjectType(User.sObjectType)
            .withFields(new Map<String, String>{'UserType'=>'CustomerSuccess'})
            .build()
            .getObjectString();
        String internallyCreatedEngagementFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.SObjectType)
            .withFields(new Map<String, String>{'Work_Record__c'=>null, 'Individual__c'=>null, 'Engagement__c'=>TestUtility.getFakeId(Engagement__c.SObjectType)})
            .withParentRecords('Engagement__r', engagementString)
            .withParentRecords('CreatedBy', internalUserString)
            .build()
            .getObjectString();
        String externallyCreatedEngagementFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.SObjectType)
            .withParentRecords('Engagement__r', engagementString)
            .withFields(new Map<String, String>{'Work_Record__c'=>null, 'Individual__c'=>null, 'Engagement__c'=>TestUtility.getFakeId(Engagement__c.SObjectType)})
            .withParentRecords('CreatedBy', externalUserString)
            .build()
            .getObjectString();
       
        FileNotificationQueueEntry queueEntry = new FileNotificationQueueEntry(TestUtility.getFakeId(Group.SObjectType),(ace_File__c)JSON.deserialize(internallyCreatedEngagementFileString, ace_File__c.class));
        queueEntry.addFile((ace_File__c)JSON.deserialize(internallyCreatedEngagementFileString, ace_File__c.class));
        queueEntry.addFile((ace_File__c)JSON.deserialize(externallyCreatedEngagementFileString, ace_File__c.class));       
        
        System.debug(JSON.serialize(queueEntry));
        
        FileNotificationAlertComposer composer = new FileNotificationAlertComposer();
        String resultMessage;

        test.startTest();

        resultMessage = composer.getAlertMessage(queueEntry, 10);

        test.stopTest();

		System.debug('THE MESSAGE: '+resultMessage);
        
        System.assert(resultMessage.contains(FileNotificationAlertComposer.ALERT_INTRO), 'expect the result to contain '+FileNotificationAlertComposer.ALERT_INTRO);
        System.assert(resultMessage.contains(FileNotificationAlertComposer.ENGAGEMENT_HEADER), 'expect the result to contain '+FileNotificationAlertComposer.ENGAGEMENT_HEADER);
        System.assert(!resultMessage.contains(FileNotificationAlertComposer.INDIVIDUAL_HEADER), 'expect the result to NOT contain '+FileNotificationAlertComposer.INDIVIDUAL_HEADER);
        System.assert(resultMessage.contains(FileNotificationAlertComposer.ENGAGEMENT_FILES_INTERNAL),'expect the result to contain '+FileNotificationAlertComposer.ENGAGEMENT_FILES_INTERNAL);
        System.assert(resultMessage.contains(FileNotificationAlertComposer.ENGAGEMENT_FILES_EXTERNAL), 'expect the result to contain '+FileNotificationAlertComposer.ENGAGEMENT_FILES_EXTERNAL);
        System.assert(!resultMessage.contains(FileNotificationAlertComposer.INDIVIDUAL_FILES_EXTERNAL),'expect the result to NOT contain '+FileNotificationAlertComposer.INDIVIDUAL_FILES_EXTERNAL);
    }
}