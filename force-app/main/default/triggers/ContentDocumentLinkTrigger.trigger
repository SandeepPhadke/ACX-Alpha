trigger ContentDocumentLinkTrigger on ContentDocumentLink (
    before insert, 
    after insert) {
    
    DisableAutomation__mdt automationSetting = DisableAutomation__mdt.getInstance('ContentDocumentLink');

    if(automationSetting == null || automationSetting.IsActiveApex__c == true){
        new MetadataTriggerHandler().run();
    }
}