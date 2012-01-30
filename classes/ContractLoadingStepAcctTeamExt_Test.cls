@isTest
private class ContractLoadingStepAcctTeamExt_Test {
	
	static testMethod void myUnitTest() {
		//Test converage for the myPage visualforce page
      PageReference pageRef = Page.ContractChecklistAccountTeam;
      Test.setCurrentPageReference(pageRef);
      
      Account newAccount = new Account (name='XYZ Organization');
      insert newAccount;
      
      PSG_User__c psgUser = new PSG_User__c(Name = 'Test User'
                                        ,Email__c = 'test@email.com'
                                        ,Active__c = true);
                                        
      insert psgUser;
      
      PSG_User__c psgUserCreator = new PSG_User__c(Name = 'Test User'
                                        ,Email__c = 'test@email.com'
                                        ,Active__c = true
                                        ,Title__c = 'Market Manager');
                                        
      insert psgUserCreator;
      
      PSG_User_Role__c userRole = new PSG_User_Role__c(Account__c = newAccount.Id
                                                      ,PSG_User__c = psgUser.Id
                                                      ,Role__c = 'Market Manger');
      insert userRole;

      Contract_Checklist__c myChecklist = new Contract_Checklist__c(Status__c = 'New'
                                                                   ,Account__c = newAccount.id
                                                                   ,PSG_Checklist_Created_By__c = psgUserCreator.Id);
                                                                   
                  

      insert myChecklist;
      
      Contract_Loading_Step__c myStep = new Contract_Loading_Step__c(Contract_Checklist__c = myChecklist.Id);
      
      insert myStep;

      ApexPages.StandardController controller = new ApexPages.standardController(myStep);
      
      // create an instance of the controller
      ContractLoadingStepAccountTeamExtension extension = new ContractLoadingStepAccountTeamExtension(controller);
      System.currentPageReference().getParameters().put('psgUser',psgUser.Id);

      Id accountId = extension.getAccountId();
      List<PSG_User_Role__c> accountTeamMembers = extension.getAccountTeamMembers();
      
      List<PSG_User__c> creators = extension.getChecklistCreators();
      extension.userRole();
	
	}

}