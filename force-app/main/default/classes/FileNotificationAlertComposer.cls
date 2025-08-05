public with sharing class FileNotificationAlertComposer {
    

    @testVisible
    private static final String ALERT_INTRO = 'New Files have been added to ACX!';
    @testVisible
    private static final String ENGAGEMENT_HEADER = 'These Engagements have had new files added to them:';
    @testVisible
    private static final String INDIVIDUAL_HEADER = 'These Individuals have had new files added to them:';
    @testVisible
    private static final String ENGAGEMENT_FILES_INTERNAL = 'Files added by an Andersen user.';
    @testVisible
    private static final String ENGAGEMENT_FILES_EXTERNAL = 'Files added by a Client user.';
    @testVisible
    private static final String INDIVIDUAL_FILES_INTERNAL = 'Files added by an Andersen user.';
    @testVisible
    private static final String INDIVIDUAL_FILES_EXTERNAL = 'Files added by the Individual.';
    @testVisible
    private static final String URL_STRING = String.valueOf(URL.getOrgDomainUrl());

    private String lookbackWindow;

    public FileNotificationAlertComposer() {    }
  
    public String getAlertMessage(FileNotificationQueueEntry entry, Integer lookbackWindow){
        this.lookbackWindow = String.valueOf(lookbackWindow);

        return makeAlertMessageBody(entry);
    }

    private String makeAlertMessageBody(FileNotificationQueueEntry queueEntry){
        String emailBody = '';
        emailBody += ALERT_INTRO + '\n\n';
        emailBody = addEngagementRows(emailBody, queueEntry.engagementFiles);
        emailBody = addIndividualRows(emailBody, queueEntry.individualFiles);
        emailBody += '\n\n Go to '+URL_STRING+' to review files.';
        return emailBody;
    }

    private String addEngagementRows(String emailBody, Map<String, FileNotificationCount> engagementFiles){
        if(engagementFiles.keySet().size() > 0){
            emailBody += ENGAGEMENT_HEADER+'\n\n';
            
            for(String engagementName : engagementFiles.keySet()){
                FileNotificationCount engagementFileCount = engagementFiles.get(engagementName);

                emailBody+= engagementName+'\n';
                emailBody+= '-- '+String.valueOf(engagementFileCount.internallyAdded) + ' ' +ENGAGEMENT_FILES_INTERNAL + '\n';
                emailBody+= '-- '+String.valueOf(engagementFileCount.externallyAdded) + ' ' +ENGAGEMENT_FILES_EXTERNAL + '\n';
                emailBody+= '\n';
            }
                
        }

        return emailBody;
    }

    private String addIndividualRows(String emailBody, Map<String, FileNotificationCount> individualFiles){
          if(individualFiles.keySet().size() > 0){
            emailBody += INDIVIDUAL_HEADER+'\n\n';
            
            for(String individualName : individualFiles.keySet()){
                FileNotificationCount individualFileCount = individualFiles.get(individualName);

                emailBody+= individualName+'\n';
                emailBody+= '-- '+String.valueOf(individualFileCount.internallyAdded) + ' ' +INDIVIDUAL_FILES_INTERNAL + '\n';
                emailBody+= '-- '+String.valueOf(individualFileCount.externallyAdded) + ' ' +INDIVIDUAL_FILES_EXTERNAL + '\n';
            }
                
        }

        return emailBody;
    }
}