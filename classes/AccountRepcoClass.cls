public with sharing class AccountRepcoClass {
    
    //BEFORE INSERT
    public void indexAccountRepcos (List<Account_Repco__c> myAccountRepcos){
        Set<Id> accountSet = getAccountIds(myAccountRepcos);
        Map<Id, Integer> repcosPerAccount = buildRepcosPerAccountMap(accountSet);       
        myAccountRepcos = this.updateAccountRepcos(myAccountRepcos, repcosPerAccount);      
    }
    
    //AFTER DELETE
    public void reIndexAccountRepcos(List<Account_Repco__c> myAccountRepcos){
        Set<Id> accountIdsToReIndexRepcos = getAccountIds(myAccountRepcos);
        Map<Id, Integer> repcosPerAccount = new Map<Id, Integer>();
        
        List<Account_Repco__c> accountRepcosToReIndex = [SELECT  Id
                                                                ,Account_Repco_Index_Number__c
                                                                ,Account__c 
                                                           FROM  Account_Repco__c 
                                                          WHERE  Account__c IN : accountIdsToReIndexRepcos 
                                                       order by  Account_Repco_Index_Number__c asc];
                                                       // order by Index Number, so as we go through 
                                                       // after an accountRepco is deleted, if #2 was deleted,
                                                       // #1 will stay #1, however, if number 1 is deleted
                                                       // than #2 will shift down to #1
                                                       
        
        myAccountRepcos = this.updateAccountRepcos(accountRepcosToReIndex, repcosPerAccount);           
        update myAccountRepcos;
    }
    
    public static List<Account_Repco__c> getAccountRepcosByAccountId(Id accountId){
    	return [SELECT  Id
					   ,Repco__r.Name 
				  FROM  Account_Repco__c 
				 WHERE  Account__c = :accountId];
    	
    }
    
	public static Account_Repco__c findById(Id accountRepcoId){
		return [SELECT Id
    				  ,Account_Repco_Index_Number__c
    				  ,Account__c
    			  FROM Account_Repco__c
    			 WHERE Id = :accountRepcoId];
	}   
    
    private Set<Id> getAccountIds (List<Account_Repco__c> myAccountRepcos){
        Set<Id> accountIds = new Set<Id>();
        
        for (Account_Repco__c myAccountRepco : myAccountRepcos){
            accountIds.add(myAccountRepco.Account__c);
        }
        
        return accountIds;  
    }
    
    private List<Account_Repco__c> updateAccountRepcos(List<Account_Repco__c> myAccountRepcos, Map<Id, Integer> repcosPerAccount){
        for (Account_Repco__c myAccountRepco : myAccountRepcos){
            if (repcosPerAccount.containsKey(myAccountRepco.Account__c)){               
                myAccountRepco.Account_Repco_Index_Number__c = repcosPerAccount.get(myAccountRepco.Account__c) + 1;
            }
            else {
                myAccountRepco.Account_Repco_Index_Number__c = 1;
            }
            repcosPerAccount.put(myAccountRepco.Account__c, integer.valueOf(myAccountRepco.Account_Repco_Index_Number__c));
        }
        return myAccountRepcos;
    }
    
    private Map<Id, Integer> buildRepcosPerAccountMap (Set<Id> accountSet){
        Map<Id, Integer> repcosPerAccount = new Map<Id, Integer>(); 

        List<AggregateResult> numberOfAccountRepcos = [SELECT  Account__c
                                                              ,Count(Id) total 
                                                         FROM  Account_Repco__c 
                                                        WHERE  Account__c IN :accountSet 
                                                     GROUP BY  Account__c];
                                                     
        for (AggregateResult myResult : numberOfAccountRepcos){
            Id myAccountId = (Id) myResult.get('Account__c');
            Integer myAccountRepcoCount = (Integer) myResult.get('total');
            repcosPerAccount.put(myAccountId, myAccountRepcoCount);
        }
        
        return repcosPerAccount;
    } 
}