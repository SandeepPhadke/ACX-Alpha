public class UserChangeEventDao {
 public List<User> getActiveAssigneePortalUsers(Set<String> userIds) {
        return [
            SELECT Id, AccountId, Email, IsActive, Profile.Name, Share_Email_with_Employer__c 
            FROM User 
            WHERE IsActive = true 
              AND Profile.Name = 'Assignee Portal' 
              AND Id IN :userIds
        ];
 }
      public Map<Id, Engagement_Assignee__c> getEngagementAssigneesByAssignee(Set<String> assigneeIds) {
        return new Map<Id, Engagement_Assignee__c>(
            [SELECT Id, Assignee__c, Email__c 
             FROM Engagement_Assignee__c 
             WHERE Assignee__c IN :assigneeIds]
        );
    
    }
}