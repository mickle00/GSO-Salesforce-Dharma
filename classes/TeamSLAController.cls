public class TeamSLAController {
	public Case myCase{get;set;}
	public Team_SLA__c myTeamSLA{get;set;}
	
	public TeamSLAController(ApexPages.StandardController stdController){
		string myId = stdController.getId();
		myTeamSLA = [SELECT Id, Priority__c, Team__c, Service_Level_Agreement__c FROM Team_SLA__c WHERE Id = :myId];
		myCase = new Case(RecordTypeId = '012C00000004XEY');		
		selectedTypes = new List<String>();
	}
	
	public void addCaseType(){
		selectedTypes.add(myCase.Type);
	}
	
	public List<String> selectedTypes;
	
	public List<String> getSelectedTypes(){
		return selectedTypes;
	}	
}