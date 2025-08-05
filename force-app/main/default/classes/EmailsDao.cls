public without sharing class EmailsDao {

    public Map<Id, EmailTemplate> fetchEmailTemplatesById(Set<String> emailTemplateIds){
        return new Map<Id, EmailTemplate>([SELECT Id, Name 
                                           FROM EmailTemplate 
                                           WHERE Id IN :emailTemplateIds]);
    }
}