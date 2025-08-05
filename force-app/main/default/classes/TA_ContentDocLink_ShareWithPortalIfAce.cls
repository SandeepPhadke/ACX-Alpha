public with sharing class TA_ContentDocLink_ShareWithPortalIfAce implements TriggerAction.BeforeInsert {
    
    private static final String ACE_FILE_SOBJECT_TYPE = 'ace_File__c';
    
    public TA_ContentDocLink_ShareWithPortalIfAce() {

    }

    public void BeforeInsert(List<ContentDocumentLink> newList){
        reviewFilesAndSetToVisibleIfLinkedToAceFile(newList);
    }

    @testVisible
    private List<ContentDocumentLink> reviewFilesAndSetToVisibleIfLinkedToAceFile(List<ContentDocumentLink> newList){
        for(ContentDocumentLink cdl : newList){
            if(isLinkedToAceFile(cdl)){
                cdl.Visibility = 'AllUsers';
            }
        }

        return newList;
    }

    @testVisible
    private Boolean isLinkedToAceFile(ContentDocumentLink cdl){
        Id linkedId = cdl.LinkedEntityId;
        return linkedId.getSobjectType().toString().equalsIgnoreCase(ACE_FILE_SOBJECT_TYPE);
    }
}