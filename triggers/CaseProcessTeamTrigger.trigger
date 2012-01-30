trigger CaseProcessTeamTrigger on Case_Process_Team__c (after update, before insert) {
  
  CaseProcessTeamClass objCaseProcessTeam = new CaseProcessTeamClass();
  
  if (trigger.isBefore && trigger.isInsert){
    objCaseProcessTeam.beforeInsertCaseProcessTeam(trigger.new);
  }
  if (trigger.isAfter && trigger.isUpdate){
    objCaseProcessTeam.afterUpdateCaseProcessTeam(trigger.newMap, trigger.oldMap);
  }
}