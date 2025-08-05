public with sharing class FileNotificationQueue {

    @testVisible
    private Map<String, FileNotificationQueueEntry> notificationQueueItems;
    private List<FileNotificationQueueEntry> notificationQueue;
    @testVisible
    private Integer queueIndex;

    public FileNotificationQueue() {
        this.notificationQueueItems = new Map<String, FileNotificationQueueEntry>();
        this.notificationQueue = new List<FileNotificationQueueEntry>();
        this.queueIndex = 0;
    }

    public void addFile(ace_File__c sharedFile, Id targetGroupId){
        if(this.notificationQueueItems.containsKey(targetGroupId)){
            this.notificationQueueItems.get(targetGroupId).addFile(sharedFile);
        } else {
            FileNotificationQueueEntry entry = new FileNotificationQueueEntry(targetGroupId, sharedFile);
            this.notificationQueueItems.put(targetGroupId, entry);
        }
    }

    public FileNotificationQueueEntry getNextQueueItem(){
        FileNotificationQueueEntry entry = getQueue()[this.queueIndex];
        
        System.debug('has items: '+hasMoreItems());
        System.debug('queue index: '+this.queueIndex);
        System.debug('list size: '+getQueue().size());
        
        if(hasMoreItems()){
            this.queueIndex++;
        }

        return entry;
    }
    
    public Boolean hasMoreItems(){
        System.debug('queue size -1 : '+String.valueOf(getQueue().size()-1));
        return this.queueIndex < (getQueue().size()-1);
    }

    public List<FileNotificationQueueEntry> getQueue(){
        if(this.notificationQueue.size() == 0){
            this.notificationQueue.addAll(this.notificationQueueItems.values());
        }

        return this.notificationQueue;
    }

    public Boolean hasItems(){
        return notificationQueueItems.isEmpty() == false;
    }
}