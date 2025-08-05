public class ContentVersiondao {
    public List<ContentVersion> getContentVersionsByDocumentIds(Set<Id> contentDocumentIds) {
        return [
            SELECT ContentDocumentId, ContentSize, FileType, CreatedDate, CreatedById, Title
            FROM ContentVersion
            WHERE IsLatest = true AND ContentDocumentId IN :contentDocumentIds
        ];
    }
}