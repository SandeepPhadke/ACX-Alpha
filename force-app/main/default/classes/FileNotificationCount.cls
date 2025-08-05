public with sharing class FileNotificationCount {
    private static final String INTERNAL_USER_TYPE = 'Standard';
    private static final String EXTERNAL_USER_TYPE = 'CustomerSuccess';

    public Integer internallyAdded;
    public Integer externallyAdded;

    public FileNotificationCount(){
        this.internallyAdded = 0;
        this.externallyAdded = 0;

    }

    public void addFile(ace_File__c sharedFile){
        if(sharedFile.createdBy.UserType != null){
            String userType = sharedFile.createdBy.UserType;
            if(userType.equalsIgnoreCase(INTERNAL_USER_TYPE)){
                this.internallyAdded++;
            }
            if(userType.contains(EXTERNAL_USER_TYPE)){
                this.externallyAdded++;
            }
        }

        System.debug('user type not included or null, not including in our count.  To be included the UserType of the Shared file Creator must be included');
        
    }
}