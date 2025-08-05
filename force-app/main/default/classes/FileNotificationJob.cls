public with sharing class FileNotificationJob {
    
    private Integer emailChunkSize;
    private Integer lookbackWindow;
    
    @testVisible
    private FileNotificationQueue queue;
    @testVisible
    private FileNotificationAlertService notificationService;


    public FileNotificationJob(Integer emailChunkSize, Integer lookbackWindow){
        this.notificationService = new FileNotificationAlertService();
        this.queue = new FileNotificationQueue();
        this.emailChunkSize = emailChunkSize;
        this.lookbackWindow = lookbackWindow;
    }

    public void addItems(Request req){
        addToQueue(req);
    }

    public void addItems(List<Request> reqs){
        for(Request req : reqs){
            addToQueue(req);
        }
    }

    public void sendNotifications(){
        this.notificationService.sendNotifications(this.queue.getQueue(), 10);
    }

    public Boolean hasItems(){
        return this.queue.hasItems();
    }

    private void addToQueue(Request req){
        for(Account office : req.offices){
            System.debug('office:'+office);
            if(office.RelatedGroupId__c != null){
                this.queue.addFile(req.sharedFile, office.RelatedGroupId__c);
            }
            else{
                System.debug('the office, '+office.Name+', with the ID of '+office.Id+' does not have a RelatedGroupId. It cant be included in this queue');
            }
        }
    }


    public class Request{

        public ace_File__c sharedFile;
        public Set<Account> offices;

        public Request(ace_File__c sharedFile){
            this.sharedFile = sharedFile;
            this.offices = new Set<Account>();
        }

        public void addOffice(Account office){
            this.offices.add(office);
        }

        public void addOffices(Set<Account> officeAccounts){
            this.offices.addAll(officeAccounts);
        }
    }
}