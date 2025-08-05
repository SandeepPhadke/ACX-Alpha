global with sharing class SchedulableFileNotificationJob implements Schedulable{
    public Integer lookbackWindow;
    public Integer emailChunkSize;

    public SchedulableFileNotificationJob(Integer lookbackWindow, Integer emailChunkSize){
        this.lookbackWindow = lookbackWindow ?? 4;
        this.emailChunkSize = emailChunkSize ?? 100;
    }

    public void execute(SchedulableContext sc){
        ScheduledFileNotificationAction.Request req= new ScheduledFileNotificationAction.Request();
        req.lookbackWindow= this.lookbackWindow;
        req.emailChunkSize = this.emailChunkSize;

        ScheduledFileNotificationAction.doScheduledFileNotificationAction(new List<ScheduledFileNotificationAction.Request>{req});
    }

}