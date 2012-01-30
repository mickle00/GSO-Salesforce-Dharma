public with sharing class ContractChecklistClass {
	
	public static Contract_Checklist__c findById(Id contractChecklistId) {
		
		return [SELECT Id
                  ,Account__c
                  ,Status__c
                  ,PSG_Checklist_Created_By__c
              FROM Contract_Checklist__c
             WHERE Id = :contractChecklistId
             LIMIT 1];
	}
	
	public static List<Contract_Checklist__c> findByIds(Set<Id> checklistIds) {
	  return [SELECT Id
	                ,Account__c
                  ,Status__c
              FROM Contract_Checklist__c
             WHERE Id IN :checklistIds];	
	}
    
  public void statusChanged(List<Contract_Checklist__c> changedStatuses){
    ContractLoadingStepClass objStep = new ContractLoadingStepClass();
    objStep.newContractLoadingSteps(changedStatuses);
  }
    
  public void updateContractChecklistStatus(Set<Id> checklistIds,String status) {
        
    List<Contract_Checklist__c> checklists = ContractChecklistClass.findByIds(checklistIds);
                                                  
    for(Contract_Checklist__c checklist : checklists) {
      checklist.Status__c = status;
    }
        
    update checklists;
  }
}