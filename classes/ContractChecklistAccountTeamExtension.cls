public with sharing class ContractChecklistAccountTeamExtension {
	public List<PSG_User_Role__c> memberList {get;set;}
	private Contract_Checklist__c checklist;
	
	public ContractChecklistAccountTeamExtension(ApexPages.StandardController controller) {
		checklist = (Contract_Checklist__c)controller.getRecord();
		
		checklist = ContractChecklistClass.findById(checklist.Id);	
	}
	
	public Id getAccountId() {
    return checklist.Account__c;
	}
	
	 public List<PSG_User_Role__c> getAccountTeamMembers() {
    if(memberList == null) {
      memberList = PSGUserRoleClass.findByAccount(checklist.Account__c);       
    }
    return memberList;   
  }

}