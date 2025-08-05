public with sharing class FileNotificationAsyncJob implements Queueable{
    FileNotificationJob job;

    public FileNotificationAsyncJob(FileNotificationJob job) {
        this.job = job;
    }

    public void execute(QueueableContext qc){
        //run the sending process
    }
}