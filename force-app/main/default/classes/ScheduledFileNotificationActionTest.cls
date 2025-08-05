@isTest 

public with sharing class ScheduledFileNotificationActionTest {
    
    @isTest
    private static void itShouldOnlyActuallyRunIfItemsFound(){
     
        ScheduledFileNotificationAction.Request req = new ScheduledFileNotificationAction.Request();
        req.emailChunkSize=10;
        req.lookbackWindow=10;

     	List<ScheduledFileNotificationAction.Response> responses;
        
        test.startTest();

        responses = ScheduledFileNotificationAction.doScheduledFileNotificationAction(new List<ScheduledFileNotificationAction.Request>{req});

        test.stopTest();
        
        System.assertEquals(1, responses.size());
        ScheduledFileNotificationAction.Response response = responses[0];
        System.assertEquals(ScheduledFileNotificationAction.IS_NOT_ENQUEUED_JOB_MSG, response.msg);
        
    }
    
    @isTest 
    private static void  itShouldMakeTheJob(){
        Stub jobServiceStub = new Stub(FileNotificationJobService.class);
        Integer expected_files_reviewed = 10;

        Stub fileJobStub = new Stub(FileNotificationJob.class);
        fileJobStub.setReturnValue('hasItems', true);

        jobServiceStub.setReturnValue('makeFileNotificationJob', (FileNotificationJob)fileJobStub.instance);
        jobServiceStub.setReturnValue('getFilesReviewedSize', expected_files_reviewed);

        ScheduledFileNotificationAction.Request req = new ScheduledFileNotificationAction.Request();
        req.emailChunkSize=10;
        req.lookbackWindow=10;

        ScheduledFileNotificationAction.jobService = (FileNotificationJobService)jobServiceStub.instance;
		List<ScheduledFileNotificationAction.Response> responses;
        
        test.startTest();

        responses = ScheduledFileNotificationAction.doScheduledFileNotificationAction(new List<ScheduledFileNotificationAction.Request>{req});

        test.stopTest();
        
        jobServiceStub.assertInvoked('makeFileNotificationJob');
        jobServiceStub.assertInvoked('getFilesReviewedSize');
        fileJobStub.assertInvoked('hasItems');
        
        
    }

    @isTest
    private static void itShouldHandleExceptions(){
        String expected = 'Notification Job was not enqueued.';
        String result;
        test.startTest();
        
        result = ScheduledFileNotificationAction.handleException(new AuraHandledException('NO WAY'));
        
        test.stopTest();
        
        System.assert(result.contains(expected));
    }
  
}