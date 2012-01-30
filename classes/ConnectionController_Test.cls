@isTest
private class ConnectionController_Test {
	static testMethod void myUnitTest() {
		PageReference connectivityPage = Page.ManageConnection;
		Test.setCurrentPage(connectivityPage);
				
		Case myCase = new Case(Origin = 'Web', Subject = 'Test Case', Status = 'Testing');
		insert myCase;
		
		Connectivity_System__c myConnectivitySystem = new Connectivity_System__c (Name = 'TestConnectivitySystem');
		insert myConnectivitySystem;
		
		Account myAccount = new Account(Name = 'Test Hotel');
		insert myAccount;
		
		Connection__c myConnection = new Connection__c(Connectivity_System__c = myConnectivitySystem.Id, Account__c = myAccount.Id);
		insert myConnection;
		
		ApexPages.currentPage().getParameters().put('CaseId', myCase.Id);
		ApexPages.currentPage().getParameters().put('Id', myConnection.Id);
		
		//instantiate controller after putting parameters in page
		ApexPages.StandardController connectionStandardController = new ApexPages.StandardController(new Connection__c());
		ConnectionController myController = new ConnectionController(connectionStandardController);
		
		String pageTitle = myController.getTitle();
		Boolean renderExistingConnections = myController.getRenderExistingConnections();
		Integer numberOfAccountRepcos = myController.getAccountRepcoSize();
		system.assertEquals(0, numberOfAccountRepcos);
		
		myController.addRolloutStage();
		system.assertEquals(1, myController.numberAdditionalRolloutSteps);
		myController.removeRolloutStage();
		system.assertEquals(0, myController.numberAdditionalRolloutSteps);
		
		myController.save();
		myController.createNewConnection();
		myController.NewConnection();
		myController.editConnection();
		myController.Cancel();
		myController.returnToCase();
		
		//Test to make sure that the address exists as an OrgWideEmail. Returning 0 results will throw an exception.
		//Moving before can verify the Org Wide Email, so commenting out
		
		//OrgWideEmailAddress myEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :myController.FROM_ADDRESS];
				
		system.assertEquals(ConnectionController.getCaseQueryString(myCase.Id), myController.getCaseQueryString());
	}
}