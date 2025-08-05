public class AsyncUpdateAccountJob implements Queueable {
    @testVisible
    private Accounts accounts;
    
	private List<Account> updates;    

    public AsyncUpdateAccountJob(List<Account> updates) {
        this.updates = updates;
        this.accounts = new Accounts();
    }

    public void execute(QueueableContext context) {
        this.accounts.saveAccounts(updates);
    }
}