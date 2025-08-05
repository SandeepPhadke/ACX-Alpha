public with sharing class ClientDocumentCenterCtrl {

    private static ace_Files fileService = new ace_Files(); 

    @TestVisible
    private static void setFileService(ace_Files mockService) {
        fileService = mockService;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EngagementFileTreeWrapper> getVisibleFiles() {
        List<ace_File__c> files = fileService.getVisibleFiles();

        Map<Id, EngagementFileTreeWrapper> engagementMap = new Map<Id, EngagementFileTreeWrapper>();

        for (ace_File__c file : files) {
            if (!engagementMap.containsKey(file.Engagement__c)) {
                EngagementFileTreeWrapper wrapper = new EngagementFileTreeWrapper();
                wrapper.engagementId = file.Engagement__c;
                wrapper.engagementName = file.Engagement__r.Display_Name__c;
                wrapper.files = new List<FileNode>();
                engagementMap.put(file.Engagement__c, wrapper);
            }

            engagementMap.get(file.Engagement__c).files.add(buildFileNode(file));
        }

        return new List<EngagementFileTreeWrapper>(engagementMap.values());
    }

    @AuraEnabled(cacheable=true)
    public static List<FileNode> getEngagementFiles(Id engagementId) {
        ace_Files fileService = new ace_Files();
        List<ace_File__c> files = fileService.getFilesByEngagementId(engagementId);

        List<FileNode> result = new List<FileNode>();
        for (ace_File__c file : files) {
            result.add(buildFileNode(file));
        }

        return result;
    }

    private static FileNode buildFileNode(ace_File__c file) {
        FileNode node = new FileNode();
        node.fileId = file.Id;
        node.fileName = file.File_Name__c;
        node.sharedfileName = file.Shared_File_Name__c;
       // node.workRecordName = file.Work_Record__r != null ? file.Work_Record__r.Name : '';
        node.uploadedBy = file.Uploaded_By__r != null ? file.Uploaded_By__r.Name : '';
        node.uploadedDate = file.Upload_Date__c;
        node.fileType = file.File_Type__c;
        return node;
    }

    @AuraEnabled(cacheable=true)
    public static List<EngagementSummary> getEngagementsWithFiles(Integer batchSize, Integer offset) {
        ace_Files fileService = new ace_Files();
        return fileService.getEngagementsWithFiles(batchSize, offset);
    }

    public class EngagementFileTreeWrapper {
        @AuraEnabled public String engagementId;
        @AuraEnabled public String engagementName;
        @AuraEnabled public List<FileNode> files;
    }

    public class FileNode {
        @AuraEnabled public String fileId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String sharedfileName;
        @AuraEnabled public String fileType;
        @AuraEnabled public String uploadedBy;
        @AuraEnabled public DateTime uploadedDate;
       @AuraEnabled public String workRecordName;
    }

    public class EngagementSummary {
        @AuraEnabled public String engagementId;
       @AuraEnabled public String engagementName;
    }
}