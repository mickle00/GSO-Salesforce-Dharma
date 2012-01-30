@isTest
private class troubleshootingCaseControllerExtTest {
	private static testMethod void testTroubleshootingCaseControllerExtension() {     
	    Id rId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Troubleshooting' limit 1].id;
	    Case cs = new Case(Subject = 'Test Case', RecordTypeId = rId, Status = 'New');
	    insert cs;
	          
	    ApexPages.StandardController stdCon = new ApexPages.StandardController(cs);
	    troubleshootingCaseControllerExtension contTest = new troubleshootingCaseControllerExtension(stdCon);
	
	    contTest.getCaseId();
	    
	    contTest.getallOptions();
	    contTest.getYNList();
	    contTest.getInvolvementList();
	    contTest.getCaseProcessTeams();
	    contTest.editTeams();
	    contTest.saveTeams();
	    contTest.cancelTeams();
	    contTest.teamPreBooking();
	    contTest.teamFulfillment();
	    contTest.UpdateRecords();
	    
	    //build in assertions
  	}
}