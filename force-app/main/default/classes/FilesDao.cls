public class FilesDao {

    public List<Database.DeleteResult>  deleteContentDocumentLinks(Set<Id> recordIds){
        return Database.Delete(new List<Id>(recordIds));
    }

    public List<Database.SaveResult> insertContentDocumentLinks(List<ContentDocumentLink> cdls){
        return Database.insert(cdls);
    }

    public List<ContentDocumentLink> fetchContentDocumentLinksForDocumentAndObjectType(Set<Id> documentIds, String objectType){
        // return [SELECT ContentDocumentId, LinkedEntityId
        //         FROM ContentDocumentLink 
        //         WHERE ContentDocumentId IN :documentIds 
        //         AND LinkedEntity.Type = :objectType];

        return new List<ContentDocumentLink>();
    }
}