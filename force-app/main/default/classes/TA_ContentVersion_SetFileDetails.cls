public class TA_ContentVersion_SetFileDetails implements TriggerAction.AfterInsert {
    
    private static final String ACE_FILE_SOBJECT_TYPE = 'ace_File__c';
    private static final String STANDARD_USER_TYPE = 'STANDARD';
    
	
    
    public void AfterInsert(List<ContentVersion> newList){
        getFilesAndSetFileDetails(newList);
    }
    
    @testVisible
    private void getFilesAndSetFileDetails(List<ContentVersion> newList){
        if(UserInfo.getUserType().equalsIgnoreCase(STANDARD_USER_TYPE)){
            Set<Id> fileIds = new Set<Id>();
            Map<String, ContentVersion> mapOfFileToContentVer = contentVerToAceFileMap(newList);
            setFileDetailsOnAceFile(mapOfFileToContentVer);
        }
    }
        
        
    @testVisible
    private Boolean isLinkedToAceFile(ContentVersion cv){
        Id publicationId = cv.FirstPublishLocationId;
        return publicationId.getSobjectType().toString().equalsIgnoreCase(ACE_FILE_SOBJECT_TYPE);
    }
    
    @testVisible
    private Map<String, ContentVersion> contentVerToAceFileMap(List<ContentVersion> newList){
        Map<String, ContentVersion> mapOfFileToContentVer = new Map<String, ContentVersion>();
            for(ContentVersion cv : newList){
                if(isLinkedToAceFile(cv)){
                    if(!mapOfFileToContentVer.containsKey(cv.FirstPublishLocationId)){
                        mapOfFileToContentVer.put(cv.FirstPublishLocationId, cv);
                    }
                }
            }
        return mapOfFileToContentVer;
    }
    
    public void setFileDetailsOnAceFile(Map<String, ContentVersion> mapOfFileToContentVer){
        List<ace_File__c> fileRecords = new List<ace_File__c>();

        for(String fileRecordId : mapOfFileToContentVer.keySet()){
        	fileRecords.add(new ace_File__c(Id=fileRecordId, 
                                            File_Size__c =  mapOfFileToContentVer.get(fileRecordId).ContentSize, 
                                            File_Type__c = mapOfFileToContentVer.get(fileRecordId).FileType,
                                           	Upload_Date__c = mapOfFileToContentVer.get(fileRecordId).CreatedDate,
                                            Uploaded_By__c = mapOfFileToContentVer.get(fileRecordId).CreatedById,
                                            File_Name__c = mapOfFileToContentVer.get(fileRecordId).Title));    
        }
        
        saveAceFiles(fileRecords);
    }
    
    public void saveAceFiles(List<ace_File__c> files){
        upsert files;
    }
}