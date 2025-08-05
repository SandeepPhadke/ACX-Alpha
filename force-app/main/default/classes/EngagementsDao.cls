public with sharing class EngagementsDao {
    
    public Map<Id, Engagement__c> fetchEngagementsWithAllSubscribedOffices(Set<Id> engagementIds){
        return new Map<Id, Engagement__c>([SELECT Id, Display_Name__c, Name, Coordinating_Office__c, 
                    (SELECT Id, Account__c FROM Subscribed_Office__r ) 
                FROM Engagement__c 
                WHERE Id IN :engagementIds]);
    }

    public List<Engagement_Assignee__c> fetchMobileEmployeesByIndividualId(Set<Id> individualIds){
        return [SELECT Id, Engagements__r.Coordinating_Office__c, Assignee__c FROM Engagement_Assignee__c WHERE Assignee__c IN :individualIds];
    }
}