public class troubleshootingCaseControllerExtension {

    // Built out in the constructor
    public List <Case_Process_Team__c> caseProcessTeams;
    
    // Whether or not the Owner is rendered as an available picklist option
    
    public boolean hasOwner{get;}
    
    public boolean hasOwner(){
    for (Case_Process_Team__c myCaseProcessTeam : caseProcessTeams){    
     if (myCaseProcessTeam.Involved__c == 'Owner') return true;     
    }
        return false;
    }
       
    private final Case finalCase;
    
    public Id getCaseId(){
      return finalCase.id;
    }
    
    public troubleshootingCaseControllerExtension(ApexPages.StandardController controller){
      this.finalCase = (Case)controller.getRecord(); 
      caseProcessTeams = [SELECT Id
                                ,Involved__c
                                ,Process_Team__r.Name
                                ,Additional_Comments__c
                                ,Ready_to_Close__c
                                ,LastModifiedDate
                                ,LastModifiedBy.LastName
                                ,LastModifiedBy.FirstName 
                           FROM Case_Process_Team__c 
                           WHERE Case__c = :getCaseId() 
                           ORDER BY Process_Team__r.Name Asc ];      
    }
        
    // All Options for the Involvement Needed Picklist
  public List<SelectOption> getallOptions(){
    List<SelectOption> all = new List<SelectOption>();
          all.add(new SelectOption('Unknown','Unknown'));
          all.add(new SelectOption('No','No'));
          all.add(new SelectOption('Yes (Not Owner)','Yes (Not Owner)'));
          all.add(new SelectOption('Owner','Owner', false));
    return all;
    }
        
    // All Options, with Owner grayed out if it has already been selected, or selectable if it hasn't already been selected
  public List<SelectOption> getInvolvementList() {
    List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('Unknown','Unknown'));
      options.add(new SelectOption('No','No'));
      options.add(new SelectOption('Yes (Not Owner)','Yes (Not Owner)'));     
      
