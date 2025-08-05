public with sharing class ace_Files {

    @testVisible 
    private ace_FilesDao dao;

    public ace_Files() {
        this.dao = new ace_FilesDao();
    }

    public ace_Files(ace_FilesDao dao) {
        this.dao = dao;
    }
    
    public List<ace_File__c> saveNewFiles(List<ace_File__c> aFiles){
        return this.dao.saveAceFiles(aFiles);
    }

    public List<ace_File__c> getVisibleFiles() {
        return dao.fetchVisibleFiles();
    }

    public List<ace_File__c> getAceFilesAddedInWindowForNotification(Integer lookbackWindowInHours){
        DateTime lookbackLimit = DateTime.Now().addHours(lookbackWindowInHours * -1);

        return this.dao.fetchAceFilesAddedInWindowForNotification(lookbackLimit);
    }

    public List<ace_File__c> getAceFilesVisibleToExternalAudiences(Set<Id> aceFileIds){
        return this.dao.fetchAceFilesVisibleToExternalAudiencesById(aceFileIds); 
    }

    public void flagFilesAsInternallyUploaded(Set<Id> aceFileIds){
        List<ace_File__c> fileRecords = new List<ace_File__c>();
        for(Id fileRecordId : aceFileIds){
            fileRecords.add(new ace_File__c(
                Id=fileRecordId, 
                Is_Internally_Uploaded__c = true, 
                Internal_Review_Status__c='Pending',
                Uploaded_By__c = UserInfo.getUserId()
            ));    
        }
        this.dao.saveAceFiles(fileRecords);
    }

    public List<ace_File__c> getFilesByEngagementId(Id engagementId) {
        return dao.fetchFilesByEngagementId(engagementId);
    }

   public List<ClientDocumentCenterCtrl.EngagementSummary> getEngagementsWithFiles(Integer batchSize, Integer offset) {
        return dao.fetchEngagementsWithFiles(batchSize, offset);
    }
}