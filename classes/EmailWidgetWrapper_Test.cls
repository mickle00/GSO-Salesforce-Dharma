@isTest
private class EmailWidgetWrapper_Test {

    static testMethod void myUnitTest() {
    	string FROM_ADDRESS = 'test@test.com';
    	Set<String> TEMPLATE_FOLDERS = new Set<String>{'Test Folder'};
		
		Case myCase = new Case(Origin = 'Web', Subject = 'Test Case', Status = 'Testing');
		insert myCase;
		
		Connectivity_System__c myConnectivitySystem = new Connectivity_System__c (Name = 'TestConnectivitySystem');
		insert myConnectivitySystem;
		
		Account myAccount = new Account(Name = 'Test Hotel');
		insert myAccount;
		
		Connection__c myConnection = new Connection__c(Connectivity_System__c = myConnectivitySystem.Id, Account__c = myAccount.Id);
		insert myConnection;    	
    	
        EmailWidgetWrapper emailWidget = new EmailWidgetWrapper(myConnection, myCase.Id, TEMPLATE_FOLDERS, FROM_ADDRESS);        
        emailWidget.sendConnectivityEmail();
    }
}