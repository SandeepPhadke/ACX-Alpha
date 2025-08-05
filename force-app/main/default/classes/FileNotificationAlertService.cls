public with sharing class FileNotificationAlertService {

    @testVisible
    private Groups groups;

    @testVisible
    private SendGooderEmail emailInstance;
    
    @testVisible
    private Map<Id, List<GroupMember>> groupMembersByGroupId;

    @testVisible
    private List<FileNotificationQueueEntry> queueEntries;

    @testVisible
    private Integer lookbackWindow;


    public FileNotificationAlertService() {
        this.groups = new Groups();
        this.emailInstance = new SendGooderEmail();
    }
   
    public List<SendGooderEmailResponse> sendNotifications(List<FileNotificationQueueEntry> queueEntries, Integer lookbackWindow){
        List<SendGooderEmailResponse> responses = new List<SendGooderEmailResponse>();

        this.queueEntries = queueEntries;
        this.lookbackWindow = lookbackWindow;
        
        setTargetGroupMembers();
        
        List<SendGooderEmailRequest> emailRequests = createEmailRequests();
        List<SendGooderEmailResponse> sendResponses = getSendResponses(emailRequests);
     
        return sendResponses;
    }
   
    private List<SendGooderEmailResponse> getSendResponses(List<SendGooderEmailRequest> requests){
        List<SendGooderEmailResponse> emailSendResponses = this.emailInstance.sendEmail(requests);

        return emailSendResponses;
    }

    private List<SendGooderEmailRequest> createEmailRequests(){
        List<SendGooderEmailRequest> emailRequests = new List<SendGooderEmailRequest>();

        for(FileNotificationQueueEntry queueEntry : this.queueEntries){
            if(groupMembersByGroupId.containsKey(queueEntry.groupId)){
                emailRequests.add(makeEmailRequest(queueEntry));
            }
        }

        return emailRequests;
    }

    private Set<String> getRecipientIds(Id groupId){
        Set<String> recipientIds = new Set<String>();

        for(GroupMember groupmember : groupMembersByGroupId.get(groupId)){
            recipientIds.add(groupmember.UserOrGroupId);
        }

        return recipientIds;
    }


    @testVisible
    private SendGooderEmailRequest makeEmailRequest(FileNotificationQueueEntry queueEntry){
        SendGooderEmailRequest emailRequest = new SendGooderEmailRequest();
        
        emailRequest.subject = 'New Files Added in ACX';
        emailRequest.plainTextBody = new FileNotificationAlertComposer().getAlertMessage(queueEntry, lookbackWindow);
        emailRequest.sendToCollectionOfEmailAddresses = new List<String>(getRecipientIds(queueEntry.groupId));
        emailRequest.bcc=true;
        emailRequest.sendAsync = false;

        return emailRequest;
    }

    @testVisible
    private void setTargetGroupMembers(){
        Set<Id> groupIds = getGroupIds();

        this.groupMembersByGroupId = this.groups.getGroupMembersByGroupId(groupIds);
    }

    private Set<Id> getGroupIds(){
        Set<Id> targetGroupIds = new Set<Id>();
        
        for(FileNotificationQueueEntry queueEntry : this.queueEntries){
            targetGroupIds.add(queueEntry.groupId);
        }

        return targetGroupIds;
    }

}