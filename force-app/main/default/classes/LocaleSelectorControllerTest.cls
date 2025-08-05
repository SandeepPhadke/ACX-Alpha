@isTest
public class LocaleSelectorControllerTest {

    private static String tUserAlias;

    @TestSetup
    static void setupTestData() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        // Create a test user to run the tests under
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        tUserAlias = testUser.Alias;
        // Additional test data setup can be added here if needed
    }

    /**
     * Test method for getLocaleOptions().
     * Verifies that the method returns the expected number of locale options
     * and that each option contains correct data.
     */
    @isTest
    static void testGetLocaleOptions() {
        // Run as the test user to simulate real-world usage
        User testUser = [SELECT Id FROM User WHERE FirstName='Test' and LastName='User' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(testUser) {
            // Call the method under test
            Test.startTest();
            List<LocaleSelectorController.LocaleOption> localeOptions = LocaleSelectorController.getLocaleOptions();
            Test.stopTest();

            // Assertions
            // Verify that 10 locale options are returned
            System.assertEquals(9, localeOptions.size(), 'Expected 9 locale options.');

            // Verify properties of the first locale option
            LocaleSelectorController.LocaleOption option = localeOptions[0];
            System.assertNotEquals(null, option, 'First locale option should not be null.');
            System.assertEquals('en_US', option.localeCode, 'Locale code should be en_US.');
            System.assertEquals('en-US', option.browserLocale, 'Browser locale should be en-US.');
            System.assertEquals('MM/DD/YYYY', option.dateFormat, 'Date format should be MM/DD/YYYY.');
            System.assertEquals('1,234.56', option.numberFormat, 'Number format should be 1,234.56.');
            System.assertEquals('12-Hour', option.timeFormat, 'Time format should be 12-Hour.');
            System.assertNotEquals(null, option.displayLabel, 'Display label should not be null.');
        }
    }

    /**
     * Test method for updateUserLocale() with a valid locale code.
     * Verifies that the user's LocaleSidKey is updated correctly.
     */
    @isTest
    static void testUpdateUserLocale_ValidLocale() {
        // Run as the test user
        User testUser = [SELECT Id, LocaleSidKey FROM User WHERE FirstName='Test' and LastName='User' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(testUser) {
            // Ensure the initial LocaleSidKey is different from the test value
            String initialLocale = testUser.LocaleSidKey;
            String newLocale = 'fr_FR';
            System.assertNotEquals(initialLocale, newLocale, 'Initial locale should be different from new locale.');

            // Call the method under test
            Test.startTest();
            LocaleSelectorController.updateUserLocale(newLocale);
            Test.stopTest();

            // Query the user again to get the updated value
            User updatedUser = [SELECT LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
            // Assertions
            System.assertEquals(newLocale, updatedUser.LocaleSidKey, 'User LocaleSidKey should be updated to ' + newLocale + '.');
        }
    }

    /**
     * Test method for updateUserLocale() with an invalid locale code.
     * Verifies that an AuraHandledException is thrown.
     */
    @isTest
    static void testUpdateUserLocale_InvalidLocale() {
        // Run as the test user
        User testUser = [SELECT Id FROM User WHERE FirstName='Test' and LastName='User' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(testUser) {
            // Call the method under test with an invalid locale code
            String invalidLocale = 'invalid_locale_code';
            Boolean exceptionThrown = false;
            String actualMessage = '';
            
            try {
                Test.startTest();
                LocaleSelectorController.updateUserLocale(invalidLocale);
                Test.stopTest();
            } catch (AuraHandledException e) {
                exceptionThrown = true;
                actualMessage = e.getMessage();
            }

            // Assert that an exception was thrown
            System.assert(exceptionThrown, 'AuraHandledException should be thrown for invalid locale code.');
            
            // Verify the exact error message format
            String expectedMessagePart = 'Script-thrown exception';
            System.assert(actualMessage.contains(expectedMessagePart), 
                'Expected error message to contain: ' + expectedMessagePart + 
                ' but got: ' + actualMessage);
        }
    }

    /**
     * Test method to cover the LocaleOption constructor.
     * Verifies that LocaleOption objects are constructed correctly.
     */
    @isTest
    static void testLocaleOptionConstructor() {
        // Create a new LocaleOption instance
        String localeCode = 'en_US';
        String browserLocale = 'en-US';
        String dateFormat = 'MM/DD/YYYY';
        String numberFormat = '1,234.56';
        String timeFormat = 'hh:mm a';

        LocaleSelectorController.LocaleOption option = new LocaleSelectorController.LocaleOption(
            localeCode,
            browserLocale,
            dateFormat,
            numberFormat,
            timeFormat
        );

        // Assertions
        System.assertEquals(localeCode, option.localeCode, 'Locale code should match.');
        System.assertEquals(browserLocale, option.browserLocale, 'Browser locale should match.');
        System.assertEquals(dateFormat, option.dateFormat, 'Date format should match.');
        System.assertEquals(numberFormat, option.numberFormat, 'Number format should match.');
        System.assertEquals(timeFormat, option.timeFormat, 'Time format should match.');
        System.assertNotEquals(null, option.displayLabel, 'Display label should not be null.');
        // System.assert(option.displayLabel.contains(browserLocale), 'Display label should contain the browser locale.');
        System.assert(option.displayLabel.contains(dateFormat), 'Display label should contain the date format.');
        System.assert(option.displayLabel.contains(numberFormat), 'Display label should contain the number format.');
        System.assert(option.displayLabel.contains(timeFormat), 'Display label should contain the time format.');
    }
}