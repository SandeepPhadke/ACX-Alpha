@isTest
public class ace_FilesDaoTest {
    
    @isTest
    static void aceFilesDao(){
        List<ace_File__c> filesToUpdate = new List<ace_File__c>();
        ace_FilesDao fileDao = new ace_FilesDao();
        
        Id fakeEngagementId = TestUtility.getFakeId(Engagement__c.SObjectType);
        ace_File__c mockFile = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Engagement__c = fakeEngagementId
        );
        
        String message;
        Test.startTest();
        try{
            fileDao.saveAceFiles(filesToUpdate);
            fileDao.fetchFilesByEngagementId(fakeEngagementId);
            fileDao.fetchEngagementsWithFiles(5,0);
			List<ClientDocumentCenterCtrl.EngagementSummary> summaries = fileDao.fetchEngagementsWithFiles(5,0);            
            fileDao.fetchVisibleFiles();
        } catch (Exception e) {
            message = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, String.isEmpty(message));
    }

    @isTest
    private static void testFetchAceFilesVisibleToExternalAudiencesById() {
        List<ace_File__c> existingFiles = new List<ace_File__c>{new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Internal_Review_Status__c = 'Approved'
        )};
        Set<Id> fileIds = new Set<Id>();
        for (ace_File__c file : existingFiles) {
            fileIds.add(file.Id);
        }
        ace_FilesDao dao = new ace_FilesDao();

        
        Test.startTest();
        List<ace_File__c> result = dao.fetchAceFilesVisibleToExternalAudiencesById(fileIds);
        Test.stopTest();

    }
    
}