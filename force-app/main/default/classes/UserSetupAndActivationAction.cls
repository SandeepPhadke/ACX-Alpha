public with sharing class UserSetupAndActivationAction {
    
    private static final String NO_ITEMS_RESULT = 'No items in the queue for request. Doing NOTHING';
    private static final String ITEM_REMOVED = 'The following items were removed from the request due to a problem with the request: ';
    private static final String ITEM_ADDED = 'The following items are enqueued for setup and activation: ';
    
    @testVisible
    private static List<Queueable> asyncJobs = new List<Queueable>();

    //TODO: this could be implemented to be a little more flexible for testing. 
    @InvocableMethod(label='Complete User Setup and Activation')
    public static List<Response> enqueueUserSetupAndActivation(List<Request> Requests) {
        List<Response> responses = new List<Response>();

        for(Request req : requests){
            responses.add(getResponse(req));
        }

        if(asyncJobs.size() > 0){
           enqueueAsyncJobs();
        }

        return responses;
    }

    private static Response getResponse(Request req){
        String msg;

        List<AsyncUserSetupQueueItem> queueItemsInRequest = req.queueItems;
        List<AsyncUserSetupQueueItem> queueItemsRemoved = new List<AsyncUserSetupQueueItem>();
        List<AsyncUserSetupQueueItem> queueItemsIncluded = new List<AsyncUserSetupQueueItem>();
        
        for(AsyncUserSetupQueueItem item : queueItemsInRequest){
            if(item.isValid()){
                queueItemsIncluded.add(item);
            } else {
                queueItemsRemoved.add(item);
            }
        }

        if(queueItemsIncluded.isEmpty()){
            msg += NO_ITEMS_RESULT+'\n';
        }
        if(queueItemsIncluded.isEmpty() == false){
            msg += ITEM_ADDED+'\n';
            msg += getQueueItemsAsWrittenList(queueItemsIncluded)+'\n';

            addAsyncJob(queueItemsIncluded);
        }
        if(queueItemsRemoved.isEmpty() == false){
            msg += ITEM_REMOVED+'\n';
            msg += getQueueItemsAsWrittenList(queueItemsRemoved)+'\n';
        }
        
        Response response = new Response();
        response.msg = msg;

        return response;
    }

    private static String getQueueItemsAsWrittenList(List<AsyncUserSetupQueueItem> items){
        String listString = '';
        for(AsyncUserSetupQueueItem item : items){
            listString+= JSON.serialize(items)+'\n';
        }

        return listString;
    }

    private static void addAsyncJob(List<AsyncUserSetupQueueItem> queueItems){
        asyncJobs.add(new AsyncUserSetupJob(queueItems));
    }   

    private static void enqueueAsyncJobs(){
        for(Queueable asyncJob : asyncJobs){
            Id jobId = Test.isRunningTest() ? null : System.enqueueJob(asyncJob);
        }      
    }

  
    public class Response{
        @InvocableVariable(label='Message')
        public String msg;
    }

    public class Request {
        @InvocableVariable(label = 'User Setup Queue Items' required=true)
        public List<AsyncUserSetupQueueItem> queueItems;

        public Request(){
            this.queueItems =  new List<AsyncUserSetupQueueItem>();
        }
    }

}