trigger caseOwnerUpdate on Case (after update) {
    List<Case> updateCS = new List<Case>();
    Map<Id,Case> cases = new Map<Id,Case>();
    
    for (Case cs : Trigger.new)
    {
        if(Trigger.isUpdate && !(cs.Isescalated)) {  
            System.debug('>>>>> Owner ID: '+cs.ownerId+' Temp Owner ID: '+cs.TempOwnerId__c);
            if(cs.TempOwnerId__c <> null && cs.TempOwnerId__c <> '') {
                if(cs.OwnerId <> cs.TempOwnerId__c) {
                    cases.put(cs.id,cs);
                }
            }           
        }   
    }
    if (cases.isEmpty()) return;
    
    for (Case cs : [SELECT OwnerId,TempOwnerId__c FROM Case WHERE id in :cases.keySet()]) {
        cs.OwnerId = cases.get(cs.Id).TempOwnerId__c;
        cs.TempOwnerId__c = 'SKIP'; //flag to stop infinite loop upon update
        updateCS.add(cs);
    }
    System.debug('>>>>>Update Cases: '+updateCS);
    
    //
    //Update last assignment for Assignment Group in batch
    //
    if (updateCS.size()>0) {
        try {
            update updateCS;
        } catch (Exception e){

        }
    }
}