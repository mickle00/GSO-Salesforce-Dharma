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
private class AccountClass_Test {
	
	private static final Integer ITERATIONS = 200;

    static testMethod void myUnitTest() {
    	AccountClass objAccountClass = new AccountClass();

    	// get region codes
		Region__c mexico = RegionClass.FindRegionByName('Mexico & Central America');
		Region__c southAmerica = RegionClass.FindRegionByName('South America');
		Super_Region__c superRegion = SuperRegionClass.FindSuperRegionByName('LATAM');
    	
    	test.startTest();
    	
        // create accounts
        List<Account> accounts = new List<Account>();
    	for (Integer i = 0; i < ITERATIONS; i++) {
    		Account account = (Account)SmartFactory.createSObject('Account');
    		account.Region__c = mexico.Id;
    		accounts.add(account);
    	}
    	
    	objAccountClass.BeforeInsertUpdateAccount(accounts);
    	insert accounts;
    	
    	// update region to null
    	for(Account item : accounts) {
    		item.Region__c = NULL;
    	}
    	
    	objAccountClass.BeforeInsertUpdateAccount(accounts);
    	update accounts;

    	// update region to south america
    	for(Account item : accounts) {
    		item.Region__c = southAmerica.Id;
    	}
    	
    	objAccountClass.BeforeInsertUpdateAccount(accounts);
    	update accounts;
    	
    	// query accounts for super region
    	List<Account> accts = [Select Super_Region__r.Name From Account Where Id IN : accounts];
    	
    	// validate that the super region was set to LATAM
    	for(Account item : accts) {
    		System.assertEquals('LATAM', item.Super_Region__r.Name);
    	}
        
        test.stopTest();
    }
}