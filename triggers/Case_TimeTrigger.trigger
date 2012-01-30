trigger Case_TimeTrigger on Case_Time__c (before insert, before update) {
	
	CaseTimeClass caseTimeObj = new CaseTimeClass();
	BusinessHours allHours = [select Id from BusinessHours where IsDefault=true];
	
	if (trigger.isUpdate){
		for (Case_Time__c myCaseTime : trigger.New){
			if (myCaseTime.First_Handle_Time__c != null && myCaseTime.Logged_Business_Hours_Until_First_Handle__c == null){
				myCaseTime.Logged_Business_Hours_Until_First_Handle__c = BusinessHours.diff(myCaseTime.Case_Business_Hours_ID__c, myCaseTime.Case_Created_Date__c, myCaseTime.First_Handle_Time__c)/3600000.0;
				// can this be calculated with formula field??
				//myCaseTime.xLogged_Hours_Until_First_Handle__c = BusinessHours.diff(allHours.Id, myCaseTime.Case_Created_Date__c, myCaseTime.First_Handle_Time__c)/3600000.0;
			}
		}		
	}
	
	for (Case_Time__c myCaseTime : trigger.New){
		if (myCaseTime.Case_Status__c != null && myCaseTime.Case_Closed__c != null){
			myCaseTime.Current_Time_Included_in_SLA_Time__c = caseTimeObj.isStatusIncludedInSLATime(myCaseTime.Case_Status__c, myCaseTime.Case_Closed__c);
		}
		if (myCaseTime.SLA_in_Hours__c != null){
			Long businessTimeRemainingInSLA = (myCaseTime.SLA_in_Hours__c - myCaseTime.Logged_Business_Hours_Included_in_SLA__c).longValue() * 3600000L;
			DateTime statusChangeTime = myCaseTime.Most_Recent_Change__c;
			if (statusChangeTime == null) statusChangeTime = system.now();
			myCaseTime.Business_Hours_Earliest_SLA_Due_Date__c = BusinessHours.add(myCaseTime.Case_Business_Hours_ID__c,statusChangeTime, businessTimeRemainingInSLA); 
		}
	}
}