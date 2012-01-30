public class troubleshootingCaseClassExtension {

//for Before Insert
public void beforeNewTroubleshootingCase(List<Case> myCases){
  for (Case myCase : myCases){
  	// If initially creating a Troubleshooting Case, then set the owner to the Troubleshooting Queue
  	// and build out the picklist values
    if (myCase.RecordTypeId == troubleshootingRecordType){
      myCase.OwnerId = troubleshootingQueueId;
      myCase.Involved__c = getAllInvolvedTeamsPicklistValue();
    } 
  }
}

// for Before Update
public void beforeUpdateTroubleshootingCase(Map<Id, Case> newCaseIDtoCaseMap, Map<Id, Case> oldCaseIDtoCaseMap){
  for (Case myCase : newCaseIDtoCaseMap.values()){
  	// All cases that the Troubleshooting Queue owns should be Troubleshooting Record Type
    if (myCase.OwnerId == troubleshootingQueueId) myCase.RecordTypeId = troubleshootingRecordType;
    // build logic for transferring a Case
    try {
    	// Transferring from Non-Troubleshooting to Non-Troubleshooting
    	if (myCase.Status == 'Transferred' && transportQueueIds().contains(myCase.OwnerId) && myCase.RecordTypeId != troubleshootingRecordType){
    		myCase.RecordTypeId = teamNameToRecordTypeMap().get(troubleshootingQueueIdToNameMap.get(myCase.OwnerId)).Id;
    	}
    	// Transferring from Troubleshooting to non-Troubleshooting
    	if (myCase.Status == 'Transferred' && transportQueueIds().contains(myCase.OwnerId) && myCase.RecordTypeId == troubleshootingRecordType){
    		myCase.RecordTypeId = teamNameToRecordTypeMap().get(troubleshootingQueueIdToNameMap.get(myCase.OwnerId)).Id;
    		myCase = removeInvolvedTeams(myCase);
    	}
    }
    catch (Exception e){
    	system.debug ('*** ERROR ' + e +' ***');
    }
    // If transferring from a non-Troubleshooting Case to a Troubleshooting Case, build out the picklist values.
    if (oldCaseIDtoCaseMap.get(myCase.id).RecordTypeId != troubleshootingRecordType && newCaseIDtoCaseMap.get(myCase.id).RecordTypeId == troubleshootingRecordType){
      myCase.Involved__c = getAllInvolvedTeamsPicklistValue();
    }
  }
}

// for After Insert
public void afterNewTroubleshootingCase(List<Case> myCases){
  List<Case_Process_Team__c> newCaseProcessTeamsToInsert = new List<Case_Process_Team__c>();
  for (Case myCase : myCases){
    if (myCase.RecordTypeId == troubleshootingRecordType){
      for (Process_Team__c myProcessTeam : processTeams){
        Case_Process_Team__c caseProcessTeamToAdd = new Case_Process_Team__c(Case__c = myCase.Id, Process_Team__c = myProcessTeam.Id);
        newCaseProcessTeamsToInsert.add(caseProcessTeamToAdd);
      }       
    } 
  }
  insert newCaseProcessTeamsToInsert;
}

// for After Update
public void afterUpdateTroubleshootingCase(Map<Id, Case> newCaseIDtoCaseMap, Map<Id, Case> oldCaseIDtoCaseMap){
  Map<Id, Integer> caseCaseProcessTeamCount = new Map<Id, Integer>();
  List<Case_Process_Team__c> newCaseProcessTeams = new List<Case_Process_Team__c>();
  
  for (AggregateResult ar : 
      [SELECT Case__c
              ,count(id) total 
       FROM Case_Process_Team__c 
       WHERE Case__c IN : newCaseIDtoCaseMap.keyset() 
       GROUP BY Case__c]){
    Id i = (Id) ar.get('Case__c');
    Integer tot = (Integer) ar.get('total');
    caseCaseProcessTeamCount.put(i, tot);
  }
    
  for (Case myCase : newCaseIDtoCaseMap.values()){
      if (!caseCaseProcessTeamCount.containsKey(myCase.Id)){
        if (myCase.RecordTypeId == troubleshootingRecordType){
          for (Process_Team__c myProcessTeam : processTeams){
            Case_Process_Team__c caseProcessTeamToAdd = new Case_Process_Team__c(Case__c = myCase.Id, Process_Team__c = myProcessTeam.Id);
            newCaseProcessTeams.add(caseProcessTeamToAdd);
            caseCaseProcessTeamCount.put(myCase.Id, 1);
          }
        }
      }   
  } 
  insert newCaseProcessTeams;
}
/**

PRIVATE METHODS

**/

private Case removeInvolvedTeams (Case myCase){
	List<Case_Process_Team__c> involvedCaseProcessTeams = [SELECT Id, Involved__c FROM Case_Process_Team__c WHERE Case__c = :myCase.Id];
	delete involvedCaseProcessTeams;
	myCase.Involved__c = '';
	return myCase;
}

private Id troubleshootingRecordType = teamNameToRecordTypeMap().get('Troubleshooting').Id;

private Map<String, RecordType> teamNameToRecordTypeMap(){
	Map<String, RecordType> teamNameToRecordTypeMap = new Map<String, RecordType>();
	for (RecordType myRecordType : 
									[SELECT Id
											,Name 
                                      FROM  RecordType 
                                     WHERE  sObjectType = 'Case']){
 		teamNameToRecordTypeMap.put(myRecordType.Name, myRecordType);
	}
	return teamNameToRecordTypeMap;
}
                                
private Id troubleshootingQueueId = [SELECT Id
                                            ,Name
                                            ,(SELECT Id
                                                     ,SobjectType 
                                              FROM QueueSobjects 
                                              WHERE SobjectType = 'Case') 
                                      FROM Group 
                                      WHERE Type = 'Queue' 
                                      AND Name = 'Troubleshooting Transport Queue' LIMIT 1].Id;
                                      
private Map<Id, String> troubleshootingQueueIdToNameMap = new Map<Id, String>();

private Set<Id> transportQueueIds(){
	Set<Id> buildingTransportQueueIds = new Set<Id>();
	Set<String> transportTeamQueueNames = new Set<String>{'ADM'
														  ,'Air CPR'
														  ,'CarOps'
														  ,'Commissions'
														  ,'Fare Filing'
														  ,'Quality'
														  ,'Regional Team'
														  ,'Schedule Change'
														  ,'Settlement & Reporting'
														  ,'Ticketing'
														  ,'Training'
														  };
	
	for (Group myGroup : [SELECT Id
                                 ,Name
                                 ,(SELECT Id
                                          ,SobjectType 
                                     FROM QueueSobjects 
                                    WHERE SobjectType = 'Case') 
                            FROM Group 
                           WHERE Type = 'Queue' 
                             AND Name IN :transportTeamQueueNames]){                
   		buildingTransportQueueIds.add(myGroup.Id);
   		troubleshootingQueueIdToNameMap.put(myGroup.Id, myGroup.Name);
        }
    return buildingTransportQueueIds;                             
} 

// List of all of the Checkoff Teams. Currently 11 Teams.
private List<Process_Team__c> processTeams = [SELECT Id 
                                              FROM Process_Team__c];

// build all all possible values of Involved__c into a semicolon seperated string
private String getAllInvolvedTeamsPicklistValue(){
  String involvedTeams = '';
  Schema.DescribeFieldResult fieldResult = Case.Involved__c.getDescribe();
  List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
  for (Schema.PicklistEntry picklistEntry : picklistEntries){
    involvedTeams = involvedTeams + picklistEntry.getValue() + ';';
  }
  return involvedTeams;
}
}