      if (this.hasOwner() == true){        
      options.add(new SelectOption('Owner','Owner', true));
      return options;
      }    
        // if the owner is NOT the troubleshooting queue, display owner as a NON SELECTABLE field
        else {      
      options.add(new SelectOption('Owner','Owner', false)); 
        return options;
        }
    }
    
    // Yes or No for the Ready to Close field. By manually building it out in the controller we get rid of the "---None---" option.
  public List<SelectOption> getYNList() {
    List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('No','No'));
      options.add(new SelectOption('Yes','Yes'));
    return options;
  	}

  public List<Case_Process_Team__c> getCaseProcessTeams(){
    return caseProcessTeams;
    }
    
    // Go to the Edit Page
    public PageReference editTeams() {
      PageReference nextPage = Page.troubleshootingCaseEditPage;     
      nextPage.setredirect(false);
      return nextPage; 
  }
    
  // Save the InvolvementNeeded Page and return to the Case
  public PageReference saveTeams() {      
    List<Case_Process_Team__c> oldCaseProcessTeams = [SELECT Id
                                                             ,Involved__c
                                                             ,Process_Team__r.Name
                                                             ,Additional_Comments__c
                                                             ,Ready_to_Close__c
                                                         FROM Case_Process_Team__c 
                                                        WHERE Case__c = :finalCase.Id 
                                                     ORDER BY Process_Team__r.Name Asc];
                                                     
      Map<Id, Case_Process_Team__c> oldCaseProcessTeamIdtoCaseProcessTeamMap = new Map<Id, Case_Process_Team__c>();
      
      for (Case_Process_Team__c myOldProcessTeam : oldCaseProcessTeams){
        oldCaseProcessTeamIdtoCaseProcessTeamMap.put(myOldProcessTeam.Id, myOldProcessTeam);
      }
      
      List<Case_Process_Team__c> caseProcessTeamsToUpdate = new List<Case_Process_Team__c>();
      
      for (Case_Process_Team__c currentCaseProcessTeam : caseProcessTeams){
      if (currentCaseProcessTeam.Involved__c == 'No') {
        currentCaseProcessTeam.Ready_to_Close__c = 'Yes';
      }
        if (currentCaseProcessTeam.Involved__c == 'Unknown') {
            currentCaseProcessTeam.Ready_to_Close__c = 'No';            
        }
        Case_Process_Team__c oldCaseProcessTeam = oldCaseProcessTeamIdtoCaseProcessTeamMap.get(currentCaseProcessTeam.Id);
        String newComments = currentCaseProcessTeam.Additional_Comments__c;
        if (newComments == NULL) newComments = '';
        String oldComments = oldCaseProcessTeam.Additional_Comments__c;
        if (oldComments == NULL) oldComments = '';
        //see if anything has changed
        if ((currentCaseProcessTeam.Involved__c != oldCaseProcessTeam.Involved__c) || 
           (currentCaseProcessTeam.Ready_to_Close__c != oldCaseProcessTeam.Ready_to_Close__c) || 
           (newComments != oldComments)){
          caseProcessTeamsToUpdate.add(currentCaseProcessTeam);
        }
      }
      update caseProcessTeamsToUpdate; 
      return reloadPage(false);
  }
     
     // Cancel any of the edits since the last save
  public PageReference cancelTeams() {
    return reloadPage(false);
  }
  
  public PageReference teamPreBooking(){        
    removeUninvolvedTeams(new List<String>{'Ticketing', 'Air Fulfillment Process & Support', 'Regional Team', 'Schedule Change'});
    return reloadPage(false);
  }

     
    //Used for Team Fulfillment button
    public PageReference teamFulfillment() {
    removeUninvolvedTeams(new List<String>{'Air CPR', 'ADM', 'CarOps', 'Commissions', 'Fare Filing', 'Regional Team'});
        return reloadPage(false);
    }
    
    public string getCSSStyle(Case_Process_Team__c myCheckoffJunction){
        if(myCheckoffJunction.Involved__c == 'Yes (Not Owner)' || myCheckoffJunction.Involved__c == 'Owner'){
            return 'workingTeam';
        }
        else{
            return 'nonWorkingTeam';
        }
    }
        
    //incase we want to do anything else when page is refreshsed/updated
    public void UpdateRecords(){
    //getRenderOwner();
    //this.getInvolvementList();   
  }
  
  /**
  
  PRIVATE METHODS
  
  **/
  
  private PageReference reloadPage(boolean setRedirect){
    PageReference nextPage = new PageReference('/'+ getCaseId());
    if (setRedirect == true) nextPage.setredirect(true);
    if (setRedirect == false) nextPage.setredirect(false);
    return nextPage;
  }  

  private void removeUninvolvedTeams(List<String> myUninvolvedTeams){
    string queryWhere = '';
    if (myUninvolvedTeams.size() == 1){
        queryWhere = 'Process_Team__r.Name = \'' + myUninvolvedTeams[0] + '\'';
    }
    if (myUninvolvedTeams.size() > 1){
        Integer teamCount = 1;
        for (String teamName : myUninvolvedTeams){
         queryWhere = queryWhere + 'Process_Team__r.Name = \'' + teamName + '\''; // + '\'OR ';
         if (teamCount < myUninvolvedTeams.size()){
          queryWhere = queryWhere + 'OR ';
         }
         teamCount = teamCount + 1;
      }
    //queryWhere = queryWhere.substring(0,queryWhere.length()-3);
    }
    //Wrapping this in a try/catch method.....better safe than sorry
    try{
        List<Case_Process_Team__c> uninvolvedCheckoffJunctions = Database.query('SELECT Id, Involved__c FROM Case_Process_Team__c WHERE (' + queryWhere + ')AND Case__c = \'' + getCaseId() + '\'');                                                               
      
        for (Case_Process_Team__c myCaseProcessTeam : uninvolvedCheckoffJunctions){
          myCaseProcessTeam.Involved__c = 'No';
          myCaseProcessTeam.Ready_to_Close__c = 'Yes';
        }
        update uninvolvedCheckoffJunctions;
    } catch (Exception e){
        system.debug ('troubleshootingCaseControllerExtension Error: ' + e + 'Case #: ' + getCaseId());
    }
  }
}