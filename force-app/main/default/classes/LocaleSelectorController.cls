public without sharing class LocaleSelectorController {

    /**
     * Map Salesforce locale codes to browser locale codes
     */
    private static Map<String, String> getBrowserLocaleMap() {
        return new Map<String, String> {
            'en_US' => 'en-US',
            'en_GB' => 'en-GB',
            'es_ES' => 'es-ES',
            'fr_FR' => 'fr-FR',
            'de_DE' => 'de-DE',
            'ja_JP' => 'ja-JP',
            'zh_CN' => 'zh-CN',
            'pt_BR' => 'pt-BR',
            'ru_RU' => 'ru-RU'
        };
    }

    /**
     * Retrieves a list of the most commonly used locale options.
     * Each locale option includes display formats for date, number, and time.
     *
     * @return List<LocaleOption> - A list of locale options for the combobox.
     */
    @AuraEnabled(cacheable=true)
    public static List<LocaleOption> getLocaleOptions() {
        List<LocaleOption> localeOptions = new List<LocaleOption>();
        Map<String, String> browserLocaleMap = getBrowserLocaleMap();

        // Define the 9 most commonly used locales with display formats
        localeOptions.add(new LocaleOption('en_US', browserLocaleMap.get('en_US'), 'MM/DD/YYYY', '1,234.56', '12-Hour'));
        localeOptions.add(new LocaleOption('en_GB', browserLocaleMap.get('en_GB'), 'DD/MM/YYYY', '1,234.56', '24-Hour'));
        localeOptions.add(new LocaleOption('es_ES', browserLocaleMap.get('es_ES'), 'DD/MM/YYYY', '1.234,56', '24-Hour'));
        localeOptions.add(new LocaleOption('fr_FR', browserLocaleMap.get('fr_FR'), 'DD/MM/YYYY', '1 234,56', '24-Hour'));
        localeOptions.add(new LocaleOption('de_DE', browserLocaleMap.get('de_DE'), 'DD.MM.YYYY', '1.234,56', '24-Hour'));
        localeOptions.add(new LocaleOption('ja_JP', browserLocaleMap.get('ja_JP'), 'YYYY/MM/DD', '1,234.56', '24-Hour'));
        localeOptions.add(new LocaleOption('zh_CN', browserLocaleMap.get('zh_CN'), 'YYYY/MM/DD', '1,234.56', '24-Hour'));
        localeOptions.add(new LocaleOption('pt_BR', browserLocaleMap.get('pt_BR'), 'DD/MM/YYYY', '1.234,56', '24-Hour'));
        localeOptions.add(new LocaleOption('ru_RU', browserLocaleMap.get('ru_RU'), 'DD.MM.YYYY', '1 234,56', '24-Hour'));

        return localeOptions;
    }

    /**
     * Updates the current user's locale setting based on the selected locale code.
     *
     * @param localeCode - The Salesforce locale code selected by the user.
     * @throws AuraHandledException - If an error occurs during the update process.
     */
    @AuraEnabled
    public static void updateUserLocale(String localeCode) {
        try {
            // Handle both internal and Experience Cloud users
            Id userId = UserInfo.getUserId();
            User currentUser;

            if (Network.getNetworkId() != null) {
                // Experience Cloud context
                currentUser = [SELECT Id, LocaleSidKey FROM User 
                             WHERE Id = :userId 
                             WITH SECURITY_ENFORCED];
            } else {
                // Internal user context
                currentUser = [SELECT Id, LocaleSidKey FROM User 
                             WHERE Id = :userId];
            }

            // Update the user's LocaleSidKey with the selected locale code
            currentUser.LocaleSidKey = localeCode;
            update currentUser;

        } catch (Exception e) {
            // Handle any exceptions and pass an error message back to the LWC
            throw new AuraHandledException('An error occurred while updating your locale: ' + e.getMessage());
        }
    }

    /**
     * Wrapper class representing a locale option.
     * Includes the Salesforce locale code and display formats for date, number, and time.
     */
    public class LocaleOption {
        @AuraEnabled public String localeCode { get; set; }
        @AuraEnabled public String browserLocale { get; set; }
        @AuraEnabled public String dateFormat { get; set; }
        @AuraEnabled public String numberFormat { get; set; }
        @AuraEnabled public String timeFormat { get; set; }
        @AuraEnabled public String displayLabel { get; set; }

        /**
         * Constructor for the LocaleOption class.
         *
         * @param localeCode - The Salesforce locale code.
         * @param browserLocale - The browser-compatible locale code.
         * @param dateFormat - The locale's date format for display.
         * @param numberFormat - The locale's number format for display.
         * @param timeFormat - The locale's time format for display.
         */
        public LocaleOption(String localeCode, String browserLocale, String dateFormat, String numberFormat, String timeFormat) {
            this.localeCode = localeCode;
            this.browserLocale = browserLocale;
            this.dateFormat = dateFormat;
            this.numberFormat = numberFormat;
            this.timeFormat = timeFormat;
            // Create a user-friendly display label combining all formats
            // this.displayLabel = String.format('{0} ({1})', 
            this.displayLabel = String.format('{1}', 
                new List<String>{ browserLocale, dateFormat + ' | ' + numberFormat + ' | ' + timeFormat });
        }
    }
}