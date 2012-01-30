public with sharing class EmailMessageClass {
	
	public enum enumEmailStatus{newMessage, read, replied, sent}
	
	//constructor
	public EmailMessageClass() {}
	
	public Id createEmailMessage(Id parentId, String subject, String fromAddress, String fromName,
	  String[] toAddresses, String textBody, enumEmailStatus status,Boolean incoming, String[] ccAddresses) {
	  	
	  system.debug('***EmailMessageClass.createEmailMessage before insert ***');
	
	  String[] unformattedCCAddresses;
    //if (ccAddresses != NULL){
    	unformattedCCAddresses = EmailUtilities.unformattedEmailAddresses(ccAddresses); 
    //}
    
    String[] unformattedToAddresses = EmailUtilities.unformattedEmailAddresses(toAddresses);
    
	  EmailMessage newEmail = new EmailMessage(ParentId = parentId
	                                          ,Incoming = incoming
	                                          ,Subject = subject
	                                          ,FromAddress = fromAddress
	                                          ,FromName = fromName
	                                          ,ToAddress = Utilities.listToDelimitedString(unformattedToAddresses, ';')
	                                          //,ToAddress = allTo
	                                          ,TextBody = textBody
	                                          ,MessageDate = system.now()
	                                          ,CCAddress = Utilities.listToDelimitedString(unformattedCCAddresses, ';')
	                                          //,CCAddress = allCCs
	                                          ,Status = String.valueOf(status.ordinal()));
	  
	  insert newEmail;
	  
	  return newEmail.Id;
	 
	}
}