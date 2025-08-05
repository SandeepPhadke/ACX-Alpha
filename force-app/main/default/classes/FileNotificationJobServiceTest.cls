@isTest 
public with sharing class FileNotificationJobServiceTest {
  
    @isTest
    private static void itShouldBePreparedToNotifyAllFirms(){
        Stub aFilesStub = new Stub(ace_Files.class);
		Stub engagementsStub = new Stub(Engagements.class);
		Stub accountStub = new Stub(Accounts.class);
        
        Account clientAccount = makeAccount();
        Account coordinatingAccount = makeAccount();
        Account subscribedOfficeAccount = makeAccount();
        Account personAccount = makeAccount();
        
		List<Account> officeAccounts = new List<Account>();
        officeAccounts.add(makeAccount());
        officeAccounts.add(makeAccount());
        officeAccounts.add(makeAccount());
        officeAccounts.add(makeAccount());
        officeAccounts.add(makeAccount());
        
        List<Account> returnedAccounts = new List<Account>{clientAccount, coordinatingAccount, subscribedOfficeAccount};
        
		returnedAccounts.addAll(officeAccounts);
            
        Engagement__c engagement = makeEngagement(clientAccount, coordinatingAccount);
        
        Subscribed_Offices__c subscribedOffice = makeSubscribedOffice(engagement, subscribedOfficeAccount);
        
        List<Subscribed_Offices__c> offices = new List<Subscribed_Offices__c>();
        offices.add(subscribedOffice);
        
        System.debug('SUB OFFICE: '+JSON.serialize(subscribedOffice));
        
        for(Account officeAccount : officeAccounts){
            offices.add(makeSubscribedOffice(engagement, officeAccount));
        }
        
        engagement = makeEngagementWithOffices(engagement, offices);
        
        Engagement_Assignee__c assignee = makeEngagementAssignee(engagement, personAccount);
        
        List<ace_File__c> filesSinceLookback = new List<ace_File__c>();
        ace_File__c highlyVisibleEngagementFile = makeEngagementFile(engagement, subscribedOffice);
        highlyVisibleEngagementFile.Internal_Visibility__c = 'All Firms on Engagement';
       
        ace_File__c lessVisibleEngagementFile = makeEngagementFile(engagement, subscribedOffice);
        
        //sub office should see 3 files.. everyone else should see one, except coordinating office.
        filesSinceLookback.add(lessVisibleEngagementFile);
        filesSinceLookback.add(highlyVisibleEngagementFile);
        filesSinceLookback.add(makeIndividualFile(personAccount, subscribedOffice));
        
		System.debug('files returned:: '+JSON.serialize(filesSinceLookback));
        
        aFilesStub.setReturnValue('getAceFilesAddedInWindowForNotification', filesSinceLookback);
        engagementsStub.setReturnValue('getEngagementsWithAllSubscribedOffices', new Map<Id, Engagement__c>{engagement.Id=>engagement});
        engagementsStub.setReturnValue('getMobileEmployeesByIndividualId', new List<Engagement_Assignee__c>{assignee});
        accountStub.setReturnValue('getFirmAccountsById', new Map<Id, Account>(returnedAccounts));
        
        FileNotificationJobService jobService = new FileNotificationJobService();
        jobService.aFiles = (ace_Files)aFilesStub.instance;
        jobService.engagements = (Engagements)engagementsStub.instance;
        jobService.accounts = (Accounts)accountStub.instance;
        
        FileNotificationJob job;
       
        test.startTest();
        
        job = jobService.makeFileNotificationJob(10,10);
        
        test.stopTest();
        
        
        System.debug(JSON.serialize(job));

    }


    @isTest 
    private static void itShouldDoTheThing(){
        Stub aFilesStub = new Stub(ace_Files.class);
		Stub engagementsStub = new Stub(Engagements.class);
		Stub accountStub = new Stub(Accounts.class);
        
        Account clientAccount = makeAccount();
        Account coordinatingAccount = makeAccount();
        Account subscribedOfficeAccount = makeAccount();
        Account personAccount = makeAccount();
        
        List<Account> returnedAccounts = new List<Account>{clientAccount, coordinatingAccount, subscribedOfficeAccount};
            
        Engagement__c engagement = makeEngagement(clientAccount, coordinatingAccount);
        Subscribed_Offices__c subscribedOffice = makeSubscribedOffice(engagement, subscribedOfficeAccount);
        
        engagement = makeEngagementWithOffices(engagement, new List<Subscribed_Offices__c>{subscribedOffice});
        
        Engagement_Assignee__c assignee = makeEngagementAssignee(engagement, personAccount);
        
        List<ace_File__c> filesSinceLookback = new List<ace_File__c>();
        filesSinceLookback.add(makeEngagementFile(engagement, subscribedOffice));
        filesSinceLookback.add(makeIndividualFile(personAccount, subscribedOffice));
        
		System.debug('files returned:: '+JSON.serialize(filesSinceLookback));
        
        aFilesStub.setReturnValue('getAceFilesAddedInWindowForNotification', filesSinceLookback);
        engagementsStub.setReturnValue('getEngagementsWithAllSubscribedOffices', new Map<Id, Engagement__c>{engagement.Id=>engagement});
        engagementsStub.setReturnValue('getMobileEmployeesByIndividualId', new List<Engagement_Assignee__c>{assignee});
        accountStub.setReturnValue('getFirmAccountsById', new Map<Id, Account>(returnedAccounts));
        
        FileNotificationJobService jobService = new FileNotificationJobService();
        jobService.aFiles = (ace_Files)aFilesStub.instance;
        jobService.engagements = (Engagements)engagementsStub.instance;
        jobService.accounts = (Accounts)accountStub.instance;
        
        FileNotificationJob job;
       
        test.startTest();
        
        job = jobService.makeFileNotificationJob(10,10);
        
        test.stopTest();
        
        
        aFilesStub.assertInvoked('getAceFilesAddedInWindowForNotification');
    }

   
	
    private static Account makeAccount(){
        Account fakeAccount = new Account(Name='Fake Account '+String.valueOf(DateTime.Now()), Id=TestUtility.getFakeId(Account.SObjectType), RelatedGroupId__c=TestUtility.getFakeId(Group.SObjectType));
        
        return fakeAccount;
    }
    
    private static Engagement__c makeEngagement(Account clientAccount, Account coordinatingOfficeAccount){
        String engagementString = new MobilityTestRecordBuilder()
                                    .withObjectType(engagement__c.SObjectType)
                                    .withParentRecords('Coordinating_Office__r', JSON.serialize(coordinatingOfficeAccount))
                                    .withParentRecords('Client__r', JSON.serialize(clientAccount))
                                    .withFields(new Map<String, String>{'Name'=>'Super Engagement'+String.valueOf(DateTime.Now())})
                                    .build()
                                    .getObjectString();
    
        return (Engagement__c)JSON.deserialize(engagementString, Engagement__c.class);
    }

    private static Engagement_Assignee__c makeEngagementAssignee(Engagement__c engagement, Account personaccount){
        String assigneeString = new MobilityTestRecordBuilder()
            					.withObjectType(Engagement_Assignee__c.SobjectType)
            					.withParentRecords('Engagements__r', JSON.serialize(engagement))
            					.withParentRecords('Assignee__r', JSON.serialize(personAccount))
                                .withFields(new Map<String, String>{'Assignee__c'=>personaccount.Id})
            					.build()
        						.getObjectString();
        System.debug('assignee : '+assigneeString);
        return (Engagement_Assignee__c)JSON.deserialize(assigneeString, Engagement_Assignee__c.class);
        
    }

    private static Engagement__c makeEngagementWithOffices(Engagement__c engagement, List<Subscribed_Offices__c> offices){
        List<String> subscribedOffices = new List<String>();
        String childString = '';
        
        for(Subscribed_offices__c office: offices){
            subscribedOffices.add(JSON.serialize(office));
        }
        
        String engagementString = new MobilityTestRecordBuilder()
            						.withObjectType(Engagement__c.sobjectType)
            						.withObjectString(JSON.serialize(engagement))
            						.withChildRecords('Subscribed_Office__r', subscribedOffices)
            						.build()
            						.getObjectString();
        
        return (Engagement__c)JSON.deserialize(engagementString, Engagement__c.class);
    }

    private static Subscribed_Offices__c makeSubscribedOffice(Engagement__c engagement, Account subscribedOfficeAccount){
        String subscribedOfficeString = new MobilityTestRecordBuilder()
                                            .withObjectType(Subscribed_Offices__c.SObjectType)
                                            .withFields(new Map<String, String>{'Engagement__c'=>engagement.Id, 'Account__c'=>subscribedOfficeAccount.Id})
                                            .withParentRecords('Engagement__r', JSON.serialize(engagement))
                                            .withParentRecords('Account__r', JSON.serialize(subscribedOfficeAccount))
                                            .build()
                                            .getObjectString();
        
    
        return (Subscribed_Offices__c)JSON.deserialize(subscribedOfficeString, Subscribed_Offices__c.class);
    }

   private static ace_File__c makeEngagementFile(Engagement__c engagement, Subscribed_Offices__c office){
        String userString = new MobilityTestRecordBuilder()
            .withObjectType(User.sObjectType)
            .withFields(new Map<String, String>{'UserType'=>'Standard'})
            .build()
            .getObjectString();
        String sharedFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.sObjectType)
            .withParentRecords('CreatedBy', userString)
            .withParentRecords('Engagement__r', JSON.serialize(engagement))
            .withParentRecords('Subscribed_Office__r', JSON.serialize(office))
            .withFields(new Map<String, String>{'Engagement__c'=>engagement.Id, 'Subscribed_Office__c' => office.Id, 'Work_Record__c'=>null, 'Individual__c'=>null})
            .build()
            .getObjectString();

        return (ace_File__c)JSON.deserialize(sharedFileString, ace_File__c.class);
    }

    private static ace_File__c makeIndividualFile(Account individual, Subscribed_Offices__c office){
    String userString = new MobilityTestRecordBuilder()
            .withObjectType(User.sObjectType)
            .withFields(new Map<String, String>{'UserType'=>'CustomerSuccess'})
            .build()
            .getObjectString();
        String sharedFileString = new MobilityTestRecordBuilder()
            .withObjectType(ace_File__c.sObjectType)
            .withParentRecords('CreatedBy', userString)
            .withParentRecords('Individual__r', JSON.serialize(individual))
            .withParentRecords('Subscribed_Office__r', JSON.serialize(office))
        	.withFields(new Map<String, String>{'Engagement__c'=>null,'Subscribed_Office__c' => office.Id, 'Work_Record__c'=>null, 'Individual__c'=>individual.Id, 'Subscribed_Office__c'=>office.Id})
            .build()
            .getObjectString();

        return (ace_File__c)JSON.deserialize(sharedFileString, ace_File__c.class);
    }
    
}