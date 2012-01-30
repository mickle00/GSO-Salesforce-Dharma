public with sharing class CaseTimeClass {
	
	private Map<String, Status_Time_Bucket__c> statusToTimeMap;
	
	public Map<String, Status_Time_Bucket__c> getStatusToTimeMap(){
		if (statusToTimeMap == null){
			statusToTimeMap = new Map<String, Status_Time_Bucket__c>();
			for (Status_Time_Bucket__c statusTime : Status_Time_Bucket__c.getAll().values()){
            	statusToTimeMap.put(statusTime.Status__c,statusTime);
        	}	
		}
		return statusToTimeMap;
	}
	
	public string getStatusTimeBucket(string caseStatus, boolean caseClosed){
		if (caseClosed) return 'Closed';
		if (getStatusToTimeMap().containsKey(caseStatus)){
			return getStatusToTimeMap().get(caseStatus).Time_Bucket__c;
		}
		return 'Included in SLA';
	}
	
	public boolean isStatusIncludedInSLATime (string caseStatus, boolean caseClosed){
		if (caseClosed) return false;
		if (getStatusToTimeMap().containsKey(caseStatus)){
			return getStatusToTimeMap().get(caseStatus).Included_in_SLA_Time__c;
		}
		return true;
	}
	
	public boolean isStatusIncludedInSLATime (string caseStatus, string caseClosed){
		//formula fields cant return boolean. trying to save uneccessary soql here
		if (caseClosed == 'TRUE') return false;
		return this.isStatusIncludedInSLATime(caseStatus, false);
	}
		
}