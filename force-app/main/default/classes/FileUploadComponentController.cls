public without sharing class FileUploadComponentController {
    @AuraEnabled
    public static void deleteFile(String contentDocumentId) {
        String fileId = contentDocumentId;
        try {
            if (String.isNotBlank(fileId)) {
                delete [SELECT Id FROM 
                        ContentDocument 
                        WHERE 
                        Id = :fileId];
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting file: ' + e.getMessage());
        }
    }
}