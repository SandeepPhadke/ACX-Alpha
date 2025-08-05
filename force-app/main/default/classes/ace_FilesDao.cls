public with sharing class ace_FilesDao {

     
        public List<ace_File__c> saveAceFiles(List<ace_File__c> files){
            upsert files;
            return files;
        }

      public List<ace_File__c> fetchAceFilesVisibleToExternalAudiencesById(Set<Id> aceFileIds) {
          return [
              SELECT Id, Internal_Review_Status__c 
              FROM ace_File__c
              WHERE Internal_Review_Status__c = 'Approved' 
                AND Id IN :aceFileIds
          ];
      }

      public List<ace_File__c> fetchAceFilesAddedInWindowForNotification(DateTime lookbackLimit){
        //  return [SELECT Id, Engagement__c, Engagement__r.Coordinating_Office__c, Engagement__r.Name, Individual__r.Name, Individual__c, CreatedBy.UserType, Work_Record__c, 
                      //  Subscribed_Office__c
               // FROM ace_File__c
        return [SELECT Id, Engagement__c, Engagement__r.Name,  Engagement__r.Coordinating_Office__c,Engagement__r.Display_Name__c,  Individual__r.Name, Individual__c, CreatedBy.UserType, Work_Record__c, 
                        Subscribed_Office__c, Internal_Visibility__c
                FROM ace_File__c
                WHERE 
                ((Engagement__c != null AND Individual__c = null AND Work_Record__c = null )
                OR
                (Individual__c !=null AND Engagement__c = null AND Work_Record__c = null ))
                AND CreatedDate > :lookbackLimit
                ];

      }

      public List<ace_File__c> fetchVisibleFiles() {
        //  SELECT Id, File_Name__c, Shared_File_Name__c, File_Type__c, Upload_Date__c,
                   //  Uploaded_By__r.Name, Work_Record__r.Name, Engagement__c, Engagement__r.Name
           //   FROM ace_File__c
          return [
              SELECT Id, File_Name__c, Shared_File_Name__c, File_Type__c, Upload_Date__c,
                     Uploaded_By__r.Name,  Engagement__c , Engagement__r.Display_Name__c
              FROM ace_File__c
              WHERE Uploaded_By__c != null AND Engagement__c != NULL
          ];
      }

      public List<ace_File__c> fetchFilesByEngagementId(Id engagementId) {
         // SELECT Id, File_Name__c, Shared_File_Name__c, File_Type__c, Upload_Date__c,
                    // Uploaded_By__r.Name, Work_Record__r.Name, Engagement__c
             // FROM ace_File__c
          return [
              SELECT Id, File_Name__c, Shared_File_Name__c, File_Type__c, Upload_Date__c,
                     Uploaded_By__r.Name,  Engagement__c
              FROM ace_File__c
              WHERE Engagement__c = :engagementId
          ];
      }

      public List<ClientDocumentCenterCtrl.EngagementSummary> fetchEngagementsWithFiles(Integer batchSize, Integer offset) {
          // List<AggregateResult> results = [SELECT Engagement__c engagementId, Engagement__r.Name engagementName FROM ace_File__c WHERE Engagement__c != NULLGROUP BY Engagement__c, Engagement__r.NameORDER BY Engagement__c
          List<AggregateResult> results = [
              SELECT Engagement__c engagementId
              FROM ace_File__c
              WHERE Engagement__c != NULL
              GROUP BY Engagement__c 
              ORDER BY Engagement__c
              LIMIT :batchSize
              OFFSET :offset
          ];
          
           Set<Id> engagementIds = new Set<Id>();
        for (AggregateResult ar : results) {
            if (ar.get('engagementId') != null)
                engagementIds.add((Id)ar.get('engagementId'));
        }
          Map<Id, Engagement__c> engMap = engagementIds.isEmpty() 
            ? new Map<Id, Engagement__c>() 
            : new Map<Id, Engagement__c>(
                [SELECT Id, Display_Name__c FROM Engagement__c WHERE Id IN :engagementIds]
              );

          List<ClientDocumentCenterCtrl.EngagementSummary> summaries = new List<ClientDocumentCenterCtrl.EngagementSummary>();
          for (AggregateResult ar : results) {
              Id eid = (Id)ar.get('engagementId');
              ClientDocumentCenterCtrl.EngagementSummary summary = new ClientDocumentCenterCtrl.EngagementSummary();
              summary.engagementId = String.valueOf(eid);
            summary.engagementName = (engMap.containsKey(eid) ? engMap.get(eid).Display_Name__c : null);
            summaries.add(summary);
          }
          return summaries;
      } 
  }