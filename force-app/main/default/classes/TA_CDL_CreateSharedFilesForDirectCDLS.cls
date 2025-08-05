public with sharing class TA_CDL_CreateSharedFilesForDirectCDLS implements TriggerAction.afterInsert{

    @testVisible
    private ace_Files aFiles;

    @testVisible
    private Files files;


    @testVisible
    private Set<Id> deletes;
    @testVisible
    private List<ace_File__c> inserts;
    @testVisible
    private List<ContentDocumentLink> newCdls;

    private static final Integer CONCATENATED_KEY_LENGTH = 36;
    private static final Map<String, String> OBJECT_FIELD_RELATION_MAP = new Map<String, String>{
        'Engagement__c' => 'Engagement__c',
        'Account' => 'Individual__c'
    };

    public TA_CDL_CreateSharedFilesForDirectCDLS() {
        this.aFiles = new ace_Files();
        this.files = new Files();

        this.deletes = new Set<Id>();
        this.inserts = new List<ace_File__c>();
        this.newCdls = new List<ContentDocumentLink>();
    }

    public void afterInsert(List<ContentDocumentLink> newList){
        for(ContentDocumentLink cdl : newList){
            String relatedFieldString = getRelatedObjectField(cdl);
            if(relatedFieldString != null){
                this.inserts.add(makeSharedFileForRecord(cdl, relatedFieldString));
                this.deletes.add(cdl.Id);
            }
        }

        if(this.inserts.size() > 0){
            this.aFiles.saveNewFiles(inserts);
            this.newCdls = makeNewCdls(inserts);
            this.files.addNewContentDocumentLinks(newCdls);
            this.files.removeContentDocumentLinks(deletes);
        }
      
    }

    @testVisible 
    private List<ContentDocumentLink> makeNewCdls(List<ace_File__c> newSharedFileRecords){
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();

        for(ace_File__c file : newSharedFileRecords){
            if(file.OriginalEntityContentDocumentKey__c.length() == CONCATENATED_KEY_LENGTH){

                Id linkedEntityId = file.Id;
                Id contentDocumentId =file.OriginalEntityContentDocumentKey__c.right(18);
                
                cdls.add(new ContentDocumentLink(LinkedEntityId = linkedEntityId, ContentDocumentId = contentDocumentId));
            }
        }
        
        return cdls;
    }

    private ace_file__c makeSharedFileForRecord(ContentDocumentLink cdl, String relatedField){
        ace_File__c aFile = new ace_File__c();
     
        aFile.put(relatedField, cdl.LinkedEntityId);
        aFile.OriginalEntityContentDocumentKey__c = String.valueOf(cdl.LinkedEntityId)+String.valueOf(cdl.ContentDocumentId);
     
        return aFile;
    }

    private string getRelatedObjectField(ContentDocumentLink cdl){
        return OBJECT_FIELD_RELATION_MAP.get(getLinkedEntityObjectType(cdl));
    }

    private String getLinkedEntityObjectType(ContentDocumentLink cdl){
        Id linkedId = cdl.LinkedEntityId;
        return linkedId.getSobjectType().toString();
    }
}