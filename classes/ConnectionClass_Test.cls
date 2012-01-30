@isTest
private class ConnectionClass_Test {

    static testMethod void myUnitTest() {
    	//hardcoding fake AccountId for test;
    	String psgAccountId = 'TEST000000d8XlEAAU';
        Account myAccount = new Account (Name='PSG Test', External_Account_Id__c = psgAccountId);
        insert myAccount;
        
		Connectivity_System__c myConnectivitySystem = new Connectivity_System__c (Name = 'TestConnectivitySystem');
		insert myConnectivitySystem;
		
		Connection__c myConnection = new Connection__c (Account__c = myAccount.Id
													   ,Connectivity_System__c = myConnectivitySystem.Id
													   ,Type__c = 'Type'
													   ,Status__c = 'Connected'
													   ,Platform__c = 'Platform');
													   
		insert myConnection;		
		
		//requery to get formula field
		myConnection = [SELECT Id, PSG_Account_ID__c, Type__c, Platform__c, Status__c, Integration_Connection_Key__c FROM Connection__c WHERE Id = :myConnection.Id];
		
		List<Connection__c> myConnections = new List<Connection__c>();
		myConnections.add(myConnection);
		
		ConnectionClass conObj = new ConnectionClass();
		conObj.buildConnectionIntegrationKeys(myConnections);		
		
		system.assertEquals(psgAccountId+ ':' + myConnection.Type__c + ':' + myConnection.Platform__c, myConnection.Integration_Connection_Key__c);
		
		
		myConnections = ConnectionClass.getConnectionsByAccountId(myAccount.Id);
		system.assertEquals(myConnections.size(), 1);
		
		myConnection.Type__c = 'CHANGED';
		ConnectionClass.upsertConnection(myConnection);		
		myConnection = ConnectionClass.getConnection(myConnection.Id);		
		system.assertEquals(myConnection.Type__c, 'CHANGED');
		
		myConnection = new Connection__c (Account__c = myAccount.Id
										 ,Connectivity_System__c = myConnectivitySystem.Id
										 ,Type__c = 'New'
										 ,Status__c = 'Disconnected'
										 ,Platform__c = 'Insert');
		
		ConnectionClass.upsertConnection(myConnection);
										 		   
    }
}