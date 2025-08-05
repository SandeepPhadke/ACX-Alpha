@isTest
public with sharing class EmailsTest {
    
    @isTest
    private static void testGetEmailResult(){
        Id emailTemplateId = [SELECT Id From EmailTemplate LIMIT 1].Id;
        Messaging.SingleEmailMessage result;
        
        test.startTest();
        
        result = new Emails().getRenderedEmail(emailTemplateId, UserInfo.getUserId(), null);
        
        test.stopTest();
        
        System.assertNotEquals(null, result, 'expected to see a result here, not a null value.');
        
    }
    @isTest
    private static void testEmails(){
        Stub daoStub = new Stub(EmailsDao.class);
        daoStub.setReturnValue('fetchEmailTemplatesById', new Map<Id, EmailTemplate>());

        Emails emails = new Emails();
        emails.dao = (EmailsDao)daoStub.instance;

        Map<Id, EmailTemplate> result;

        test.startTest();

        result = emails.getEmailTemplatesById(new Set<String>());

        test.stopTest();

        daoStub.assertInvoked('fetchEmailTemplatesById');

    }

    @isTest
    private static void testDao(){
        EmailsDao dao = new EmailsDao();

        Map<Id, EmailTemplate> result;

        test.startTest();

        result = dao.fetchEmailTemplatesById(new Set<String>());

        test.stopTest();

        System.assert(result != null);
    }
}