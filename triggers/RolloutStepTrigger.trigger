trigger RolloutStepTrigger on Rollout_Step__c (after insert) {
	
	if (trigger.isAfter && trigger.isInsert){
		RolloutStepClass.updateConnection(trigger.New);
	}    
    //What if rollout step deleted? 
}