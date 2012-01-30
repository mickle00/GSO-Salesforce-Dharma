public with sharing class ContractLoadingStepAccountTeamExtension {
	private Contract_Loading_Step__c step;
	private Contract_Checklist__c checklist;
	public List<PSG_User_Role__c> memberList {get;set;}
	public List<PSG_User__c> creatorList {get;set;}
 	public Contract_Loading_Step__c myContractLoadingStep {get;set;}
	
	private ContractLoadingStepClass objContractLoadingStep = new ContractLoadingStepClass();
	private ContractChecklistClass objContractChecklist = new ContractChecklistClass();
	
  public ContractLoadingStepAccountTeamExtension(ApexPages.StandardController controller) {
    step = (Contract_Loading_Step__c)controller.getRecord();
    
    // get a handled on the step with all the fields needed for the page
    step = ContractLoadingStepClass.findById(step.Id);
    // get a copy for the section of the page that will rerender
    myContractLoadingStep = step;
    
    //get the checklist this step rolls up to  
    checklist = ContractChecklistClass.findById(step.Contract_Checklist__c);
                   
  }
  
  public Id getAccountId() {
  	if(checklist == null) {
  	  checklist = ContractChecklistClass.findById(step.Contract_Checklist__c);	
  	}
  	return checklist.Account__c;
  }
  
  public List<PSG_User_Role__c> getAccountTeamMembers() {
  	if(memberList == null) {
    	memberList = PSGUserRoleClass.findByAccount(checklist.Account__c);  
  	}
  	return memberList;   
  }
  
  public List<PSG_User__c> getChecklistCreators() {
  	if(creatorList == null) {
  		Set<Id> creatorIds = new Set<Id>();
  		creatorIds.add(checklist.PSG_Checklist_Created_By__c);
  		creatorList = PSGUserClass.findAllByPSGIds(creatorIds);
  	}
  	return creatorList;
  }
  
  public pageReference userRole() {
  	
    //PSG_User_Role__c userRole = PSGUserRoleClass.findByName(ApexPages.currentPage().getParameters().get('roleNumber'));                                  
    PSG_User__c psgUser = PSGUserClass.findById(ApexPages.currentPage().getParameters().get('psgUser'));
                                  
    //myContractLoadingStep.PSG_User_Role_Name__c = userRole.Id;
    myContractLoadingStep.PSG_User__c = psgUser.Id;
    
    update myContractLoadingStep;
    
    myContractLoadingStep = ContractLoadingStepClass.findById(myContractLoadingStep.Id);
    
    return null;
  }
}