public with sharing class ConnectivitySystemContactClass {
	
	public static List<Connectivity_System_Contact__c> findByConnectivitySystemId (Id connectivitySystemId){
		       return [SELECT Id
							 ,Contact__r.Email
							 ,Contact__r.FirstName
							 ,Contact__r.LastName 
		    			 FROM Connectivity_System_Contact__c 
		   				WHERE Connectivity_System__c = :connectivitySystemId]; 
	}
}