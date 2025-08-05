public class ContentDocumentLinkDao {

    public List<ContentDocumentLink> getLinksByLinkedEntityAndDocumentId(Set<Id> aceFileIds, Set<Id> incomingDocIds) {
        return [
            SELECT LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :aceFileIds
            AND ContentDocumentId NOT IN :incomingDocIds
        ];
    }
}