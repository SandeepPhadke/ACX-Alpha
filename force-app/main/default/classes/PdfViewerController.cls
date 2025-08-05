public class PdfViewerController {
    
    @AuraEnabled(cacheable=true)
    public static String getPdfUrl(Id workRecordId) {
        Id contentDocumentId;
        for(ContentDocumentLink cdl : [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :workRecordId
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
        ]){
            contentDocumentId = cdl.ContentDocumentId;
            System.debug('contentDocumentId : ' + contentDocumentId);
        }
        if (contentDocumentId == NULL) {
            System.debug('return null : ');
            return null;
        }

        return Site.getBaseUrl() + '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
    }
}