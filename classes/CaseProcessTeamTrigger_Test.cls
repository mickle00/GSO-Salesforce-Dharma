@isTest
private class CaseProcessTeamTrigger_Test {

    static testMethod void myUnitTest() {
		Case myCase = new Case(Subject = 'Test Case');
		insert myCase;
		
		Process_Team__c myProcessTeam = new Process_Team__c (Name = 'ADM');
		insert myProcessTeam;
		
		List<Case_Process_Team__c> myCaseProcessTeams = new List<Case_Process_Team__c>();
		Map<Id, Case_Process_Team__c> oldMap = new Map<Id, Case_Process_Team__c>();
		Map<Id, Case_Process_Team__c> newMap = new Map<Id, Case_Process_Team__c>();		 
		
		Case_Process_Team__c myCaseProcessTeam = new Case_Process_Team__c(Case__c = myCase.Id, Process_Team__c = myProcessTeam.Id);
		insert myCaseProcessTeam;
		
		myCaseProcessTeam.Involved__c = 'No';
		update myCaseProcessTeam;
		 
    }
}