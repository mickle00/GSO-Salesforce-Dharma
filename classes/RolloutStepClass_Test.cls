@isTest
private class RolloutStepClass_Test {

    static testMethod void myUnitTest() {
        Account myAccount = new Account (Name='AccountTest');
        insert myAccount;
        
		Connectivity_System__c myConnectivitySystem = new Connectivity_System__c (Name = 'TestConnectivitySystem');
		insert myConnectivitySystem;
		
		Connection__c myConnection = new Connection__c (Account__c = myAccount.Id
													   ,Connectivity_System__c = myConnectivitySystem.Id
													   ,Type__c = 'Type'
													   ,Platform__c = 'Platform');
													   
		insert myConnection;
		
		Rollout_Step__c myFirstRolloutStep = new Rollout_Step__c (Connection__c = myConnection.Id, Rollout_Step__c = 'TestStep1');
		insert myFirstRolloutStep;
		
		List<Rollout_Step__c> myRolloutSteps = RolloutStepClass.getRolloutStepsByConnectionId(myConnection.Id);
		Rollout_Step__c mySecondRolloutStep = new Rollout_Step__c (Connection__c = myConnection.Id, Rollout_Step__c = 'TestStep2');
		myRolloutSteps.add(mySecondRolloutStep);
		
		RolloutStepClass.insertNewRolloutSteps(myRolloutSteps);		
		system.assertEquals(RolloutStepClass.getRolloutStepsByConnectionId(myConnection.Id).size(), 2);
		mySecondRolloutStep = RolloutStepClass.getRolloutStepById(mySecondRolloutStep.Id);		
    }
}