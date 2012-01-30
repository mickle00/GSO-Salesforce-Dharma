public class CasePointOfSaleClass {
  
  //use this if trigger.isInsert....if it's insert cannot pass trigger.oldmap as it's null
  public void insertCasePointsOfSaleForNewCases(List<Case> myCases){
      List<Case_Point_of_Sale__c> junctionsToInsert = new List<Case_Point_of_Sale__c>();
      List<String> casePicklistPointsOfSale = new List<String>();
      for(Case myCase: myCases){
          string semiColonSeparatedPointsOfSale = myCase.Points_of_Sale__c;
          if (myCase.Points_of_Sale__c != NULL) casePicklistPointsOfSale = semiColonSeparatedPointsOfSale.split(';');
          for (String singlePicklistPointOfSale : casePicklistPointsOfSale){
              Case_Point_of_Sale__c newCasePointOfSale = new Case_Point_of_Sale__c(Case__c = myCase.id, Travel_Product__c = getTravelProductId(singlePicklistPointOfSale));
              // trap incase it couldn't find anything in the map.
              if(newCasePointOfSale.Travel_Product__c != NULL) junctionsToInsert.add(newCasePointOfSale);   
          }
      }
      insert junctionsToInsert;
  } 

  //use this is if trigger.isUpdate. Passses both the trigger.newMap and trigger.oldMap to compare the values
  // Make sure that when the Points of Sale picklist values change, the junction table stays in sync

  public void syncCasePointsOfSale(Map<Id, Case> oldCaseIdtoCaseMap, Map<Id, Case> newCaseIdtoCaseMap){

      List<Case_Point_of_Sale__c> casePointsOfSaleToInsert = new List<Case_Point_of_Sale__c>();
      List<Case_Point_of_Sale__c> casePointsOfSaleToDelete = new List<Case_Point_of_Sale__c>(); 
    
      List<Case_Point_of_Sale__c> currentCasePointsofSaleList =  [SELECT 
                                                                  Id
                                                                  ,Case__c
                                                                  ,Travel_Product__r.Name
                                                                  ,Travel_Product__r.Brand__c
                                                                  ,Travel_Product__r.TPID__c // always need to query, so we can bulid the buildKeyForPicklistValue
                                                                  FROM Case_Point_of_Sale__c 
                                                                  WHERE Case__c IN: newCaseIdtoCaseMap.keyset()];

      for (Case myCase : newCaseIdtoCaseMap.values()){      
          if(newCaseIdtoCaseMap.get(myCase.id).Points_of_Sale__c == oldCaseIdtoCaseMap.get(myCase.id).Points_of_Sale__c){
              system.debug('No changes were made to the Points of Sale for Case: ' + myCase);
          }
          else{
            //build a list of the current Picklist Values
            List<String> currentPointOfSalePicklistValues = new List<String>();
            // because sets MUST be unique, we can compare the Set of New Picklist Values with Old Picklist Values, and use .removeAll() to extract the overlap.
                Set<String> currentPointOfSalePicklistValuesSet = new Set<String>();
                if (myCase.Points_of_Sale__c != NULL) currentPointOfSalePicklistValues = myCase.Points_of_Sale__c.split(';');
                currentPointOfSalePicklistValuesSet.addAll(currentPointOfSalePicklistValues);
                
                //build a unique set of old picklist values
                List<String> oldPointOfSalePicklistValues = new List<String>();
                if (oldCaseIdtoCaseMap.get(myCase.id).Points_of_Sale__c != NULL) oldPointOfSalePicklistValues = oldCaseIdtoCaseMap.get(myCase.id).Points_of_Sale__c.split(';');
                Set<String> oldPointOfSalePicklistValuesSet = new Set<String>();
                oldPointOfSalePicklistValuesSet.addAll(oldPointOfSalePicklistValues);           
                
                //compare sets to insert CasePointOfSales for picklist values that have been added
                Set<String> casePointsOfSaletoAddSet = new Set<String>();
                // Clone the set, so that we don't modify the original
                casePointsOfSaletoAddSet = currentPointOfSalePicklistValuesSet.clone();
                casePointsOfSaletoAddSet.removeAll(oldPointOfSalePicklistValuesSet);
                
                //compare sets to delete CasePointOfSales that have been removed from the picklist
                Set<String> casePointsofSaletoDeleteSet = new Set<String>();
                // Clone the set, so that we don't modify the original
                casePointsofSaletoDeleteSet = oldPointOfSalePicklistValuesSet.clone();
                casePointsofSaletoDeleteSet.removeAll(currentPointOfSalePicklistValuesSet);
                
                //add the new CasePointOfSales records into a list, for mass DML
                for (String newPicklistValue : casePointsOfSaletoAddSet){
                    Case_Point_of_Sale__c newCasePointOfSale = new Case_Point_of_Sale__c(Case__c = myCase.id, Travel_Product__c = getTravelProductId(newPicklistValue));
                    if(newCasePointOfSale.Case__c != NULL && newCasePointOfSale.Travel_Product__c != NULL) casePointsOfSaleToInsert.add(newCasePointOfSale);
                }
                
                //add the CasePointOfSales records we are going to delete into a list, for mass DML
                //is probably a better way of doing this...
                for (String removedPicklistValue : casePointsofSaletoDeleteSet){                
                  for (Case_Point_of_Sale__c casePointofSale : currentCasePointsofSaleList){
                    String primaryKeyforPicklist = buildKeyForPicklistValue(casePointofSale.Travel_Product__r);
                        if (casePointofSale.Case__c == myCase.id && primaryKeyforPicklist == removedPicklistValue){
                            casePointsOfSaleToDelete.add(casePointofSale);                      
                        }
                  }             
                }
          }
      }
      insert casePointsOfSaleToInsert;
      delete casePointsOfSaleToDelete;
  }
  
  //List of all Travel Products in SFDC
  private static List<Travel_Product__c> allTravelProducts = [SELECT 
                                                              Name
                                                             ,Brand__c
                                                             ,TPID__c
                                                             ,Id 
                                                             FROM Travel_Product__c]; 

  //build a unique name from the TravelProduct Name & TPID to be able to map to the picklist value
  // if we change the picklist values, we can just update the code here, and the rest will work
  private static string buildKeyForPicklistValue(Travel_Product__c myTravelProduct){
    return myTravelProduct.TPID__c + '-' + myTravelProduct.Name;  
  }

  //build a map of the TravelProduct key (as defined by the Picklist), to Travel_Product__c Id
  private static Map<String, ID> travelProductKeytoTravelProductIdMap(){
    Map <String, Id> buildingMap = new Map<String, Id> ();
    for (Travel_Product__c  myTravelProduct : allTravelProducts){
      buildingMap.put(buildKeyForPicklistValue(myTravelProduct), myTravelProduct.Id);
    }
    return buildingMap;
  }
  //Get the ID value of the Travel_Product__c using the TravelProduct key (as defined by the Picklist)
  private static Id getTravelProductId(String travelProductKey){
   return travelProductKeytoTravelProductIdMap().get(travelProductKey);
  }  
}