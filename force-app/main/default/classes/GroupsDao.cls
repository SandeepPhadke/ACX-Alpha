public with sharing class GroupsDao {
    
    public List<GroupMember> fetchGroupMembersWhoAreUsers(Set<Id> groupIds){
        return [SELECT Id, UserOrGroupId , GroupId
                FROM GroupMember 
                 WHERE GroupId IN :groupIds 
                 AND  UserOrGroupId IN (SELECT Id FROM User WHERE IsACtive = TRUE)];
    }
}