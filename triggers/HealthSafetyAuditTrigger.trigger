trigger HealthSafetyAuditTrigger on Health_Safety_Audit__c (after delete, after insert, after update) {
	
	HealthSafetyAuditClass hsAudit = new HealthSafetyAuditClass();
	
	if(trigger.isDelete) {
		hsAudit.SetHSAuditPending(trigger.old);	
	}else {
		hsAudit.SetHSAuditPending(trigger.new);
	}
}