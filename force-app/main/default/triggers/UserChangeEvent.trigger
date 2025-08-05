trigger UserChangeEvent on UserChangeEvent (after insert) {
	DisableAutomation__mdt automationSetting = DisableAutomation__mdt.getInstance('UserChangeEvent');
    
    if (automationSetting == null || automationSetting.IsActiveApex__c == true) {
        new MetadataTriggerHandler().run();
    }
}