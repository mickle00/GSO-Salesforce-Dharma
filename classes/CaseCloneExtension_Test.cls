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
private class CaseCloneExtension_Test {

    static testMethod void myUnitTest() {
    	RecordType objRecordType = [Select Id, Name, DeveloperName, sobjecttype From RecordType Where DeveloperName = 'Health_Safety' and SobjectType = 'Case'];
    	Case objCase = (Case)SmartFactory.createSObject('Case');
    	objCase.RecordTypeId = objRecordType.Id;
    	insert objCase;
    	
    	test.startTest();
    	
	    ApexPages.StandardController stdCon = new ApexPages.StandardController(objCase);
        CaseCloneExtension objCaseCloneExtension = new CaseCloneExtension(stdCon);

		// no languages were selected
        objCaseCloneExtension.CloneCases();
        system.assert(Apexpages.hasMessages());
        
        // confirm that there are no related cases
        List<Case> listRelatedCases = objCaseCloneExtension.RelatedCases;
        system.assertEquals(listRelatedCases.isEmpty(), true);

        // build list of selected languages
        List<SelectOption> listOptions = objCaseCloneExtension.getLanguages();
        for(SelectOption item : listOptions) {
        	objCaseCloneExtension.LanguagesSelected.add(item.getValue());
        }
        
        // clone cases
        objCaseCloneExtension.CloneCases();
        
        // confirm that child cases were created
        listRelatedCases = objCaseCloneExtension.RelatedCases;
        system.assertEquals(listRelatedCases.isEmpty(), false);
        
        test.stopTest();
    }
}