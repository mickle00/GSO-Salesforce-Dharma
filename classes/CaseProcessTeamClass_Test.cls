/**

DEPENDENCIES

QUEUE
Troubleshooting Transport Queue

RECORD TYPE
Troubleshooting

At least one Process_Team__c in the Database

**/

@isTest
private class CaseProcessTeamClass_Test {

    static testMethod void myUnitTest() {
		CaseProcessTeamClass objCaseProcessTeam = new CaseProcessTeamClass();
    	Map<Id, Case_Process_Team__c> oldMap = new Map<Id, Case_Process_Team__c>();
        Map<Id, Case_Process_Team__c> newMap = new Map<Id, Case_Process_Team__c>();
        List<Case_Process_Team__c> myCaseProcessTeams = new List<Case_Process_Team__c>();
        List<Case_Process_Team__c> updatedCaseProcessTeams = new List<Case_Process_Team__c>();
                
        Process_Team__c myProcessTeam = [SELECT Id FROM Process_Team__c limit 1];
        Case myCase = [SELECT Id FROM Case limit 1];
        Case_Process_Team__c beforeInsert = new Case_Process_Team__c (Case__c = myCase.Id, Process_Team__c = myProcessTeam.Id); 
       
        myCaseProcessTeams.add(beforeInsert);
        objCaseProcessTeam.beforeInsertCaseProcessTeam(myCaseProcessTeams);        
        
        
        insert myCaseProcessTeams;        

        for (Case_Process_Team__c updatedCaseProcessTeam : myCaseProcessTeams){
        	oldMap.put(updatedCaseProcessTeam.Id, updatedCaseProcessTeam);      	
        	updatedCaseProcessTeam.Involved__c = 'No';
        	updatedCaseProcessTeams.add(updatedCaseProcessTeam);
        	newMap.put(updatedCaseProcessTeam.Id, updatedCaseProcessTeam);
        }
        update updatedCaseProcessTeams;            
        objCaseProcessTeam.afterUpdateCaseProcessTeam(newMap, oldMap);
        
        for (Case_Process_Team__c updatedCaseProcessTeam : myCaseProcessTeams){
        	oldMap.put(updatedCaseProcessTeam.Id, updatedCaseProcessTeam);      	
        	updatedCaseProcessTeam.Involved__c = 'Owner';
        	updatedCaseProcessTeams.add(updatedCaseProcessTeam);
        	newMap.put(updatedCaseProcessTeam.Id, updatedCaseProcessTeam);
        }
        objCaseProcessTeam.afterUpdateCaseProcessTeam(newMap, oldMap);

    }
}