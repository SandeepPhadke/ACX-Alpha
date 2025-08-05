public class AccountsDao {
    public void updateAccounts(List<Account> accounts) {
        update accounts;
    }

    public Map<Id, Account> fetchFirmAccountsById(Set<Id> firmAccountIds){
        return new Map<Id, Account>([SELECT Id, Name, RelatedGroupId__c from Account WHERE Id IN :firmAccountIds AND RecordType.Name = 'Firm']);
    }
}