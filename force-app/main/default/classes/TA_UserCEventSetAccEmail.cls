public class TA_UserCEventSetAccEmail implements TriggerAction.AfterInsert {

    @testVisible
    public UserChangeEventDao dao;

    public TA_UserCEventSetAccEmail() {
        this.dao = new UserChangeEventDao();
    }

    public void AfterInsert(List<UserChangeEvent> newList) {
        handleUserEmailChange(newList);
    }

    @testVisible
    public void handleUserEmailChange(List<UserChangeEvent> events) {
        Set<String> userIds = new Set<String>();

        for (UserChangeEvent event : events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            if (header.changedFields.contains('Email') && header.changeType == 'Update') {
                userIds.addAll(header.RecordIds);
            }
        }

        if (userIds.isEmpty()) return;

        List<User> userList = dao.getActiveAssigneePortalUsers(userIds);
        if (userList.isEmpty()) return;

        Map<String, User> accIdToUserMap = new Map<String, User>();
        List<Account> accountsToUpdate = new List<Account>();

        for (User usr : userList) {
            if (usr.AccountId != null) {
                accountsToUpdate.add(new Account(
                    Id = usr.AccountId,
                    Primary_Email__pc = usr.Email,
                    Agree_to_Share_Email__pc = usr.Share_Email_with_Employer__c
                ));
                accIdToUserMap.put(usr.AccountId, usr);
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }

        Map<Id, Engagement_Assignee__c> engagementAssigneeMap =
            dao.getEngagementAssigneesByAssignee(accIdToUserMap.keySet());

        List<Engagement_Assignee__c> engagementAssigneesToUpdate = new List<Engagement_Assignee__c>();

        for (Engagement_Assignee__c ea : engagementAssigneeMap.values()) {
            User user = accIdToUserMap.get(ea.Assignee__c);
            if (user != null && user.Share_Email_with_Employer__c) {
                ea.Email__c = user.Email;
                engagementAssigneesToUpdate.add(ea);
            }
        }

        if (!engagementAssigneesToUpdate.isEmpty()) {
            update engagementAssigneesToUpdate;
        }
    }
}