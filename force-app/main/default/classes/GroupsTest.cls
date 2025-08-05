@isTest 
public with sharing class GroupsTest {

    @isTest 
    private static void itShouldMapGroupMembers(){
        Id group_one_id = TestUtility.getFakeId(Group.SObjectType);
        Id group_two_id = TestUtility.getFakeId(Group.SObjectType);

        List<GroupMember> groupMembersFromQuery = new List<GroupMember>();
        groupMembersFromQuery.add(new GroupMember(UserOrGroupId=TestUtility.getFakeId(User.SObjectType), GroupId = group_one_id, Id = TestUtility.getFakeId(GroupMember.SObjectType)));
        groupMembersFromQuery.add(new GroupMember(UserOrGroupId=TestUtility.getFakeId(User.SObjectType), GroupId = group_one_id, Id = TestUtility.getFakeId(GroupMember.SObjectType)));
        groupMembersFromQuery.add(new GroupMember(UserOrGroupId=TestUtility.getFakeId(User.SObjectType), GroupId = group_two_id, Id = TestUtility.getFakeId(GroupMember.SObjectType)));
        groupMembersFromQuery.add(new GroupMember(UserOrGroupId=TestUtility.getFakeId(User.SObjectType), GroupId = group_two_id, Id = TestUtility.getFakeId(GroupMember.SObjectType)));
        groupMembersFromQuery.add(new GroupMember(UserOrGroupId=TestUtility.getFakeId(User.SObjectType), GroupId = group_two_id, Id = TestUtility.getFakeId(GroupMember.SObjectType)));

        Stub daoStub = new Stub(GroupsDao.class);
        daoStub.setReturnValue('fetchGroupMembersWhoAreUsers', groupMembersFromQuery);

        Groups instance = new Groups();
        instance.dao = (GroupsDao)daoStub.instance;

        Map<Id, List<GroupMember>> results;

        test.startTest();

        results = instance.getGroupMembersByGroupId(new Set<Id>());

        test.stopTest();

        daoStub.assertInvoked('fetchGroupMembersWhoAreUsers');
        
        System.assertEquals(2, results.get(group_one_id).size(), 'expected two rows in group 1');
        System.assertEquals(3, results.get(group_two_id).size(), 'expected three rows in group 2');
    }

    @isTest 
    private static void itShouldExerciseTheDao(){
        List<GroupMember> results;

        test.startTest();

        results = new GroupsDao().fetchGroupMembersWhoAreUsers(new Set<Id>{TestUtility.getFakeId(GroupMember.SObjectType)});

        test.stopTest();

        System.assertEquals(0, results.size(), 'expected nothing to come back for a made up id!');
    }
}