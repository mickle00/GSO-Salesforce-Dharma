@isTest
private class ConnectivitySystemContactClass_Test {

    static testMethod void myUnitTest() {
    	Connectivity_System__c myConnectivitySystem = new Connectivity_System__c (Name = 'TestConnectivitySystem');
    	insert myConnectivitySystem;
    	
    	Contact myContact = new Contact (LastName = 'Test');
    	insert myContact;
    	
    	Connectivity_System_Contact__c myConnectivitySystemContact = new Connectivity_System_Contact__c(Connectivity_System__c = myConnectivitySystem.Id, Contact__c = myContact.Id);
    	insert myConnectivitySystemContact;
    	
		List<Connectivity_System_Contact__c> myConnectivitySystemContacts = ConnectivitySystemContactClass.findByConnectivitySystemId(myConnectivitySystem.Id);        
		system.assertEquals(myConnectivitySystemContacts.size(), 1);
    }
}