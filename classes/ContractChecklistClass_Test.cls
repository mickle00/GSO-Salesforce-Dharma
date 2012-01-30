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
private class ContractChecklistClass_Test {
  
  static testMethod void myUnitTest() {
  	
  	String completedStatus = 'Completed';
    String newStatus = 'New';
    
    // create account
    Account testAccount = new Account(name = 'Test Account1');
    	  
    insert testAccount;
    	  
    List<Contract_Checklist__c> checklists = new List<Contract_Checklist__c>();
    //create contract checklists
    for(Integer i = 0; i < 10; i++) {
      checklists.add(new Contract_Checklist__c(Account__c = testAccount.Id
                                              ,Status__c = newStatus));
    }
    insert checklists;
      
    Contract_Checklist__c firstChecklist = checklists[0];
    Set<Id> newChecklistIds = new Set<Id>();
    for(Contract_Checklist__c checklist : checklists) {
    	newChecklistIds.add(checklist.Id);
    }
      
    checklists[2].Status__c = 'Contract Returned to MM/MC-See Comments';
    
    update checklists;
    
    
    ContractChecklistClass objChecklist = new ContractChecklistClass();
    objChecklist.updateContractChecklistStatus(newChecklistIds,completedStatus);
    
    Contract_Checklist__c checklistById = ContractChecklistClass.findById(firstChecklist.Id);
    system.assertEquals(firstChecklist.Id,checklistById.Id);
    
    List<Contract_Checklist__c> checklistsById = ContractChecklistClass.findByIds(newChecklistIds);
    system.assertEquals(checklistsById.size(),10);
    
    for(Contract_Checklist__c checklist : checklistsById) {
    	system.assertEquals(checklist.Status__c, completedStatus);
    }
    
  }
}