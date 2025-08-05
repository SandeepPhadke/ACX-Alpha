public with sharing class TA_ContentVersion_PreventShareIfAce implements TriggerAction.BeforeInsert {
   
    private static final String ACE_FILE_SOBJECT_TYPE = 'ace_File__c';

    public TA_ContentVersion_PreventShareIfAce() {

    }

    public void beforeInsert(List<ContentVersion> newList){
        reviewFilesAndPreventFurtherSharingIfLinkedToAceFile(newList);
    }

    @testVisible
    private List<ContentVersion> reviewFilesAndPreventFurtherSharingIfLinkedToAceFile(List<ContentVersion> newList){
        for(ContentVersion cv : newList){
            System.debug(cv);
            if(isLinkedToAceFile(cv)){
                cv.SharingOption = 'R';
            }
        }

        return newList;
    }

    @testVisible
    private Boolean isLinkedToAceFile(ContentVersion cv){
        if(cv.FirstPublishLocationId != null){
			Id firstPublishedId = cv.FirstPublishLocationId;
            return firstPublishedId.getSobjectType().toString().equalsIgnoreCase(ACE_FILE_SOBJECT_TYPE);            
        }
        
        return false;  
    }
}