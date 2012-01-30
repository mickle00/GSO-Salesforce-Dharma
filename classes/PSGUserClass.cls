public with sharing class PSGUserClass {
	
	public static List<PSG_User__c> findAllByPSGIds(Set<Id> Ids) {
		return [SELECT Id
		              ,Name
		              ,Active__c
		              ,Email__c
		              ,Phone__c
		              ,Title__c
		          FROM PSG_User__c
		         WHERE Id IN :Ids];
	}	
	
	public static PSG_User__c findById(Id psgUserId) {
		return [SELECT Id
                  ,Name
                  ,Active__c
                  ,Email__c
                  ,Phone__c
                  ,Title__c
              FROM PSG_User__c
             WHERE Id = :PsgUserId];
  } 
	
	private static PSG_User__c findUser(String whereClause) {
		
		String soql = 'SELECT Id ' +
                  ',Name ' +
                  ',Active__c ' +
                  ',Email__c ' +
                  ',Phone__c ' +
                  ',Title__c ' +
              'FROM PSG_User__c ' +
              'WHERE ' + whereClause +
              'LIMIT 1';
     
    PSG_User__c user = Database.query(soql);
    return user;
	}

}