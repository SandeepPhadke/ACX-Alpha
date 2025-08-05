public with sharing class Engagements {

    @testVisible
    private EngagementsDao dao;

    public Engagements(){
        this.dao = new EngagementsDao();
    }

    public Map<Id, Engagement__c> getEngagementsWithAllSubscribedOffices(Set<Id> engagementIds){
        return this.dao.fetchEngagementsWithAllSubscribedOffices(engagementIds);
    }

    public List<Engagement_Assignee__c> getMobileEmployeesByIndividualId(Set<Id> individualIds){
        return this.dao.fetchMobileEmployeesByIndividualId(individualIds);
    }
}