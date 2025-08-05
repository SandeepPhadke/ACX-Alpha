public class Accounts {
    @testVisible
    private AccountsDao dao = new AccountsDao();  

    public void saveAccounts(List<Account> accounts) {
        dao.updateAccounts(accounts);
    }

    public Map<Id, Account> getFirmAccountsById(Set<Id> firmAccountIds){
        return this.dao.fetchFirmAccountsById(firmAccountIds);
    }
}