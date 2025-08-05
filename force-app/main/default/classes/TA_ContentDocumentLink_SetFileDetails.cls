public class TA_ContentDocumentLink_SetFileDetails implements TriggerAction.AfterInsert {

    private static final String ACE_FILE_SOBJECT_TYPE = 'ace_File__c';
    private static final String STANDARD_USER_TYPE = 'STANDARD';
    
    @testVisible
    private ContentVersionDao contVersionDao;
    @testVisible
    private ace_FilesDao filesDao;
    @testVisible
    private List<ace_File__c> fileUpdates;

    public TA_ContentDocumentLink_SetFileDetails() {
        this(new ContentVersionDao(), new ace_FilesDao());
    }

    public TA_ContentDocumentLink_SetFileDetails(ContentVersionDao dao, ace_FilesDao filesDao) {
        this.contVersionDao = dao;
        this.filesDao = filesDao;
        this.fileUpdates = new List<ace_File__c>(); 
    }
    
    public void AfterInsert(List<ContentDocumentLink> newList) {
        getFilesAndSetFileDetails(newList);
    }

    @testVisible
    private void getFilesAndSetFileDetails(List<ContentDocumentLink> docLinks) {
        Map<Id, Id> fileToDocumentMap = new Map<Id, Id>();

        for (ContentDocumentLink cdl : docLinks) {
            if (cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSObjectType() == ace_File__c.SObjectType) {
                fileToDocumentMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
            }
        }

        if (fileToDocumentMap.isEmpty()) return;

        Set<Id> contentDocumentIds = new Set<Id>(fileToDocumentMap.values());

        List<ContentVersion> versions = contVersionDao.getContentVersionsByDocumentIds(contentDocumentIds);
 
        Map<Id, ContentVersion> docIdToVersionMap = new Map<Id, ContentVersion>();
        for (ContentVersion cv : versions) {
            docIdToVersionMap.put(cv.ContentDocumentId, cv);
        }

        Map<Id, ace_File__c> fileUpdateMap = new Map<Id, ace_File__c>(); 
        for (Id fileId : fileToDocumentMap.keySet()) {
            Id docId = fileToDocumentMap.get(fileId);
            ContentVersion cv = docIdToVersionMap.get(docId);
            if (cv != null) {
                ace_File__c fileUpdate = new ace_File__c(
                    Id = fileId,
                    File_Size__c = cv.ContentSize,
                    File_Type__c = cv.FileType,
                    Upload_Date__c = cv.CreatedDate,
                    Uploaded_By__c = cv.CreatedById,
                    File_Name__c = cv.Title
                );
                fileUpdateMap.put(fileId, fileUpdate); 
            }
        }

        if (!fileUpdateMap.isEmpty()) {
            fileUpdates.addAll(fileUpdateMap.values());
            filesDao.saveAceFiles(fileUpdates);
        }
    }
}