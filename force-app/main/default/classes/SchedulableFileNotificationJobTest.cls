@isTest 
public with sharing class SchedulableFileNotificationJobTest {

    @isTest 
    private static void itShouldRunTheJob(){
        Stub jobServiceStub = new Stub(FileNotificationJobService.class);
        Integer expected_files_reviewed = 10;

        Stub fileJobStub = new Stub(FileNotificationJob.class);
        fileJobStub.setReturnValue('hasItems', true);

        jobServiceStub.setReturnValue('makeFileNotificationJob', (FileNotificationJob)fileJobStub.instance);
        jobServiceStub.setReturnValue('getFilesReviewedSize', expected_files_reviewed);

        
        SchedulableFileNotificationJob job = new SchedulableFileNotificationJob(10,10);

        test.startTest();
       
        ScheduledFileNotificationAction.jobService = (FileNotificationJobService)jobServiceStub.instance;
       
        job.execute(null);

        test.stopTest();

    }
}