public with sharing class RolloutStepClass {
	
	public static List<Rollout_Step__c> getRolloutStepsByConnectionId(Id connectionId){
		return [SELECT Id
                      ,Rollout_Step__c
                      ,OwnerId
                      ,Completed_Date__c
                      ,Case__c
                      ,Owner.Name
                 FROM  Rollout_Step__c
                WHERE  Connection__c = :connectionId
             order by Completed_Date__c asc nulls last];
	}
	
	public static Rollout_Step__c getRolloutStepById(Id rolloutStepId){
		return [SELECT Id
				  FROM Rollout_Step__c
				 WHERE Id = :rolloutStepId];
	}
	
    //Upserting a list touches even unchanged records. This simply pulls out the new steps and inserts them.
    public static void insertNewRolloutSteps(List<Rollout_Step__c> myRolloutSteps){
    	List<Rollout_Step__c> rolloutStepsToInsert = new List<Rollout_Step__c>();
    	for (Rollout_Step__c myRolloutStep : myRolloutSteps){
    		if (myRolloutStep.Id == null){
    			rolloutStepsToInsert.add(myRolloutStep);
    		}
    	}
    	if (rolloutStepsToInsert.size() > 0) insert rolloutStepsToInsert;    	
    }
    
    //Syncronize the Number of Chaser Fields & Connection Status on the Connection Object for HSTS Connectivity
    public static void updateConnection(List<Rollout_Step__c> myRolloutSteps){
    	Map<Id, String> connectionStatusMap = new Map<Id, String>();
	    Map<Id, Integer> mappingChasers = new Map<Id, Integer>();
	    Map<Id, Integer> enrollmentChasers = new Map<Id, Integer>();
	    
	    RecordType connectivityRolloutStepRecordType = [SELECT Id 
                                                   		  FROM RecordType 
                                                  		 WHERE sObjectType = 'Rollout_Step__c' 
                                                    	   AND DeveloperName = 'Connectivity'];
	    
	    for (Rollout_Step__c rolloutStep : myRolloutSteps){	    	
	    	if (rolloutStep.RecordTypeId == connectivityRolloutStepRecordType.Id){	    	
		        connectionStatusMap.put(rolloutStep.Connection__c, rolloutStep.Rollout_Step__c);
		        
		        if(rolloutStep.Rollout_Step__c.contains('Mapping Chaser')){
		        	if (mappingChasers.containsKey(rolloutStep.Connection__c)){
		        		mappingChasers.put(rolloutStep.Connection__c, mappingChasers.get(rolloutStep.Connection__c) + 1);
		        	} else{		        	
		            mappingChasers.put(rolloutStep.Connection__c, 1);
		        	}
		        }
		        if(rolloutStep.Rollout_Step__c.contains('Enrollment Chaser')){
		        	if (enrollmentChasers.containsKey(rolloutStep.Connection__c)){
		        		enrollmentChasers.put(rolloutStep.Connection__c, enrollmentChasers.get(rolloutStep.Connection__c) + 1);
		        	} else{	
		            enrollmentChasers.put(rolloutStep.Connection__c, 1);
		        	}
		        }
	    	}
	    }
	
	    List<Connection__c> myConnections = [SELECT Id
	                                               ,Status__c
	                                               ,Number_of_Enrollment_Chasers__c
	                                               ,Number_of_Mapping_Chasers__c 
	                                           FROM Connection__c 
	                                          WHERE Id In :connectionStatusMap.keySet()];
	    
	    for (Connection__c myConnection : myConnections){
	        myConnection.Status__c = connectionStatusMap.get(myConnection.Id);
	        if (enrollmentChasers.containsKey(myConnection.Id)){
	            myConnection.Number_of_Enrollment_Chasers__c = myConnection.Number_of_Enrollment_Chasers__c + enrollmentChasers.get(myConnection.Id);
	            myConnection.Last_Interaction__c = system.now();
	        }  
	        if (mappingChasers.containsKey(myConnection.Id)){
	            myConnection.Number_of_Mapping_Chasers__c = myConnection.Number_of_Mapping_Chasers__c + mappingChasers.get(myConnection.Id);
	            myConnection.Last_Interaction__c = system.now();
	        }
	        if (myConnection.Status__c == 'Enrollment Form Sent' || myConnection.Status__c == 'Mapping Information Sent' ){
	            myConnection.Last_Interaction__c = system.now();
	        }  
	    }
	    update myConnections;
    }

}