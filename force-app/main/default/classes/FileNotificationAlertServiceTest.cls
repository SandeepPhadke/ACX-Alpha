@isTest 
public with sharing class FileNotificationAlertServiceTest {
    
    @isTest 
    public static void itShouldTryToDoEmails(){
        Stub groupStub = new Stub(Groups.class);
        Stub emailStub = new Stub(SendGooderEmail.class);

        Id mockGroupId = TestUtility.getFakeId(Group.SObjectType);
        GroupMember member = new GroupMember(GroupId = mockGroupId, UserOrGroupId = TestUtility.getFakeId(User.SObjectType));
        
        groupStub.setReturnValue('getGroupMembersByGroupId', new Map<Id, List<GroupMember>>{mockGroupId=>new List<GroupMember>{member}});
        emailStub.setReturnValue('sendEmail', new List<SendGooderEmailResponse>{new SendGooderEmailResponse()});

        FileNotificationAlertService alertService = new FileNotificationAlertService();
        alertService.groups = (Groups)groupStub.instance;
        alertService.emailInstance = (SendGooderEmail)emailStub.instance;

        FileNotificationQueueEntry queueEntry = new FileNotificationQueueEntry(mockGroupId,new ace_File__c());
        
        List<SendGooderEmailResponse> results;

        test.startTest();

        results = alertService.sendNotifications(new List<FileNotificationQueueEntry>{queueEntry}, 10);

        test.stopTest();

        System.assertEquals(1, results.size());
        groupStub.assertInvoked('getGroupMembersByGroupId');
        emailStub.assertInvoked('sendEmail');
    }

    @isTest 
    private static void itShouldComposeEmailRequests(){
        Stub groupStub = new Stub(Groups.class);
        Stub emailStub = new Stub(SendGooderEmail.class);

        Id mockGroupId = TestUtility.getFakeId(Group.SObjectType);
        GroupMember member = new GroupMember(GroupId = mockGroupId, UserOrGroupId = TestUtility.getFakeId(User.SObjectType));
        
        groupStub.setReturnValue('getGroupMembersByGroupId', new Map<Id, List<GroupMember>>{mockGroupId=>new List<GroupMember>{member}});
        emailStub.setReturnValue('sendEmail', new List<SendGooderEmailResponse>{new SendGooderEmailResponse()});

        FileNotificationQueueEntry queueEntry = new FileNotificationQueueEntry(mockGroupId,new ace_File__c());

        FileNotificationAlertService alertService = new FileNotificationAlertService();
        alertService.groups = (Groups)groupStub.instance;
        alertService.emailInstance = (SendGooderEmail)emailStub.instance;
        alertService.queueEntries = new List<FileNotificationQueueEntry>{queueEntry};
        alertService.setTargetGroupMembers();

        
        SendGooderEmailRequest request = new SendGooderEmailRequest();

        test.startTest();

        request = alertService.makeEmailRequest(queueEntry);

        test.stopTest();

        System.assert(request != null);
    }
}