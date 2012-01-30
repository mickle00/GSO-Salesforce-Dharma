public with sharing class ContractLoadingStepClass {
	
	public static Contract_Loading_Step__c findById(Id contractLoadingStepId) {
		
		return [SELECT Id
                  ,Contract_Checklist__c
                  ,PSG_User__c
                  ,PSG_User_Name__c
                  ,PSG_User_Role_Name__c
                  ,PSG_User_Role__c
              FROM Contract_Loading_Step__c
             WHERE Id = :contractLoadingStepId
             LIMIT 1];
	}
	
	public void newContractLoadingSteps(List<Contract_Checklist__c> checklists) {
		Map<String,Id> userRoleIdByAccountPSGUserMap = new Map<String,Id>();
		Set<Id> checklistIds = new Set<Id>();
		Set<Id> creatorIds = new Set<Id>();
		
		for(Contract_Checklist__c checklist : checklists) {
			checklistIds.add(checklist.Id);
			creatorIds.add(checklist.PSG_Checklist_Created_By__c);
		}
		List<Contract_Loading_Step__c> newSteps = new List<Contract_Loading_Step__c>();
    List<Contract_Loading_Step__c> stepsNotComplete = completeOutstandingContractLoadingStepsByContractChecklistId(checklistIds);
		for(Contract_Checklist__c checklist : checklists) {
			
		  //Contract_Loading_Step__c newStep = newContractLoadingStep(checklist.status__c, checklist.Id, this.contractReturnedToMM(checklist.Status__c) ? checklist.PSG_Checklist_Created_By__c : null);
		  Contract_Loading_Step__c newStep = newContractLoadingStep(checklist.status__c, checklist.Id, null);
		  
		  if(newStep != null) {
  		  newSteps.add(newStep);
		  } 
		}
		
		system.debug('newSteps.size()=' + newSteps.size());
		if(newSteps.size() > 0) {
			system.debug('BEFORE insert');
			insert newSteps;
		}
		
		if(stepsNotComplete.size() > 0) {
			update stepsNotComplete;
		}	
	}
	
	public List<Contract_Loading_Step__c> completeOutstandingContractLoadingStepsByContractChecklistId(Set<Id> contractChecklists) {
		List<Contract_Loading_Step__c> stepsNotComplete = [SELECT Id
		                                                         ,Contract_Checklist__c
		                                                         ,Status__c
		                                                     FROM Contract_Loading_Step__c
		                                                    WHERE Status__c <> 'Complete'
		                                                      AND Contract_Checklist__c IN :contractChecklists
		                                                    ORDER By Contract_Checklist__c];
		                                                    
	  for(Contract_Loading_Step__c step : stepsNotComplete) {
	    step.Status__c = 'Complete'; 	
	  }
		return stepsNotComplete;
	}
	
	public void marketManagerTaskComplete(List<Contract_Loading_Step__c> steps) {
		
		Set<Id> checklistIds = new Set<Id>();
		
		for(Contract_Loading_Step__c step : steps) {
			if(step.Contract_Loading_Step__c == 'Contract Returned to MM/MC-See Comments'
			  && step.Status__c == 'Completed') {
			  checklistIds.add(step.Contract_Checklist__c);
		  }
		}
		ContractChecklistClass objChecklist = new ContractChecklistClass();
	  objChecklist.updateContractChecklistStatus(checklistIds, 'Contract Returned to Loading Team');
		
	}
	
	private Contract_Loading_Step__c newContractLoadingStep(String checklistStatus, Id checklist, Id psgUser) {
		
		Contract_Loading_Step__c newStep;
		System.debug('NEW-CONTRACT-LOADINGSTEP-STATUS=' + checklistStatus);
		
		newStep = new Contract_Loading_Step__c(Status__c = 'Open'
                                          ,Contract_Loading_Step__c = checklistStatus
		                                      ,Contract_Checklist__c = checklist
		                                      ,PSG_User__c = psgUser);
	
		return newStep;
	}
	
	private Boolean contractReturnedToMM(String status) {
		return status == 'Contract Returned to MM/MC-See Comments';
	}
	
	
}