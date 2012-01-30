public with sharing class AccountContactClass {
	
	public AccountContactClass(){}
	
	public Map<String,Integer> getEmailCountsForEmails(Set<String> emails){
		system.debug('<<<<< STARTING');
		List<AggregateResult> emailCountList = [SELECT Contact__r.Email, count(id) total 
		                                          FROM Account_Contact__c 
		                                         WHERE contact__r.Email IN : emails Group By Contact__r.email];
		                                         
		Map<String,Integer> emailCount = new Map<String,Integer>();
		
		//Loop throug the results and map the email to the number of occurrences
        for (AggregateResult e : emailCountList)
        {
          String email =  (String) e.get('Email');
          Integer total = (integer) e.get('total'); 
          emailCount.put(email, total);
        }    
        
        return emailCount;
	}
	
	public Map<String,List<Account_Contact__c>> getEmailToListOfAccountContacts(List<Account_Contact__c> myAccountContacts) {
		// Map holding email to list of account contacts
		Map<String,List<Account_Contact__c>> newAccountContacts = new Map<String,List<Account_Contact__c>>();
		// List of account contacts for map
		List<Account_Contact__c> listForMap = new List<Account_Contact__c>();
		
		for (Account_Contact__c accountContact : myAccountContacts) {
			// if email is a key in map
			if(newAccountContacts.containsKey(accountContact.Contact__r.Email)) {
				// get list of account contacts
				listForMap = newAccountContacts.get(accountContact.Contact__r.Email);
			}
			// add account contact to list for map
			listForMap.add(accountContact);
			// put email and list into map
			newAccountContacts.put(accountContact.Contact__r.Email,listForMap);	
		}
		return newAccountContacts;
	}
	
	public List<Account_Contact__c> getAllByContactEmail(Set<String> emails) {
		
		List<Account_Contact__c> allAccountContacts = [SELECT Id
		                                                     ,contact__r.email
		                                                     ,contact__r.name
		                                                     ,contact__c
		                                                     ,contact__r.Case_Priority__c
		                                                     ,account__c
		                                                     ,account__r.rating
		                                                     ,account__r.name   
		                                                 FROM Account_Contact__c 
		                                                WHERE contact__r.Email IN : emails 
		                                                ORDER BY account__r.rating desc nulls first];
		                                                //need to order by desc, because the map will override as it 
		                                                //loops through
	  
	  return allAccountContacts;
	}
	
    public static List<Account_Contact__c> findByAccountId (Id myAccountId){
        return [SELECT Id
                      ,Contact__c
                      ,Contact__r.Email
                      ,Contact__r.FirstName
                      ,Contact__r.LastName 
                  FROM Account_Contact__c 
                 WHERE Account__c = :myAccountId];
    }

}