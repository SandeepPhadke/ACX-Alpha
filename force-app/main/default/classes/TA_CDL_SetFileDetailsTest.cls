@isTest
public class TA_CDL_SetFileDetailsTest {

    private class ContentVersionDaoStubProvider implements System.StubProvider {
        private List<ContentVersion> mockVersions;
        
        public ContentVersionDaoStubProvider(List<ContentVersion> versions) {
            this.mockVersions = versions;
        }
        
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getContentVersionsByDocumentIds') {
                return mockVersions;
            }
            return null;
        }
    }

    private class AceFilesDaoStubProvider implements System.StubProvider {
        private List<ace_File__c> mockFiles;
        
        public AceFilesDaoStubProvider(List<ace_File__c> files) {
            this.mockFiles = files;
        }
        
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'saveAceFiles') {
                return mockFiles; 
            }
            return null;
        }
    }

    @isTest
    static void testAfterInsertLogic_ValidContentDocumentLink() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User stdUser = new User(
            Id = TestUtility.getFakeId(User.SObjectType),
            Alias = 'stdusr',
            Email = 'standarduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Standard',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testsduser001@example.com'
        );

        Id contentDocumentId = TestUtility.getFakeId(ContentDocument.SObjectType);
        ContentVersion cv = new ContentVersion(
            Id = TestUtility.getFakeId(ContentVersion.SObjectType),
             Title = 'TestFile.pdf',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Sample content'),
            ContentDocumentId = contentDocumentId
        );

        ace_File__c aceFile = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Type__c = 'Tax Equalization'
        );

        ContentDocumentLink cdl = new ContentDocumentLink(
            Id = TestUtility.getFakeId(ContentDocumentLink.SObjectType),
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = aceFile.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        ContentVersionDao cvDaoMock = (ContentVersionDao) Test.createStub(ContentVersionDao.class, new ContentVersionDaoStubProvider(new List<ContentVersion>{cv}));
        ace_FilesDao filesDaoMock = (ace_FilesDao) Test.createStub(ace_FilesDao.class, new AceFilesDaoStubProvider(new List<ace_File__c>{aceFile}));

        Test.startTest();
        TA_ContentDocumentLink_SetFileDetails testAction = new TA_ContentDocumentLink_SetFileDetails(cvDaoMock, filesDaoMock);
        testAction.AfterInsert(new List<ContentDocumentLink>{cdl});
        Test.stopTest();

        System.assertEquals(1, testAction.fileUpdates.size(), 'One file should be prepared for update');
        ace_File__c updatedFile = testAction.fileUpdates[0];
        System.assertEquals('TestFile.pdf', updatedFile.File_Name__c, 'File name should match');
       
    }

    @isTest
    static void testAfterInsertLogic_EmptyList() {
        ContentVersionDao cvDaoMock = (ContentVersionDao) Test.createStub(ContentVersionDao.class, new ContentVersionDaoStubProvider(new List<ContentVersion>()));
        ace_FilesDao filesDaoMock = (ace_FilesDao) Test.createStub(ace_FilesDao.class, new AceFilesDaoStubProvider(new List<ace_File__c>()));

        Test.startTest();
        TA_ContentDocumentLink_SetFileDetails testAction = new TA_ContentDocumentLink_SetFileDetails(cvDaoMock, filesDaoMock);
        testAction.AfterInsert(new List<ContentDocumentLink>());
        Test.stopTest();

        System.assertEquals(0, testAction.fileUpdates.size(), 'No files should be updated for empty input');
    }

    @isTest
    static void testAfterInsertLogic_NonAceFileLinkedEntity() {
        Id contentDocumentId = TestUtility.getFakeId(ContentDocument.SObjectType);
        ContentVersion cv = new ContentVersion(
            Id = TestUtility.getFakeId(ContentVersion.SObjectType),
             Title = 'TestFile.pdf',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Sample content'),
            ContentDocumentId = contentDocumentId
        );

        ContentDocumentLink cdl = new ContentDocumentLink(
            Id = TestUtility.getFakeId(ContentDocumentLink.SObjectType),
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = TestUtility.getFakeId(Account.SObjectType), 
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        ContentVersionDao cvDaoMock = (ContentVersionDao) Test.createStub(ContentVersionDao.class, new ContentVersionDaoStubProvider(new List<ContentVersion>{cv}));
        ace_FilesDao filesDaoMock = (ace_FilesDao) Test.createStub(ace_FilesDao.class, new AceFilesDaoStubProvider(new List<ace_File__c>()));

        Test.startTest();
        TA_ContentDocumentLink_SetFileDetails testAction = new TA_ContentDocumentLink_SetFileDetails(cvDaoMock, filesDaoMock);
        testAction.AfterInsert(new List<ContentDocumentLink>{cdl});
        Test.stopTest();

        System.assertEquals(0, testAction.fileUpdates.size(), 'No files should be updated for non-ace_File__c LinkedEntityId');
    }

    @isTest
    static void testAfterInsertLogic_NoMatchingContentVersion() {
        Id contentDocumentId = TestUtility.getFakeId(ContentDocument.SObjectType);
        ace_File__c aceFile = new ace_File__c(
            Id = TestUtility.getFakeId(ace_File__c.SObjectType),
            Type__c = 'Tax Equalization'
        );

        ContentDocumentLink cdl = new ContentDocumentLink(
            Id = TestUtility.getFakeId(ContentDocumentLink.SObjectType),
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = aceFile.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        ContentVersionDao cvDaoMock = (ContentVersionDao) Test.createStub(ContentVersionDao.class, new ContentVersionDaoStubProvider(new List<ContentVersion>())); 
        ace_FilesDao filesDaoMock = (ace_FilesDao) Test.createStub(ace_FilesDao.class, new AceFilesDaoStubProvider(new List<ace_File__c>{aceFile}));

        Test.startTest();
        TA_ContentDocumentLink_SetFileDetails testAction = new TA_ContentDocumentLink_SetFileDetails(cvDaoMock, filesDaoMock);
        testAction.AfterInsert(new List<ContentDocumentLink>{cdl});
        Test.stopTest();

        System.assertEquals(0, testAction.fileUpdates.size(), 'No files should be updated when no ContentVersion is found');
    }
}