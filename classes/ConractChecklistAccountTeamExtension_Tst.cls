@isTest
private class ConractChecklistAccountTeamExtension_Tst {

    static testMethod void myUnitTest() {
      //Test converage for the myPage visualforce page
      PageReference pageRef = Page.ContractChecklistAccountTeam;

      Test.setCurrentPageReference(pageRef);
      
      Account newAccount = new Account (name='XYZ Organization');
      insert newAccount;
      
      PSG_User__c psgUser = new PSG_User__c(Name = 'Test User'
                                        ,Email__c = 'test@email.com'
                                        ,Active__c = true
                                        ,Title__c = 'Market Manager');
                                        
      insert psgUser; 

      Contract_Checklist__c myChecklist = new Contract_Checklist__c(Status__c = 'New'
                                                                   ,Account__c = newAccount.id);

      insert myChecklist;

      ApexPages.StandardController controller = new ApexPages.standardController(myChecklist);

      // create an instance of the controller
      ContractChecklistAccountTeamExtension extension = new ContractChecklistAccountTeamExtension(controller);

      Id accountId = extension.getAccountId();
      List<PSG_User_Role__c> accountTeamMembers = extension.getAccountTeamMembers();

    }
}