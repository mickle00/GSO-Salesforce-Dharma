public with sharing class PSGUserRoleClass {
	
	public static List<PSG_User_Role__c> findByAccount(Id accountId) {
		return [SELECT Id
                  ,Name
                  ,Role__c
                  ,Account__c
                  ,Account__r.Name
                  ,PSG_User__c
                  ,PSG_User__r.Name
                  ,PSG_User__r.Phone__c
                  ,PSG_User__r.Email__c
              FROM PSG_User_Role__c
             WHERE Account__c = :accountId
             ORDER BY Role__c ASC];
	}
	
	public static PSG_User_Role__c findByName(String psgUserRoleName) {
	  return [SELECT Id
                  ,Name
                  ,Role__c
                  ,Account__c
                  ,Account__r.Name
                  ,PSG_User__c
                  ,PSG_User__r.Name
                  ,PSG_User__r.Phone__c
                  ,PSG_User__r.Email__c
              FROM PSG_User_Role__c
             WHERE Name = :psgUserRoleName
             LIMIT 1];	
	}
	


}