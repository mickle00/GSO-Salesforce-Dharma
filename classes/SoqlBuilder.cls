public with sharing class SoqlBuilder {

	public static List<SObject> ExecuteSelectQuery(String objectName, String condition) {
		
		return ExecuteSelectQuery(null, objectName, condition, null);
	}

	public static List<SObject> ExecuteSelectQuery(String fields, String objectName, String condition, String orderBy) {
		List<SObject> listSObjects = new List<SObject>();
		
		String query = BuildQuery('Select', fields, objectName, condition, orderBy);
        if(query == null) { return null; }
        
        system.debug('>>>>>>>>>> SoqlBuilder.ExecuteQuery query = ' + query);
        listSObjects = Database.query(query);
		
		return listSObjects;
	}
	
	/////////// Private Methods
	
	private static String BuildQuery(String queryType, String fields, String objectName, String condition, String orderBy) {
		String query;
		
		// get the object type		
		SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
		if(objectType == null) { return null; }

		// get list of fields
		String fieldList = GetFields(fields, objectType);
       
        // build query
        query = queryType + ' ' + fieldList + ' From ' + objectName;
        
        // include where clause
        if(condition != null && condition != '') {
        	query += ' Where ' + condition;
        }
        
        // include order by clause
        if(orderBy != null && orderBy != '') {
        	query += ' Order by ' + orderBy;
        }
        
        return query;
	}

	private static String GetFields(String fields, SObjectType objectType) {
		String strFields;
		
		if(fields == null || fields == '*') {
			
			// get list of all fields
			List<Schema.SObjectField> listFields = objectType.getDescribe().fields.getMap().values();
			
	        strFields = listFields[0].getDescribe().LocalName;
	        for (Integer i = 1; i < listFields.size(); i++) {
	            strFields += ',' + listFields[i].getDescribe().LocalName;
	        }
		}else {
			strFields = fields;
		}
		
		return strFields;
	}
}