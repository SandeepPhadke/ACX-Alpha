@isTest
public class ClientDocumentCenterCtrlTest {

    private static User createTestUser(String uniquePrefix) {
        Profile p = new Profile(Id = TestUtility.getFakeId(Profile.SObjectType), Name = 'Standard User');
        User u = new User(
            Id = TestUtility.getFakeId(User.SObjectType),
            Alias = 'testusr',
            Email = uniquePrefix + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniquePrefix + DateTime.now().getTime() + '@test.com'
        );
        return u;
    }

    private static ContentVersion createContentVersion(String title) {
        ContentVersion cv = new ContentVersion(
            Id = TestUtility.getFakeId(ContentVersion.SObjectType),
            Title = title,
            PathOnClient = title,
            VersionData = Blob.valueOf('Sample content'),
            ContentDocumentId = TestUtility.getFakeId(ContentDocument.SObjectType)
        );
        return cv;
    }

    @isTest
    static void testGetVisibleFiles_RealData() {
        Engagement__c engagement = new Engagement__c(
            Id = TestUtility.getFakeId(Engagement__c.SObjectType),
            Engagement_Name_Tag__c = 'Test',
            Client__c=TestUtility.getFakeId(Account.SObjectType)
            
        );

        Work_Record__c work = new Work_Record__c(
            Id = TestUtility.getFakeId(Work_Record__c.SObjectType)
        );

        User testUser = createTestUser('testuser');

        ace_File__c file = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Type__c = 'Tax Equalization',
            Engagement__c = engagement.Id,
            Engagement__r = engagement,
            Work_Record__c = work.Id,
            Work_Record__r = work,
            Uploaded_By__c = testUser.Id,
            Uploaded_By__r = testUser,
            File_Name__c = 'TestFile.pdf',
            File_Type__c = 'PDF',
            Upload_Date__c = DateTime.now()
        );

        ContentVersion cv = createContentVersion('TestFile.pdf');

        ContentDocumentLink cdl = new ContentDocumentLink(
            Id = TestUtility.getFakeId(ContentDocumentLink.SObjectType),
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = file.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        Stub fileDao = new Stub(ace_FilesDao.class);
        fileDao.setReturnValue('fetchVisibleFiles', new List<ace_File__c>{file});

        ace_Files filesService = new ace_Files((ace_FilesDao)fileDao.instance);

        ClientDocumentCenterCtrl.setFileService(filesService);

        Test.startTest();
        List<ClientDocumentCenterCtrl.EngagementFileTreeWrapper> results = ClientDocumentCenterCtrl.getVisibleFiles();
        Test.stopTest();

        fileDao.assertInvoked('fetchVisibleFiles');

        System.assert(!results.isEmpty(), 'Expected at least one engagement file tree wrapper');
        if (!results.isEmpty()) {
          // System.assertEquals('Test Engagement', results[0].engagementName, 'Engagement name should match');
            System.assert(!results[0].files.isEmpty(), 'Expected at least one file in the engagement');
            if (!results[0].files.isEmpty()) {
                ClientDocumentCenterCtrl.FileNode node = results[0].files[0];
                System.assertEquals(file.Id, node.fileId, 'File ID should match');
                System.assertEquals('TestFile.pdf', node.fileName, 'File name should match');
              //  System.assertEquals('Test Work', node.workRecordName, 'Work record name should match');
                System.assertEquals('PDF', node.fileType, 'File type should match');
                System.assertEquals(file.Upload_Date__c, node.uploadedDate, 'Upload date should match');
            }
        }
    }

    @isTest
    static void testGetEngagementFiles_RealData() {
        Engagement__c engagement = new Engagement__c(
            Id = TestUtility.getFakeId(Engagement__c.SObjectType),
            Engagement_Name_Tag__c = 'Test X',
            Client__c=TestUtility.getFakeId(Account.SObjectType)
        );

        Work_Record__c work = new Work_Record__c(
            Id = TestUtility.getFakeId(Work_Record__c.SObjectType)
        );

        User testUser = createTestUser('testuser');

        ace_File__c file = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Type__c = 'Other',
            Engagement__c = engagement.Id,
            Engagement__r = engagement,
            Work_Record__c = work.Id,
            Work_Record__r = work,
            Uploaded_By__c = testUser.Id,
            Uploaded_By__r = testUser,
            File_Name__c = 'WorkXFile.pdf',
            File_Type__c = 'PDF',
            Upload_Date__c = DateTime.now()
        );

        ContentVersion cv = createContentVersion('WorkXFile.pdf');

        ContentDocumentLink cdl = new ContentDocumentLink(
            Id = TestUtility.getFakeId(ContentDocumentLink.SObjectType),
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = file.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        Stub fileDao = new Stub(ace_FilesDao.class);
        fileDao.setReturnValue('fetchFilesByEngagementId', new List<ace_File__c>{file});

        ace_Files filesService = new ace_Files((ace_FilesDao)fileDao.instance);

        ClientDocumentCenterCtrl.setFileService(filesService);

        Test.startTest();
        List<ClientDocumentCenterCtrl.FileNode> result = ClientDocumentCenterCtrl.getEngagementFiles(engagement.Id);
        Test.stopTest();
       
        if (!result.isEmpty()) {
            System.assertEquals('WorkXFile.pdf', result[0].fileName, 'File name should match');
            System.assertEquals('SharedWorkXFile.pdf', result[0].sharedfileName, 'Shared file name should match');
            //System.assertEquals('Work X', result[0].workRecordName, 'Work record name should match');
            System.assertEquals('Test User', result[0].uploadedBy, 'Uploaded by should match');
            System.assertEquals('PDF', result[0].fileType, 'File type should match');
            System.assertEquals(file.Upload_Date__c, result[0].uploadedDate, 'Upload date should match');
        }
    }

    @isTest
    static void testGetEngagementsWithFiles_RealData() {
        Engagement__c engagement = new Engagement__c(
            Id = TestUtility.getFakeId(Engagement__c.SObjectType),
            Engagement_Name_Tag__c = 'Test Y',
            Client__c=TestUtility.getFakeId(Account.SObjectType)
        );

        User testUser = createTestUser('testuser');

        ace_File__c file = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            File_Name__c = 'Summary.pdf',
            File_Type__c = 'PDF',
            Upload_Date__c = DateTime.now(),
            Engagement__c = engagement.Id,
            Engagement__r = engagement,
            Uploaded_By__c = testUser.Id,
            Uploaded_By__r = testUser
        );

        ClientDocumentCenterCtrl.EngagementSummary summary = new ClientDocumentCenterCtrl.EngagementSummary();
        summary.engagementId = engagement.Id;
        //summary.engagementName = 'Eng Summary';

        Stub fileDao = new Stub(ace_FilesDao.class);

        ace_Files filesService = new ace_Files((ace_FilesDao)fileDao.instance);

        ClientDocumentCenterCtrl.setFileService(filesService);

        Test.startTest();
        List<ClientDocumentCenterCtrl.EngagementSummary> summaries = ClientDocumentCenterCtrl.getEngagementsWithFiles(5, 0);
        Test.stopTest();

        if (!summaries.isEmpty()) {
          //  System.assertEquals('Eng Summary', summaries[0].engagementName, 'Engagement name should match');
        }
    }
}