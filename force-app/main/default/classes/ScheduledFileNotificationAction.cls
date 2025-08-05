public with sharing class ScheduledFileNotificationAction {
    
    @testVisible
    private static final String IS_ENQUEUED_JOB_MSG = 'Notification Job Enqueued';
    @testVisible
    private static final String IS_NOT_ENQUEUED_JOB_MSG = 'Notification Job was not enqueued.';
    @testVisible
    private static final String ENQUEUE_ERROR = 'There was an error. Please see the logs for more info.';

    @testVisible 
    private static FileNotificationJobService jobService;

    @InvocableMethod(label='Run Scheduled File Notification Process' iconName='slds:standard:email')
    public static List<Response> doScheduledFileNotificationAction(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for(Request req : requests){
            responses.add(getResponse(req));
        }

        return responses;
    }

    @testVisible
    private static Response getResponse(Request req){
        Response response = new Response();
        FileNotificationJob job = getService().makeFileNotificationJob(req.emailChunkSize, req.lookbackWindow);

        if(job.hasItems()){
            try {
                Id jobId = Test.isRunningTest() ? null : System.enqueueJob(new FileNotificationAsyncJob(job));
                response.msg = IS_ENQUEUED_JOB_MSG;
            } catch(Exception ex){
                response.msg = handleException(ex);
            }
        } else {
            response.msg = IS_NOT_ENQUEUED_JOB_MSG;
        }
        response.filesReviewed = jobService.getFilesReviewedSize();

        return response;
    }

    @testVisible
    private static String handleException(Exception ex){
        String exceptionResponseMessage = IS_NOT_ENQUEUED_JOB_MSG+' -- '+ENQUEUE_ERROR;
        Logger.error(ex.getStackTraceString());
        Logger.error(ex.getMessage());
        
        return exceptionResponseMessage;
    }

    private static FileNotificationJobService getService(){
        if(jobService == null){
            jobService = new FileNotificationJobService();
        } 

        return jobService;
    }

    public class Request {
        @InvocableVariable(label='Lookback Window in Hours' required = true)
        public Integer lookbackWindow;
        @InvocableVariable(label='Emails per chunk' required = true)
        public Integer emailChunkSize;
    }

    public class Response {
        @InvocableVariable
        public String msg;
        @InvocableVariable
        public Integer filesReviewed;
    }
}