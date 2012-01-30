trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    
  CasePointOfSaleClass objPOS = new CasePointOfSaleClass();
  troubleshootingCaseClassExtension CaseEx = new  troubleshootingCaseClassExtension();
    List<Case> casesToMatchContactAndAccount = new List<Case>();
    Map<String,RecordType> recordTypeDevleoperNametoRecordType = Utilities.getRecordTypesMap('Case', true);
    
    if (trigger.isBefore && trigger.isInsert){
        for(Case thisCase : trigger.new) {
            if(thisCase.SuppliedEmail != null && 
               thisCase.SuppliedEmail != '' && 
               !thisCase.SuppliedEmail.contains('@choicehotels.com') &&
               thisCase.RecordTypeId != recordTypeDevleoperNametoRecordType.get('Support_Request').Id) {
                
                casesToMatchContactAndAccount.add(thisCase);
            }
        }
        CaseClass objCaseClass = new CaseClass();
        objCaseClass.linkAccountAndContactToCase(casesToMatchContactAndAccount);
        CaseEx.beforeNewTroubleshootingCase(trigger.new);
    }
    
    if (trigger.isBefore && trigger.isUpdate){
    CaseEx.beforeUpdateTroubleshootingCase(trigger.newMap, trigger.oldMap);
  }
    
    if (trigger.isAfter && trigger.isInsert){
        objPOS.insertCasePointsOfSaleForNewCases(trigger.new);
        CaseEx.afterNewTroubleshootingCase(trigger.new);
    }   
    
    if(trigger.isAfter && trigger.isUpdate){
    objPOS.syncCasePointsOfSale(trigger.oldMap, trigger.newMap);
    CaseEx.afterUpdateTroubleshootingCase (trigger.newMap, trigger.oldMap);
    
    if (!Utilities.hasAlreadyFiredTrigger()){
      Utilities.setAlreadyFiredTrigger();
      CaseClass objCaseClass = new CaseClass();
      objCaseClass.afterUpdateCloneAndTransferCase(trigger.newMap, trigger.oldMap);
    }     
    }
}