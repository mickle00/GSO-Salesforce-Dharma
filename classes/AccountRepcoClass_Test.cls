@isTest
private class AccountRepcoClass_Test {

    static testMethod void myUnitTest() {
        Account myAccount = new Account (Name='TestAccount');
        insert myAccount;
        
        Repco__c myRepco = new Repco__c (Name = 'TestRepco');
        insert myRepco;
        
        Account_Repco__c myFirstAccountRepco = new Account_Repco__c (Account__c = myAccount.Id, Repco__c = myRepco.Id);
        List<Account_Repco__c> myAccountRepcos = new List<Account_Repco__c>();
        myAccountRepcos.add(myFirstAccountRepco);
        
        AccountRepcoClass accRepObj = new AccountRepcoClass();
        accRepObj.indexAccountRepcos(myAccountRepcos);
        
        //Insert to get ID so can requery to see the AccountRepcoIndexNumberField built
        insert myFirstAccountRepco;
        myFirstAccountRepco = AccountRepcoClass.findById(myFirstAccountRepco.Id);        
        system.assertEquals(myFirstAccountRepco.Account_Repco_Index_Number__c, 1);       
        
        //Add a second account Repco
        Account_Repco__c mySecondAccountRepco = new Account_Repco__c (Account__c = myAccount.Id, Repco__c = myRepco.Id);        
        myAccountRepcos = new List<Account_Repco__c>();
        myAccountRepcos.add(mySecondAccountRepco);       

        accRepObj.indexAccountRepcos(myAccountRepcos);
        
        insert mySecondAccountRepco;
        mySecondAccountRepco = AccountRepcoClass.findById(mySecondAccountRepco.Id);
        
        //Verify gets indexed correctly        
        system.assertEquals(mySecondAccountRepco.Account_Repco_Index_Number__c, 2);
                
        myAccountRepcos = new List<Account_Repco__c>();
        myAccountRepcos.add(myFirstAccountRepco);
        delete myFirstAccountRepco;
        accRepObj.reIndexAccountRepcos(myAccountRepcos);        
        
        //Verify the second account repco's index number changes to 1 after the first
        //accountrepco is deleted
        mySecondAccountRepco = AccountRepcoClass.findById(mySecondAccountRepco.Id);        
        system.assertEquals(mySecondAccountRepco.Account_Repco_Index_Number__c, 1);
                
        //test retrieving all accountrepcos for a given account
        List<Account_Repco__c> allTestAccountsRepcos = AccountRepcoClass.getAccountRepcosByAccountId(myAccount.Id);
        system.assertEquals(allTestAccountsRepcos.size(), 1);               

    }
}