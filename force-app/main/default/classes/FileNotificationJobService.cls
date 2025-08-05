public with sharing class FileNotificationJobService {

    private static final String INDIVIDUAL_KEY = 'Individual';
    private static final String ENGAGEMENT_KEY = 'Engagement';
    private static final String ALL_FIRMS_KEY = 'All Firms on Engagement'; //TODO.. make enum?
	
    @testVisible
    private ace_Files aFiles;
    @testVisible
    private Engagements engagements;
    @testVisible
    private Accounts accounts;

    @testVisible
    private Map<Id, Account> accountsById;
    @testVisible
    private Map<Id, Id> coordinatingOfficeByIndividual;
    @testVisible
    private Map<Id, List<Subscribed_Offices__c>> subscribedOfficesByEngagement;

    private List<ace_File__c> newFiles;
    
    public FileNotificationJobService() {
     	this.aFiles= new ace_Files();
        this.engagements = new Engagements();
        this.accounts = new Accounts();
    }

    public FileNotificationJob makeFileNotificationJob(Integer emailChunkSize, Integer lookbackWindow){
        initializeData(lookbackWindow);

        FileNotificationJob job = new FileNotificationJob(emailChunkSize, lookbackWindow);
        job.addItems(makeJobRequests());

        return job;
    }

    public Integer getFilesReviewedSize(){
        return this.newFiles.size();
    }

    @testVisible
    private void initializeData(Integer lookbackWindow){
        this.accountsById = new Map<Id, Account>();
        this.coordinatingOfficeByIndividual = new Map<Id, Id>();

        this.newfiles = getFilesSinceLookback(lookbackWindow);
        Map<String, Set<Id>> recordIdsByType = getRecordIdsBySharedFileType(this.newFiles);
        this.subscribedOfficesByEngagement = getSubscribedOfficesForEngagements(recordIdsByType.get(ENGAGEMENT_KEY)); 
        this.coordinatingOfficeByIndividual  = getCoordinatingCountriesForIndividualFiles(recordIdsByType.get(INDIVIDUAL_KEY));
       
        setAccountData();  
    }

    private void setAccountData(){
        Set<Id> firmAccountIds = new Set<Id>();
        firmAccountIds.addAll(getAccountIds(this.subscribedOfficesByEngagement.values()));
        firmAccountIds.addAll(this.coordinatingOfficeByIndividual.values());
        firmAccountIds.addAll(getCoordinatingOfficeFirmAccountsForEngagementFiles(this.newFiles));
        
        setAccountsById(firmAccountIds);
    }

    private List<ace_File__c> getFilesSinceLookback(Integer lookbackWindow){
        return this.aFiles.getAceFilesAddedInWindowForNotification(lookbackWindow);
    }

    private List<FileNotificationJob.Request> makeJobRequests(){
        List<FileNotificationJob.Request> requests = new List<FileNotificationJob.Request>();

        for(ace_File__c sharedFile : this.newFiles){
            requests.add(makeJobRequest(sharedFile));
        }

        return requests;
    }

    @testVisible
    private FileNotificationJob.Request makeJobRequest(ace_File__c sharedFile){
        FileNotificationJob.Request request = new FileNotificationJob.Request(sharedFile);
        Set<Account> offices = getOfficesForFile(sharedFile);
        
       
        request.addOffices(offices);

        return request;
    }

    private Set<Account> getOfficesForFile(ace_File__c sharedFile){
        Set<Account> offices = new Set<Account>();
        if(isEngagementFile(sharedFile)){
            offices = addOfficeAccount(offices, sharedFile.Engagement__r.Coordinating_Office__c);
        }
        if(isIndividualFile(sharedFile)){
           offices = addOfficeAccount(offices, this.coordinatingOfficeByIndividual.get(sharedFile.Individual__c));
        }
        if(hasSubscribedOffice((sharedFile))){
            offices = addOfficeAccount(offices, sharedFile.Subscribed_Office__r.Account__c);
        }
        if(isSharedWithAllOffices(sharedFile)){
            offices = addAllSubscribedOfficeAccounts(offices, sharedFile.Engagement__c);
        }
        
        return offices;
    }

    private Set<Account> addOfficeAccount(Set<Account> offices, Id officeAccountId){
        if(this.accountsById.containsKey(officeAccountId)){
            offices.add(accountsById.get(officeAccountId));
        }

        return offices;
    }

   private Set<Account> addAllSubscribedOfficeAccounts(Set<Account> offices, Id engagementId){
        List<Subscribed_Offices__c> subscribedOfficesOnEngagement = subscribedOfficesByEngagement.get(engagementId);
        
        if(subscribedOfficesOnEngagement == null || subscribedOfficesOnEngagement.isEmpty()) return offices;

        for(Subscribed_Offices__c subscribedOffice : subscribedOfficesOnEngagement){
            offices = addOfficeAccount(offices, subscribedOffice.Account__c);
        }

        return offices;
   }

    private void setAccountsById(Set<Id> firmAccountIds){
        this.accountsById = this.accounts.getFirmAccountsById(firmAccountIds);
    }

    private Map<String, Set<Id>> getRecordIdsBySharedFileType(List<ace_File__c> sharedFiles){
        Map<String, Set<Id>> recordIdsByType = new Map<String, Set<Id>>{INDIVIDUAL_KEY => new Set<Id>(), ENGAGEMENT_KEY=> new Set<Id>()};
        for(ace_File__c sharedFile : sharedFiles){
            if(isEngagementFile(sharedFile)){
                recordIdsByType.get(ENGAGEMENT_KEY).add(sharedFile.Engagement__c);
            }
            if(isIndividualFile(sharedFile)){
                recordIdsByType.get(INDIVIDUAL_KEY).add(sharedFile.Individual__c);
            }
        }

        return recordIdsByType;
    }

    private Map<Id, List<Subscribed_Offices__c>> getSubscribedOfficesForEngagements(Set<Id> engagementIds){
        Map<Id, List<Subscribed_Offices__c>> officesByEngagements = new Map<Id, List<Subscribed_Offices__c>>();
        for(Engagement__c engagement : this.engagements.getEngagementsWithAllSubscribedOffices(engagementIds).values()){
            officesByEngagements.put(engagement.Id, engagement.Subscribed_Office__r);
        }

        return officesByEngagements;
    }

    private Map<Id, Id> getCoordinatingCountriesForIndividualFiles(Set<Id> individualIds){
        Map<Id, Id> individualToCoordinatingCountryMap = new Map<Id, Id>();
        for(Engagement_Assignee__c employee : this.engagements.getMobileEmployeesByIndividualId(individualIds)){
            individualToCoordinatingCountryMap.put(employee.Assignee__c, employee.Engagements__r.Coordinating_Office__c);
        }

        return individualToCoordinatingCountryMap;
    }
    
    private Set<Id> getCoordinatingOfficeFirmAccountsForEngagementFiles(List<ace_File__c> sharedFiles){
        Set<Id> firmAccountIds = new Set<Id>();

        for(ace_File__c sharedFile : sharedFiles){
            firmAccountIds.add(sharedFile.Engagement__r.Coordinating_Office__c);
        }

        return firmAccountIds;
    }


    private Boolean isEngagementFile(ace_File__c sharedFile){
        return sharedFile.Engagement__c != null && sharedFile.Individual__c == null && sharedFile.Work_Record__c == null;
    }

    private Boolean isIndividualFile(ace_File__c sharedFile){
        return sharedFile.Individual__c != null && sharedFile.Engagement__c == null && sharedFile.Work_Record__c == null;
    }

    private boolean hasSubscribedOffice(ace_File__c sharedFile){
        return sharedFile.Subscribed_Office__c != null;
    }
    
    private Boolean isSharedWithAllOffices(ace_File__c sharedFile){
        return isEngagementFile(sharedFile) && sharedFile.Internal_Visibility__c != null && sharedFile.Internal_Visibility__c.equalsIgnoreCase(ALL_FIRMS_KEY);
    }

    private Set<Id> getAccountIds(List<List<Subscribed_Offices__c>> records){
        Set<Id> accountIds = new Set<Id>();
        
        for(List<Subscribed_Offices__c> officeList : records){
            for(Subscribed_Offices__c office : officeList){
                accountIds.add(office.Account__c);
            }
        }

        return accountIds;
    }
   
}