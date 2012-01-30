public with sharing class ContactClass {
	
	public ContactClass(){}
	
	private Map<String,RecordType> contactRecordTypesMap = new Map<String,RecordType>(Utilities.getRecordTypesMap('Contact',true));
	
	public Map<String,List<Contact>> getExistingContacts(Set<String> suppliedEmails){
		
    Map<String,List<Contact>> existingContacts = new Map<String,List<Contact>>{};

    // get all contacts by email address
		List<Contact> allContacts = [Select Id
		                                   ,Email
		                                   ,FirstName
		                                   ,LastName
		                                   ,Case_Priority__c
		                               From Contact
		                              Where Contact.email IN :suppliedEmails];
		
	  for(Contact c : allContacts) {
	  	// holder for new contact list
	  	List<Contact> newContact = new List<Contact>(); 
	    // check for existing email in map
	    if(existingContacts.containsKey(c.email)) {
	    	// get list of contacts for email
	    	newContact = existingContacts.get(c.email);
	    }
	    // add contact associated with email
	    newContact.add(c);
	    // add email and new list of contacts to map
	    existingContacts.put(c.email, newContact);
	  }
		
		return existingContacts;		
	}
	
	public List<Contact> getContactsToCreate(Set<String> allEmails, Map<String,String> allEmailsAndNames, Set<String> existingContacts){
		
      List<Contact> lstContactsToAdd = new List<Contact>();
      String suppliedEmail;
      String suppliedName;
      String firstName = '';
      String lastName = 'No Supplied Name!';
      
      for(String email : allEmails) {
      	if(!existingContacts.contains(email)) {
      	  suppliedEmail = email;
      	  suppliedName = allEmailsAndNames.get(email);
      	 
      	  List<String> parsedSuppliedName = new List<String>(EmailUtilities.parseSuppliedName(suppliedName));
      	
      	  if(parsedSuppliedName.size() == 1) {
      	  	lastName = parsedSuppliedName[0];
      	  }
      	  else {
      	   firstName = parsedSuppliedName[0];
      	   lastName = parsedSuppliedName[1];
      	  }
      	  
      	  Id recordTypeId = this.isInternalContact(suppliedEmail) ? contactRecordTypesMap.get('Internal_Contact').Id : contactRecordTypesMap.get('Contact').Id;  	
      	  
      	  Contact myContact = new Contact(Email = email
      	                                 ,FirstName = firstName
      	                                 ,LastName = lastName
      	                                 ,RecordTypeId = recordTypeId
      	                                 ,Integration_Contact_Key__c = Utilities.generateIntegrationContactKey(email,firstName,LastName));
      	  
      	  lstContactsToAdd.add(myContact);	  
      	}  
      }	
      return lstContactsToAdd;    
	}
							
	public void updateAccountAndRecordType(Contact[] Contacts){
		
		Map<String,Id> accountIdsByName = this.getInternalAndExternalAccounts();

		//process the list of Contacts to update the Account
		for(Contact thisContact : Contacts) {
			//filter contacts with Email is not null and Account on the Contact is null
			if(thisContact.Email != Null) {    
			  // figure out if this is an internal or external contact
			  if(this.isInternalContact(thisContact.Email)) {
			    // if internal contact
			    thisContact.RecordTypeId = this.contactRecordTypesMap.get('Internal_Contact').Id;
			    // see if we need to update the account. only update if account is not already set
			    if(!this.hasExistingAccount(thisContact.AccountId)) {
			      thisContact.AccountId = accountIdsByName.get('Internal Contacts');
			     }
			  }
			   else { // external contacts
			     thisContact.RecordTypeId = this.contactRecordTypesMap.get('Contact').Id;
			     // see if we need to update the account
			     if(!this.hasExistingAccount(thisContact.AccountId)) {
			      thisContact.AccountId = accountIdsByName.get('External Contacts');
			     }
			   }
			  } 
			}//end of for loop	        
    }//end of updateAccount method
	
	
	private Boolean hasExistingAccount(Id accountId) {
		
		return accountId != Null;
	}
	
	private Map<String,Id> getInternalAndExternalAccounts() {
		
		//get the External and Internal Contacts
		Account[] internalAndExternal = [Select id
		                                       ,Name
							                         From Account
							                        Where Name = 'Internal Contacts' 
							                           OR Name = 'External Contacts'];
	    				        
	  Map<String, Id> accountIdsByName = new Map<String, Id> ();
	  
	  for(Account thisAccount:internalAndExternal){
	    accountIdsByName.put(thisAccount.Name, thisAccount.Id);
	  }
	  return accountIdsByName;	
	}
		
	private Boolean isInternalContact(String email) {
		// return if email come from expedia inc domain
		return email.contains('@expedia.com') ||
		       email.contains('@hotels.com') || 
		       email.contains('@venere.com') || 
		       email.contains('@hotwire.com') || 
		       email.contains('@egencia.com') || 
		       email.contains('@tripadvisor.com');
	}
}