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
private class SoqlBuilder_Test {
	
	private static final Integer NUMBER_ACCOUNTS = 10;

    static testMethod void myUnitTest() {
    	List<Account> accounts = new List<Account>();
    	String accountIds;
    	
    	// generate accounts
    	for(Integer i = 0; i < NUMBER_ACCOUNTS; i++) {
	        Account objAccount = (Account)SmartFactory.createSObject('Account');
	        objAccount.Name = 'Test Account';
	        accounts.add(objAccount);
    	}
        insert accounts;
        
        // build a comma separated list of account ids
        for(Account myAccount : accounts) {
        	if(accountIds == NULL) {
        		accountIds = '\'' + myAccount.Id + '\'';
        	}else {
        		accountIds += ',\'' + myAccount.Id + '\'';
        	}
        }
        
		test.startTest();
		
		// build select query returning all fields
		List<SObject> results1 = SoqlBuilder.ExecuteSelectQuery('Account', 'Id IN (' + accountIds + ')');
		system.assertEquals(results1.size(), NUMBER_ACCOUNTS);
		
		// build select query returning the Id and Name ordered by Name
		List<SObject> results2 = SoqlBuilder.ExecuteSelectQuery('Id, Name', 'Account', 'Id IN (' + accountIds + ')', 'Name');
		system.assertEquals(results2.size(), NUMBER_ACCOUNTS);
		
		// build select query with invalid object name
		List<SObject> results3 = SoqlBuilder.ExecuteSelectQuery('TestObject', '1=1');
		system.assertEquals(results3, NULL);

		test.stopTest();
    }
}