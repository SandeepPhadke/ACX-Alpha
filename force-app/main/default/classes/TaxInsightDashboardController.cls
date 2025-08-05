public with sharing class TaxInsightDashboardController {
    @AuraEnabled(cacheable=true)
    public static WorkRecordSummaryWrapper getFormattedTaxSummary(String recordId) {
        System.debug('Received recordId: ' + recordId);
        if (String.isBlank(recordId)) {
            System.debug('Record ID is blank.');
            return new WorkRecordSummaryWrapper('No Record Found', null, null, null, null, null, null, null);
        }
        List<Work_Record__c> workRecords = [
            SELECT Id, Tax_Return_Summary__c, Work_Record_Contact__c, Type__c, Name, toLabel(Country__c)
            FROM Work_Record__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        if (workRecords.isEmpty()) {
            System.debug('No work record found for recordId: ' + recordId);
            return new WorkRecordSummaryWrapper('No Record Found', null, null, null, null, null, null, null);
        }
        Work_Record__c workRecord = workRecords[0];
        System.debug('WorkRecord found: ' + workRecord);
        ace_File__c sharedFile = getAceFile(recordId);
        System.debug('sharedFile found: ' + sharedFile);
        Id sharedFileId = sharedFile != null ? sharedFile.Id : null;
        String sharedFileType = sharedFile != null ? sharedFile.Type__c : null;
        User currentUser = [
            SELECT Id, Name, Email 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        System.debug('Current User: ' + currentUser.Name);
        String customLabel = System.Label.ace_TaxBreakdownPositionSummary_WRS;
        String summary = workRecord.Tax_Return_Summary__c;
        String formattedSummary = (String.isBlank(summary)) ? '' : customLabel.replace('{0}', summary);
        String WRName = workRecord.Name;
        WRName = WRName.replaceAll('\\s*\\([^)]*\\)$', '');
        String customLabelforName = System.Label.ace_TaxReturnBanner_Heading;
        String formattedName = customLabelforName.replace('{0}', WRName);
        System.debug('Formatted Name: ' + formattedName);
        String customLabelForUser = System.Label.ace_TaxReturnBanner_SubHeading;
        String formattedUserText = customLabelForUser.replace('{0}', currentUser.Name);
        System.debug('Formatted User Text: ' + formattedUserText);
        System.debug('Work Record Country: ' + workRecord.Country__c);
        return new WorkRecordSummaryWrapper(
            formattedSummary,
            workRecord.Work_Record_Contact__c,
            workRecord.Type__c,
            formattedName,
            formattedUserText,
            sharedFileId,
            sharedFileType,
            workRecord.Country__c 
        );
    }
@AuraEnabled(cacheable=true)
public static ace_File__c getAceFile(String recordId) {
    List<ace_File__c> sharedFiles = [
        SELECT Id, Type__c 
        FROM ace_File__c 
        WHERE Work_Record__c = :recordId 
        AND Type__c = 'Federal Tax Return'
        LIMIT 1
    ];
    return sharedFiles.isEmpty() ? null : sharedFiles[0];
}
    @AuraEnabled(cacheable=true)
    public static Work_Record_Document__c getWorkRecordDocument(Id recordId) {
        try {
            return [SELECT Id, Type__c, Amount__c,CurrencyIsoCode, Settlement_Type__c, Date_Due__c, Filing_Method__c,Filing_Deadline__c, State_Province_Name__c
                    FROM Work_Record_Document__c
                    WHERE Id = :recordId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Work Record Document: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Work_Record_Document__c> getWorkRecordDocumentList() {
        try {
            return  [SELECT Id, Type__c, Amount__c,CurrencyIsoCode, Settlement_Type__c, Date_Due__c, Filing_Method__c,Filing_Deadline__c, State_Province_Name__c
                    FROM Work_Record_Document__c
                    ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Work Record Document: ' + e.getMessage());
        }
    }
    public class TaxBreakdown {
        @AuraEnabled public ReturnsWrapper Returns {get; set;}
        @AuraEnabled public PaymentsWrapper Payments {get; set;}
        @AuraEnabled public List<Work_Record_Document__c> Equalization {get; set;}
        @AuraEnabled public List<Work_Record_Document__c> FBAR {get; set;}
        @AuraEnabled public Work_Record__c WorkRecord {get; set;}
        public TaxBreakdown() {
            Returns = new ReturnsWrapper();
            Payments = new PaymentsWrapper();
            Equalization = new List<Work_Record_Document__c>();
            FBAR = new List<Work_Record_Document__c>();
        }
    }
    public class ReturnsWrapper {
        @AuraEnabled public RefundWrapper Refunds;
        public ReturnsWrapper() {
            Refunds = new RefundWrapper();
        }
    }
    public class PaymentsWrapper {
        @AuraEnabled public Map<String, List<Work_Record_Document__c>> Federal {get; set;}
        @AuraEnabled public Map<String, List<Work_Record_Document__c>> State {get; set;}
        public PaymentsWrapper() {
            Federal = new Map<String, List<Work_Record_Document__c>>();
            State = new Map<String, List<Work_Record_Document__c>>();
        }
    }
    public class WorkRecordSummaryWrapper {
        @AuraEnabled public String FormattedSummary {get; set;}
        @AuraEnabled public String WorkRecordContact {get; set;}
        @AuraEnabled public String WorkRecordType {get; set;}
        @AuraEnabled public String FormattedName {get; set;} 
        @AuraEnabled public String FormattedUserText {get; set;} 
        @AuraEnabled public Id sharedFileId {get; set;} 
        @AuraEnabled public String sharedFileType {get; set;} 
        @AuraEnabled public String WorkRecordCountry {get; set;}  
        public WorkRecordSummaryWrapper(String formattedSummary, String workRecordContact, String workRecordType, 
            String formattedName, String formattedUserText, Id sharedFileId, String sharedFileType, String workRecordCountry) {
            this.FormattedSummary = formattedSummary;
            this.WorkRecordContact = workRecordContact;
            this.WorkRecordType = workRecordType;
            this.FormattedName = formattedName; 
            this.FormattedUserText = formattedUserText;
            this.sharedFileId = sharedFileId;
            this.sharedFileType = sharedFileType;
            this.WorkRecordCountry = workRecordCountry; 
        }
    }
    
    public class RefundWrapper {
        @AuraEnabled public Map<String, List<Work_Record_Document__c>> Federal {get; set;}
        @AuraEnabled public Map<String, List<Work_Record_Document__c>> State {get; set;}
        public RefundWrapper() {
            Federal = new Map<String, List<Work_Record_Document__c>>();
            State = new Map<String, List<Work_Record_Document__c>>();
        }
    }
    @AuraEnabled(cacheable=true)
    public static TaxBreakdown getTaxReturnBreakdown(Id recordId) {
        List<Work_Record_Document__c> docs = [SELECT Id,Type__c,Work_Record__r.Net_Amount_in_Pocket__c,Work_Record__r.Net_Amount_out_of_Pocket__c,Work_Record__c, Amount__c,CurrencyIsoCode, Settlement_Type__c, Date_Due__c, Filing_Method__c,Filing_Deadline__c, State_Province_Name__c
        FROM Work_Record_Document__c WHERE Work_Record__c = :recordId];
        Work_Record__c wc = [SELECT Id, Net_Amount_in_Pocket__c, Net_Amount_out_of_Pocket__c,CurrencyIsoCode FROM Work_Record__c WHERE Id = :recordId];
        TaxBreakdown taxData = new TaxBreakdown();
        taxData.WorkRecord = wc;
        for (Work_Record_Document__c doc : docs) {
            if (doc.Type__c!=null && doc.Type__c.contains('Return')) {
                if (doc.Settlement_Type__c == 'Refund') {
                    if (doc.Type__c == 'Federal_Tax_Return') {
                        if (!taxData.Returns.Refunds.Federal.containsKey('FederalF')) {
                            taxData.Returns.Refunds.Federal.put('FederalF', new List<Work_Record_Document__c>());
                        }
                        taxData.Returns.Refunds.Federal.get('FederalF').add(doc);
                    } else {
                        if (!taxData.Returns.Refunds.State.containsKey('StateS')) {
                            taxData.Returns.Refunds.State.put('StateS', new List<Work_Record_Document__c>());
                        }
                        taxData.Returns.Refunds.State.get('StateS').add(doc);
                    }
                } else if (doc.Settlement_Type__c == 'Payment') {
                    if (doc.Type__c == 'Federal_Tax_Return') {
                        if (!taxData.Payments.Federal.containsKey('FederalF')) {
                            taxData.Payments.Federal.put('FederalF', new List<Work_Record_Document__c>());
                        }
                        taxData.Payments.Federal.get('FederalF').add(doc);
                    } else {
                        if (!taxData.Payments.State.containsKey('StateS')) {
                            taxData.Payments.State.put('StateS', new List<Work_Record_Document__c>());
                        }
                        taxData.Payments.State.get('StateS').add(doc);
                    }
                }
            } else if (doc.Type__c == 'Equalization') {
                taxData.Equalization.add(doc);
            } else if (doc.Type__c == 'FBAR') {
                taxData.FBAR.add(doc);
            }
        }
        return taxData;
    }
    
}