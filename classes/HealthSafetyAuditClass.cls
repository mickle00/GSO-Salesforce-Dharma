public with sharing class HealthSafetyAuditClass {

	public void SetHSAuditPending(List<Health_Safety_Audit__c> hsAudits) {
		List<Contact> lstContacts = new List<Contact>();
		
		// compile list of contact Ids
		List<Id> contactIds = new List<Id>();
		for(Health_Safety_Audit__c item : hsAudits) {
			if(item.Contact__c != null) {
				contactIds.add(item.Contact__c);
			}
		}
		
		// get list of contacts with associated health and safety audits that are pending or not started
		for(Contact c : [Select (Select Id, Name, RecordTypeId, Account__c, Audit_Status__c, Audit__c, IsDeleted From Health_Safety_Audits__r Where Audit__c = 'Self Assessment' and (Audit_Status__c = 'Pending' or Audit_Status__c = 'Not Started') and IsDeleted = false) From Contact c Where Id IN : contactIds]) {
			c.HS_Audit_Pending__c = (c.Health_Safety_Audits__r.isEmpty() == false);
			lstContacts.add(c);
		}
		
		update lstContacts;
	}
}