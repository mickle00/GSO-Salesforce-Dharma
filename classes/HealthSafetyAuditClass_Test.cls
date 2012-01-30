/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class HealthSafetyAuditClass_Test {
	private static final Integer NUMBER_OF_AUDITS = 200;
	
    static testMethod void myUnitTest() {
		HealthSafetyAuditClass objHS = new HealthSafetyAuditClass();
		List<Health_Safety_Audit__c> listAudits = new List<Health_Safety_Audit__c>();   
		List<Account> listAccounts = new List<Account>();   
		List<Contact> listContacts = new List<Contact>();   

		// create accounts and contacts
		for(Integer i = 0; i < NUMBER_OF_AUDITS; i++) {
			Account objAccount = (Account)SmartFactory.createSObject('Account');
			Contact objContact = (Contact)SmartFactory.createSObject('Contact');
			listAccounts.add(objAccount);
			listContacts.add(objContact);
		}		
		insert listAccounts;
		insert listContacts;
		
		// create list of health & safety audits		
		for(Integer i = 0; i < NUMBER_OF_AUDITS; i++) {
			Health_Safety_Audit__c objAudit = (Health_Safety_Audit__c)SmartFactory.createSObject('Health_Safety_Audit__c');
			objAudit.Audit__c = 'Self Assessment';
			objAudit.Audit_Status__c = 'Pending';
			objAudit.Account__c = listAccounts.get(i).Id;
			objAudit.Contact__c = listContacts.get(i).Id;
			listAudits.add(objAudit);
		}
		
		test.startTest();
		
		objHS.SetHSAuditPending(listAudits);
		
		test.stopTest();
    }
    
    static testMethod void HSAuditPendingTriggerTest() {
		Account objAccount = (Account)SmartFactory.createSObject('Account');
		Contact objContact = (Contact)SmartFactory.createSObject('Contact');
		insert objAccount;
		insert objContact;

		Health_Safety_Audit__c objAudit = (Health_Safety_Audit__c)SmartFactory.createSObject('Health_Safety_Audit__c');
		objAudit.Audit__c = 'Self Assessment';
		objAudit.Audit_Status__c = 'Pending';
		objAudit.Account__c = objAccount.Id;
		objAudit.Contact__c = objContact.Id;
		
		test.startTest();
		
		insert objAudit;
		delete objAudit;
		
    	test.stopTest();
    }
}