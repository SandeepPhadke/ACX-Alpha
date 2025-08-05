public with sharing class FileNotificationQueueEntry {
    
    public Id groupId;
    public Map<String, FileNotificationCount> engagementFiles;
    public Map<String, FileNotificationCount> individualFiles;

    public FileNotificationQueueEntry(Id groupId, ace_File__c sharedFile) {
        this.groupId = groupId;
        this.engagementFiles = new Map<String, FileNotificationCount>();
        this.individualFiles = new Map<String, FileNotificationCount>();
        this.addFile(sharedFile);
    }

    public void addFile(ace_File__c sharedFile){
        if(isEngagementFile(sharedFile)){
            String engagementName = sharedFile.Engagement__r.Name;
            addToCount(this.engagementFiles, engagementName, sharedFile);
        }
        if(isIndividualFile(sharedFile)){
            String individualName = sharedFile.Individual__r.Name;
            addToCount(this.individualFiles, individualName, sharedFile);
         }
    }


    private void addToCount(Map<String, FileNotificationCount> countMap, String countName, ace_File__c sharedFile){
        if(countMap.containsKey(countName)){
            countMap.get(countName).addFile(sharedFile);
        } else{
            FileNotificationCount count = new FileNotificationCount();
            count.addFile(sharedFile);
            countMap.put(countName, count);
        }
    }

    
    private Boolean isEngagementFile(ace_File__c sharedFile){
        return sharedFile.Engagement__c != null && sharedFile.Individual__c == null && sharedFile.Work_Record__c == null;
    }

    private Boolean isIndividualFile(ace_File__c sharedFile){
        return sharedFile.Individual__c != null && sharedFile.Engagement__c == null && sharedFile.Work_Record__c == null;
    }
}