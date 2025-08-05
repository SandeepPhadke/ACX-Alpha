trigger ContentVersionTrigger on ContentVersion (
    before insert , after insert) {
        DisableAutomation__mdt automationSetting = DisableAutomation__mdt.getInstance('ContentVersion');

        if(automationSetting == null || automationSetting.IsActiveApex__c == true){
            new MetadataTriggerHandler().run();
        }
        
        
}