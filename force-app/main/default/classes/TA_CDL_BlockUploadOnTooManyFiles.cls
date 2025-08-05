public class TA_CDL_BlockUploadOnTooManyFiles implements TriggerAction.BeforeInsert {

    private static final String ACE_FILE_SOBJECT_TYPE = 'ace_File__c';

  
    @testVisible
    public ContentDocumentLinkDao cdlDao;


    public TA_CDL_BlockUploadOnTooManyFiles() {
      
        this.cdlDao = new ContentDocumentLinkDao();

    }

    public void BeforeInsert(List<ContentDocumentLink> newList) {
        blockIfAceFileAlreadyHasCDL(newList);
    }

    @testVisible
    private void blockIfAceFileAlreadyHasCDL(List<ContentDocumentLink> newList) {
        Set<Id> aceFileIds = new Set<Id>();
        Set<Id> incomingDocIds = new Set<Id>();

        for (ContentDocumentLink cdl : newList) {
            if (isLinkedToAceFile(cdl)) {
                aceFileIds.add(cdl.LinkedEntityId);
                if (cdl.ContentDocumentId != null) {
                    incomingDocIds.add(cdl.ContentDocumentId);
                }
            }
        }

        

        if (aceFileIds.isEmpty()) return;

        List<ContentDocumentLink> existingCdls =cdlDao.getLinksByLinkedEntityAndDocumentId(aceFileIds, incomingDocIds);

        Set<Id> aceFilesWithCDL = new Set<Id>();
        for (ContentDocumentLink existing : existingCdls) {
            aceFilesWithCDL.add(existing.LinkedEntityId);
        }


        for (ContentDocumentLink cdl : newList) {
            if (aceFilesWithCDL.contains(cdl.LinkedEntityId)) {
                cdl.addError('This is the error for shared files');

            }
        }
    }

    @testVisible
    private Boolean isLinkedToAceFile(ContentDocumentLink cdl) {
        Id linkedId = cdl.LinkedEntityId;
        return linkedId != null &&
            linkedId.getSObjectType().getDescribe().getName().equalsIgnoreCase(ACE_FILE_SOBJECT_TYPE);
    }
}