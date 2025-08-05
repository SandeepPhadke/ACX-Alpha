/**
 * @description Controller for handling Work Record status operations
 */
public without sharing class WorkRecordStatusController {
    @TestVisible private static Id mockIndividualId;
    @TestVisible private static String mockResponse = '{"controllerValues":{"Record Created":0,"In Progress":1,"Completed":2},' +
        '"values":[{"label":"In Progress","value":"In Progress","validFor":[1]},' +
        '{"label":"Completed","value":"Completed","validFor":[2]}]}';

    /**
     * @description Wrapper class for status step information
     */
    public class StatusStepWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isCurrent;
        @AuraEnabled public Boolean isCompleted;
    }

    /**
     * @description Wrapper class for Work Record data
     */
    public class WorkRecordWrapper {
        @AuraEnabled public String recordId;
        @AuraEnabled public String status;
        @AuraEnabled public String workRecordName;
        @AuraEnabled public String recordTypeId;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public List<StatusStepWrapper> statusSteps;
        
        public WorkRecordWrapper(Work_Record__c record, String rtName, List<StatusStepWrapper> steps) {
            this.recordId = record.Id;
            this.status = record.Milestone_for_Client__c;
            this.workRecordName = record.Name;
            this.recordTypeId = record.RecordTypeId;
            this.recordTypeName = rtName;
            this.statusSteps = steps;
        }
    }

    /**
     * @description Wrapper class for picklist entry data
     */
	@TestVisible
	private class PicklistEntryWrapper {
        public String label;
        public String value;
        public Boolean active;
        
        public PicklistEntryWrapper(String label, String value, Boolean active) {
            this.label = label;
            this.value = value;
            this.active = active;
        }
    }

    /**
     * @description Response wrapper for UI API picklist values
     */
	@TestVisible
    private class PicklistValueResponse {
        public Map<String, Integer> controllerValues;
        public String defaultValue;
        public String eTag;
        public String url;
        public List<PicklistValue> values;
    }
    
    /**
     * @description Individual picklist value from UI API
     */
	@TestVisible
    private class PicklistValue {
        public Object attributes;
        public String label;
        public String value;
        public List<Integer> validFor;
    }

    /**
     * @description Sortable wrapper for picklist entries
     */
	@TestVisible
    private class SortablePicklistEntry implements Comparable {
        public String label;
        public String value;
        public Integer sortOrder;
        
        public SortablePicklistEntry(String label, String value, Integer order) {
            this.label = label;
            this.value = value;
            this.sortOrder = order;
        }
        
        public Integer compareTo(Object compareTo) {
            SortablePicklistEntry other = (SortablePicklistEntry)compareTo;
            if (this.sortOrder == other.sortOrder) return 0;
            if (this.sortOrder > other.sortOrder) return 1;
            return -1;
        }
    }

    /**
     * @description Retrieves picklist values for all record types using UI API
     * @return Map<Id, List<PicklistEntryWrapper>> Map of record type IDs to their picklist values
     */
	@TestVisible
    private static Map<Id, List<PicklistEntryWrapper>> getRecordTypePicklists() {
        Map<Id, List<PicklistEntryWrapper>> picklistsByRecordType = new Map<Id, List<PicklistEntryWrapper>>();
        
        String objectApiName = 'Work_Record__c';
        String fieldApiName = 'Milestone_for_Client__c';
        
        List<RecordType> recordTypes = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = :objectApiName 
            AND IsActive = true
        ];
        
        // Get the instance URL using System URL
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        String sessionId = UserInfo.getSessionId();
        
        for(RecordType rt : recordTypes) {
            String responseBody;
            
            if (Test.isRunningTest()) {
                responseBody = mockResponse;
            } else {
                String url = baseUrl + '/services/data/v62.0/ui-api/object-info/' + 
                    objectApiName + '/picklist-values/' + rt.Id + '/' + fieldApiName;
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(url);
                req.setMethod('GET');
                req.setHeader('Authorization', 'Bearer ' + sessionId);
                req.setHeader('Content-Type', 'application/json');
                
                Http http = new Http();
                try {
                    HttpResponse res = http.send(req);                
                    if(res.getStatusCode() == 200) {
                        responseBody = res.getBody();
                    }
                } catch(Exception e) {
                    System.debug('Error fetching picklist values for record type ' + 
                        rt.DeveloperName + ': ' + e.getMessage());
                    continue;
                }
            }
            
            if (String.isNotBlank(responseBody)) {
                PicklistValueResponse response = (PicklistValueResponse)JSON.deserialize(
                    responseBody, PicklistValueResponse.class
                );
                
                List<SortablePicklistEntry> sortedEntries = new List<SortablePicklistEntry>();
                
                if(response.values != null) {
                    for(PicklistValue pv : response.values) {
                        // Get the minimum validFor value to determine the earliest valid stage
                        Integer minValidFor = null;
                        if(pv.validFor != null && !pv.validFor.isEmpty()) {
                            minValidFor = pv.validFor[0];
                            for(Integer validIndex : pv.validFor) {
                                if(validIndex < minValidFor) {
                                    minValidFor = validIndex;
                                }
                            }
                        }
                        
                        sortedEntries.add(new SortablePicklistEntry(
                            pv.label,
                            pv.value,
                            minValidFor
                        ));
                    }
                    
                    // Sort entries based on their validFor values
                    sortedEntries.sort();
                    
                    // Convert to PicklistEntryWrapper
                    List<PicklistEntryWrapper> entries = new List<PicklistEntryWrapper>();
                    for(SortablePicklistEntry entry : sortedEntries) {
                        entries.add(new PicklistEntryWrapper(
                            entry.label,
                            entry.value,
                            true
                        ));
                    }
                    
                    picklistsByRecordType.put(rt.Id, entries);
                }
            }
        }
        
        return picklistsByRecordType;
    }

    /**
     * @description Creates status step wrappers for a given set of picklist values
     * @param picklistValues List of picklist values to convert
     * @param currentStatus Current status value to determine step states
     * @return List<StatusStepWrapper> List of status steps
     */
	@TestVisible
    private static List<StatusStepWrapper> createStatusSteps(List<PicklistEntryWrapper> picklistValues, String currentStatus) {
        List<StatusStepWrapper> steps = new List<StatusStepWrapper>();
        Integer currentIndex = -1;
        
        // Find current status index
        for(Integer i = 0; i < picklistValues.size(); i++) {
            if(picklistValues[i].value == currentStatus) {
                currentIndex = i;
                break;
            }
        }
        
        // Create status steps
        for(Integer i = 0; i < picklistValues.size(); i++) {
            PicklistEntryWrapper entry = picklistValues[i];
            StatusStepWrapper step = new StatusStepWrapper();
            step.label = entry.label;
            step.value = entry.value;
            step.isCurrent = (i == currentIndex);
            step.isCompleted = (i < currentIndex);
            steps.add(step);
        }
        
        return steps;
    }

    /**
     * @description Sets mock assignee ID for testing
     * @param individualId ID to use for testing
     */
    @TestVisible
    public static void setmockIndividualId(Id individualId) {
        mockIndividualId = individualId;
    }

    /**
     * @description Retrieves open work records for the current user
     * @return List<WorkRecordWrapper> List of work records with their status information
     */
    @AuraEnabled(cacheable=true)
    public static List<WorkRecordWrapper> getOpenWorkRecords() {
        try {
            Id individualId = Test.isRunningTest() && mockIndividualId != null ? 
                mockIndividualId : getIndividualIdFromUserId(UserInfo.getUserId());
            
            // Get record type picklists
            Map<Id, List<PicklistEntryWrapper>> picklistsByRecordType = getRecordTypePicklists();
            Map<Id, String> recordTypeNames = new Map<Id, String>();
            
            for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Work_Record__c']) {
                recordTypeNames.put(rt.Id, rt.Name);
            }
            
            List<Work_Record__c> records = [
                SELECT Id, RecordTypeId, Status__c, Name, Individual__c, Milestone_for_Client__c
                FROM Work_Record__c
                WHERE Individual__c = :individualId AND Milestone_for_Client__c != null
                ORDER BY Year__c DESC NULLS LAST, CreatedDate DESC
            ];
            
            List<WorkRecordWrapper> wrappers = new List<WorkRecordWrapper>();
            for(Work_Record__c record : records) {
                List<StatusStepWrapper> steps = createStatusSteps(
                    picklistsByRecordType.get(record.RecordTypeId),
                    record.Milestone_for_Client__c
                );
                wrappers.add(new WorkRecordWrapper(
                    record,
                    recordTypeNames.get(record.RecordTypeId),
                    steps
                ));
            }
            return wrappers;
            
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while fetching work records: ' + e.getMessage());
        }
    }

    /**
     * @description Gets the Assignee ID for a given User ID
     * @param userId ID of the user to look up
     * @return String Assignee ID or null if not found
     */
    public static String getIndividualIdFromUserId(Id userId) {
        try {
            // Query User to get ContactId
            User user = [SELECT ContactId FROM User WHERE Id = :userId LIMIT 1];
            System.debug('UserId: ' + userId);
            System.debug('User: ' + user);

            if (user != null && user.ContactId != null) {
                Account individual = [SELECT Id FROM Account WHERE PersonContactId = :user.ContactId LIMIT 1];
                return individual.Id;
            }
			return null;
        } catch (Exception e) {
			throw new AuraHandledException('Error retrieving Assignee: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static WorkRecordWrapper getSingleWorkRecord(String recordId) {
        try {
            if (String.isBlank(recordId)) {
                throw new AuraHandledException('Record ID is required');
            }

            Map<Id, List<PicklistEntryWrapper>> picklistsByRecordType = getRecordTypePicklists();
            
            Work_Record__c record = [
                SELECT Id, RecordTypeId, Status__c, Name, Individual__c, Milestone_for_Client__c
                FROM Work_Record__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            
            String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :record.RecordTypeId LIMIT 1].Name;
            
            List<StatusStepWrapper> steps = createStatusSteps(
                picklistsByRecordType.get(record.RecordTypeId),
                record.Milestone_for_Client__c
            );
            
            return new WorkRecordWrapper(record, recordTypeName, steps);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving work record: ' + e.getMessage());
        }
    }
}