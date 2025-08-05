public class AsyncUpdateAccountRelatedGroupAction {
	
    @testVisible
	private static List<Queueable> asyncJobs = new List<Queueable>();  
    
    public class Request {
        
        @InvocableVariable(required = true)
        public Id accountId;

        @InvocableVariable(required = true)
        public Id groupId;
    }

    @InvocableMethod(label='CreateGroupAndUpdateAccount Subflow')
    public static void updateAccounts(List<Request> requests) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Request req : requests) {
            accountsToUpdate.add(new Account(
                Id = req.accountId,
                RelatedGroupId__c = req.groupId
            ));
        }
		asyncJobs.add(new AsyncUpdateAccountJob(accountsToUpdate));
        enqueueAsyncJobs(asyncJobs);
    }
    
    public static void enqueueAsyncJobs(List<Queueable> jobs) {
        if (jobs != null && jobs.size() >= 1) {
            for (Queueable job : jobs) {
                Id jobId = Test.isRunningTest() ? null : System.enqueueJob(job);
            }
        }
    }
}