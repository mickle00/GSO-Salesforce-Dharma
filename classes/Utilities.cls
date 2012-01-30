public with sharing class Utilities {

	public static Map<String,RecordType> getRecordTypesMap(String objectName, Boolean useDeveloperName){
		
		Map<String,RecordType> mapRecordTypes = new Map<String,RecordType>();
		
		List<RecordType> lstRecordTypes = [Select DeveloperName
		                                         ,Id
		                                         ,Name 
		                                     From RecordType
		                                    Where RecordType.SobjectType = :objectName];
		
		if(useDeveloperName == true){
		
		  for(RecordType recType : lstRecordTypes){
			  mapRecordTypes.put(recType.DeveloperName,recType);
		  }
		} 
		else {
		  for(RecordType recType : lstRecordTypes){
        mapRecordTypes.put(recType.Name,recType);
      } 
		}
		return mapRecordTypes;
	}
	
	public static Map<String, Id> getQueueNameToIdMap(String objectName){
	  Map<String, Id> buildingMap = new Map<String, Id>();
	  for (Group myQueue : 
                        [SELECT Id
                                ,Name
                                ,(SELECT  Id
                                         ,SobjectType 
                                    FROM  QueueSobjects 
                                   WHERE SobjectType = :objectName) 
                          FROM Group 
                         WHERE Type = 'Queue']){
      buildingMap.put(myQueue.Name, myQueue.Id);        
    }
    return buildingMap;
	}
		
	public static String appendToString(String existing, String appendText) {
		
		return existing == null ? appendText : existing + appendText; 
	}
	
	public static String getCaseThreadId(String caseId) {
    return ' [ ref:' + String.valueOf(Userinfo.getOrganizationId()).substring(0,4) + 
		       String.valueOf(Userinfo.getOrganizationId()).substring(11,15) + '.' + 
		       caseId.substring(0,4) + caseId.substring(10,15) + ':ref ]';
	}
	
	public static String generateIntegrationContactKey(String email, String firstName, String lastName){
		// build the integration key in format used by Informatica 
		firstName = firstName == null ? '' : firstName;
		lastName = lastName == null ? 'No supplied Name' : lastName;
		
		return email + ':' + lastName + ':' + firstName;
	}
	
	public static String truncateField(String myFieldValue, Integer maxLength, String newLine){
		if(myFieldValue == null) return '';
		if(myFieldValue.length() < maxLength) return myFieldValue;
		
		if(maxLength == 32000) maxLength = 30000;
		
    String errorMessage = '***TRUNCATED***';
    if (newLine == '<br/>') errorMessage = '<font color="red">' + errorMessage + '</font>';
    Integer usedCharacters = (newLine + newLine + errorMessage).length();
    return myFieldValue.substring(0,maxLength-usedCharacters) + newLine + newLine + errorMessage;
  }
  
  // Static variables are local to the context of a Web request    
  // (or testMethod during a runTests call)    
  // Therefore, this variable will be initialized as false    
  // at the beginning of each Web request which accesses it.  
  private static boolean alreadyFiredTrigger = false;

  public static boolean hasAlreadyFiredTrigger() {
    return alreadyFiredTrigger;
  }
  
  public static void setAlreadyFiredTrigger() {
    // By setting the variable to true, it maintains this    
    // new value throughout the duration of the request      
    // (or testMethod)  
    alreadyFiredTrigger = true;
  }
  
  public static String listToDelimitedString(String[] values, String delimeter) {
  	if(values == null) return '';
  	system.debug(values);
  	// take a list of strings and retur
  	String delimitedString = '';
  	for(String value : values) {
  	  if(delimitedString.length() == 0) {
  	  	delimitedString = value;
  	  }
  	  else {
  	  	delimitedString = delimitedString + delimeter + ' ' + value;
  	  }
  	}
  	return delimitedString;
  }
}