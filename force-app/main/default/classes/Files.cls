public class Files {

    @testVisible
    private FilesDao dao;
    
    public Files(){
        this.dao = new FilesDao();
    }
    
    public List<ContentDocumentLink> getContentDocsLinkedToSObject(Set<Id> documentIds, String objectType){
        return this.dao.fetchContentDocumentLinksForDocumentAndObjectType(documentIds, objectType);
    }

    public List<Database.SaveResult> addNewContentDocumentLinks(List<ContentDocumentLink> cdls){
        return this.dao.insertContentDocumentLinks(cdls);
    }
    
    public List<Database.DeleteResult> removeContentDocumentLinks(Set<Id> recordIds){
        return this.dao.deleteContentDocumentLinks(recordIds);
    }
}