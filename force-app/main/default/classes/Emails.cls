public class Emails {

    @testVisible
    private EmailsDao dao;
    
    public Emails(){
        this.dao = new EmailsDao();
    }
    
    public Map<Id, EmailTemplate> getEmailTemplatesById(Set<String> emailTemplateIds){
        return this.dao.fetchEmailTemplatesById(emailTemplateIds);
    }

    public Messaging.SingleEmailMessage getRenderedEmail(String templateId, String whoId, String whatId){
        return messaging.renderStoredEmailTemplate( templateId,  whoId,  whatId);
    }
}