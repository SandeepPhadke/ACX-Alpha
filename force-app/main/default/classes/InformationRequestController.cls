public with sharing class InformationRequestController {
    @AuraEnabled
    public static List<Information_Request__c> getInformationRequests(Integer limitSize, Integer offset) {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if (profileName == 'Assignee Portal') {
            return [
            SELECT Id, Name, Work_Record_Name_Formula__c, format(Due_Date__c)
            FROM Information_Request__c
            WHERE Status__c =  'Action Required' AND Assigned_To__c = 'Mobile Employee'
            ORDER BY Due_Date__c DESC LIMIT :limitSize OFFSET :offset
            ];
        }else {
            Id currentContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            return [
            SELECT Id, Name, Work_Record_Name_Formula__c, format(Due_Date__c) 
            FROM Information_Request__c
            WHERE Client_Contact__c = :currentContactId AND Status__c =  'Action Required' AND Assigned_To__c = 'Client'
            ORDER BY Due_Date__c DESC LIMIT :limitSize OFFSET :offset
            ];
        }
        
    }
    @AuraEnabled
    public static Integer getInformationRequestCount(){
        AggregateResult results;
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        List<Information_Request__c> irList = new List<Information_Request__c>();
        if (profileName == 'Assignee Portal') {
            results = [
            SELECT Count(Id) TotalIR
            FROM Information_Request__c
            WHERE Status__c =  'Action Required' AND Assigned_To__c = 'Mobile Employee'
            ];
        }else {
            Id currentContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            results = [
            SELECT Count(Id) TotalIR
            FROM Information_Request__c
            WHERE Client_Contact__c = :currentContactId AND Status__c =  'Action Required' AND Assigned_To__c = 'Client'
            ];
        }
        Integer TotalIR = (Integer)results.get('TotalIR');
        return TotalIR;
    } 
}