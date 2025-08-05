public with sharing class Groups {
    
    @testVisible
    private GroupsDao dao;

    public Groups() {
        this.dao = new GroupsDao();
    }

    public Map<Id, List<GroupMember>> getGroupMembersByGroupId(Set<Id> groupIds){
        Map<Id, List<GroupMember>> groupMembersById = new Map<Id, List<GroupMember>>();
        
        for(GroupMember member : this.dao.fetchGroupMembersWhoAreUsers(groupIds)){
            if(groupMembersById.containsKey(member.groupId)){
                groupMembersById.get(member.groupId).add(member);
            } else {
                groupMembersById.put(member.groupId, new List<GroupMember>{member});
            }
        }

        return groupMembersById;
    }
}