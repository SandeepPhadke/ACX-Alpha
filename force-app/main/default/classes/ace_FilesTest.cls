@isTest
public class ace_FilesTest {

    @isTest
    private static void itShouldCallTheDao() {
        Stub fileDao = new Stub(ace_FilesDao.class);
        fileDao.setReturnValue('saveAceFiles', null);

        ace_Files files = new ace_Files();
        files.dao = (ace_FilesDao)fileDao.instance;

        Test.startTest();
        files.flagFilesAsInternallyUploaded(new Set<Id>{
            TestUtility.getFakeId(ace_File__c.SObjectType)
        });
        Test.stopTest();

        fileDao.assertInvoked('saveAceFiles');
    }

    @isTest
    private static void test_getVisibleFiles() {
        Stub fileDao = new Stub(ace_FilesDao.class);

        ace_File__c mockFile = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            File_Name__c = 'Mock File'
        );

        fileDao.setReturnValue('fetchVisibleFiles', new List<ace_File__c>{ mockFile });

        ace_Files files = new ace_Files((ace_FilesDao)fileDao.instance);

        Test.startTest();
        List<ace_File__c> result = files.getVisibleFiles();
        Test.stopTest();
        
        fileDao.assertInvoked('fetchVisibleFiles');
    }

    @isTest
    private static void test_getFilesByEngagementId() {
        Stub fileDao = new Stub(ace_FilesDao.class);

        Id fakeEngagementId = TestUtility.getFakeId(Engagement__c.SObjectType);
        ace_File__c mockFile = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Engagement__c = fakeEngagementId
        );

        fileDao.setReturnValue('fetchFilesByEngagementId', new List<ace_File__c>{ mockFile });

        ace_Files files = new ace_Files((ace_FilesDao)fileDao.instance);

        Test.startTest();
        List<ace_File__c> result = files.getFilesByEngagementId(fakeEngagementId);
        Test.stopTest();
        
        fileDao.assertInvoked('fetchFilesByEngagementId');
    }

    @isTest
    private static void test_getEngagementsWithFiles() {
        Stub fileDao = new Stub(ace_FilesDao.class);

        ClientDocumentCenterCtrl.EngagementSummary mockSummary = new ClientDocumentCenterCtrl.EngagementSummary();
        mockSummary.engagementId = TestUtility.getFakeId(Engagement__c.SObjectType);
      //  mockSummary.engagementName = 'Test Engagement';

        fileDao.setReturnValue('fetchEngagementsWithFiles', new List<ClientDocumentCenterCtrl.EngagementSummary>{ mockSummary });

        ace_Files files = new ace_Files((ace_FilesDao)fileDao.instance);

        Test.startTest();
        List<ClientDocumentCenterCtrl.EngagementSummary> result = files.getEngagementsWithFiles(5,0);
        Test.stopTest();
        
        fileDao.assertInvoked('fetchEngagementsWithFiles');
    }

    @isTest
    private static void test_getAceFilesVisibleToExternalAudiences() {
        Stub fileDao = new Stub(ace_FilesDao.class);

        ace_File__c mockFile = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Internal_Review_Status__c = 'Approved'
        );

        fileDao.setReturnValue('fetchAceFilesVisibleToExternalAudiencesById', new List<ace_File__c>{ mockFile });

        ace_Files files = new ace_Files((ace_FilesDao)fileDao.instance);

        Set<Id> mockIds = new Set<Id>{ TestUtility.getFakeId(ace_File__c.SObjectType) };

        Test.startTest();
        List<ace_File__c> result = files.getAceFilesVisibleToExternalAudiences(mockIds);
        Test.stopTest();
        
        fileDao.assertInvoked('fetchAceFilesVisibleToExternalAudiencesById');
    }
}