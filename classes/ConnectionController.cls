public class ConnectionController{
  
    public final Set<String> TEMPLATE_FOLDERS = new Set<String>{'EQC Maintenance', 'EQC Soft Launch', 'Venere Connect'};
    public final String FROM_ADDRESS = 'eqchelp@expedia.com';   
    
    public Connection__c myConnection {get; set;}
    public Case myCase {get; set;}
    public Note myNote {get; set;}
    public List<Rollout_Step__c> myConnectivityRollouts {get; set;}    
    public List<Connection__c> accountConnections{get; set;}
    public List<Note> allNotes{get; set;}
    public boolean isCreatingNewConnection {get; set;}   
    public boolean renderConnectionDetails {get; set;}
    public final id originalCaseId{get; set;}
    public integer numberAdditionalRolloutSteps{get;set;}
    public Id rolloutStepToDelete{get;set;}
    public Id connectionIdToEdit {get; set;}
    public EmailWidgetWrapper myEmailWidget{get; set;}
    public string accountName {get; set;}        
        
    public ConnectionController(ApexPages.StandardController stdController){
        this.myConnection = (Connection__c)stdController.getRecord();
        renderConnectionDetails = false;
        numberAdditionalRolloutSteps = 0;       
        if (ApexPages.currentPage().getParameters().containsKey('CaseID')){
           if (ApexPages.currentPage().getParameters().containsKey('new'))renderConnectionDetails = true;
           originalCaseId = ApexPages.currentPage().getParameters().get('CaseID');
           this.NewConnectionFromCase();        
        }
        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            this.ExistingConnection(ApexPages.currentPage().getParameters().get('Id'));         
            myEmailWidget = new EmailWidgetWrapper(myConnection, originalCaseId, TEMPLATE_FOLDERS, FROM_ADDRESS);
        }    
        myNote = new Note();
        this.buildAccountConnections();
        
        if(myConnection.Account__c == null){
            this.noAccount();
        }
        buildAccountName();
    }
    
    public string getTitle(){
        if (isCreatingNewConnection == true) return 'New Connection';        
        return 'Edit Connection';
    }
        
    public PageReference newConnection(){
        renderConnectionDetails = true;        
        Case myCase = CaseClass.findById(originalCaseId);
        myConnection = new Connection__c(Account__c = myCase.AccountId, Status__c = 'Connecting');
        return null;
    }
            
    public boolean getRenderExistingConnections(){
        return accountConnections.size() > 0 && accountName != null;
    }
    
    public List<Account_Repco__c> getAccountRepcos(){       
        return AccountRepcoClass.getAccountRepcosByAccountId(myConnection.Account__c);
    }
    
    public integer getAccountRepcoSize(){
        return getAccountRepcos().size();
    }
    
    public List<selectOption> getAvailableAccountRepcos() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- None -')); 
        //add the first option of '- None -' in case the user doesn't want to select a value or in 
        //case no values are returned from query below
        
        for (Account_Repco__c myAccountRepco : getAccountRepcos()) { 
            options.add(new selectOption(myAccountRepco.Id, myAccountRepco.Repco__r.Name)); 
        }
        return options;
    }
    
    public void addRolloutStage(){
        numberAdditionalRolloutSteps++;
        myConnectivityRollouts.add(newRolloutStep());
    }
    
    public void removeRolloutStage(){
        numberAdditionalRolloutSteps--;
        myConnectivityRollouts.remove(myConnectivityRollouts.size()-1);
    }
    
    public void deleteRolloutStep(){
        Rollout_Step__c rolloutToDelete = RolloutStepClass.getRolloutStepById(rolloutStepToDelete);
        delete rolloutToDelete;
        rolloutStepToDelete = null;
        myConnectivityRollouts = RolloutStepClass.getRolloutStepsByConnectionId(myConnection.Id);
        if (myConnectivityRollouts.size() == 0){
            this.buildConnectivityRollouts();
        }
    }

    public PageReference Save(){
        try{
            ConnectionClass.upsertConnection(myConnection);            
            NoteClass.insertNote(myNote, myConnection.Id);
            this.saveConnectivityRollouts();
            this.refreshData();
        }catch (Exception e){
            system.debug('Connection Controller Save Exception' + e);
        }
        return null;           
    }
    
    public PageReference createNewConnection(){
        PageReference newConnectionURL = Page.ManageConnection;
        newConnectionURL.getParameters().put('CaseID', myCase.Id);
        newConnectionURL.getParameters().put('new', 'true');        
        newConnectionURL.setRedirect(true); // clear the viewstate
        return newConnectionURL;
    }
    
    public PageReference editConnection(){        
        PageReference editConnectionPage = Page.ManageConnection;
        editConnectionPage.getParameters().put('Id', connectionIdToEdit);
        if (originalCaseId != null) editConnectionPage.getParameters().put('CaseID', myCase.Id);
        editConnectionPage.setRedirect(true); 
        this.ExistingConnection(connectionIdToEdit);
        return editConnectionPage;
    }
  
    public PageReference Cancel(){
        PageReference refreshPage = ApexPages.currentPage();
        refreshPage.setRedirect(true);
        return refreshPage;
    }
  
    public PageReference returnToCase(){
        if (originalCaseId != null){            
            PageReference caseURL =  new ApexPages.StandardController(myCase).view();
            caseURL.setRedirect(true);
            return caseURL;
        }else{
            PageReference homeURL = new PageReference('/');
            return homeURL;
        }
    }
    
    //Used to build a link directly from visualforce page
    public string getCaseQueryString(){
        return getCaseQueryString(originalCaseId);
    }
    
    public static string getCaseQueryString(Id myCaseId){
        String caseQueryString = '';
        if (myCaseId != null) caseQueryString = 'CaseID=' + myCaseId;
        return caseQueryString;
    }
    
    public List<Task> getAllEmails(){
        return TaskClass.findEmailsByParentId(myConnection.Id);
    }
    
    //Need to query this way incase access the page directly from connection, and not via Case Button
    private void buildAccountName(){
        if (accountName == null){
            try {
                Account myAccount = [SELECT Name FROM Account WHERE Id = :myConnection.Account__c];
                accountName = myAccount.Name;
                }
            catch (Exception e){
                system.debug(e);
            }
        }
    }
    
    private RecordType connectivityRolloutStepRecordType;
    
    private RecordType getConnectivityRolloutStepRecordType(){
        if (connectivityRolloutStepRecordType == null){
            connectivityRolloutStepRecordType = [SELECT Id 
                                                   FROM RecordType 
                                                  WHERE sObjectType = 'Rollout_Step__c' 
                                                    AND DeveloperName = 'Connectivity'];
        }
        return connectivityRolloutStepRecordType;
    }
    
    private void refreshData(){
        this.buildAccountConnections();
        myConnection = ConnectionClass.getConnection(myConnection.Id);
        allNotes = NoteClass.getNotesByParentId(myConnection.Id);
        myNote = new Note();
        numberAdditionalRolloutSteps = 0;
        myEmailWidget = new EmailWidgetWrapper(myConnection, originalCaseId, TEMPLATE_FOLDERS, FROM_ADDRESS);
    }    
        
    private void NewConnectionFromCase(){
        isCreatingNewConnection = true;
        myCase = CaseClass.findById(originalCaseId);        
        myConnection = new Connection__c(Account__c = myCase.AccountId, Status__c = 'Connecting');
        this.buildConnectivityRollouts();
    }
    
    private void ExistingConnection(Id existingConnectionId){
        renderConnectionDetails = true;
        isCreatingNewConnection = false;        
        myConnection = new Connection__c();
        try{
            myConnection = ConnectionClass.getConnection(existingConnectionId);
        }catch (Exception e){
            system.debug('ConnectionController ExistingConnection Exception' + e);
        }
        try{
            allNotes = NoteClass.getNotesByParentId(myConnection.Id);     
            myConnectivityRollouts = RolloutStepClass.getRolloutStepsByConnectionId(myConnection.Id);
          
            if (myConnectivityRollouts.size() == 0){
                this.buildConnectivityRollouts();
            }
        } catch (Exception e){
            this.buildConnectivityRollouts();
        }                         
    }
    
    private void buildAccountConnections(){
        // catch Accounts that do not have any existing connections
        try{
            accountConnections = ConnectionClass.getConnectionsByAccountId(myConnection.Account__c);                        
        }catch (Exception e) {
            system.debug ('Error: ' + e);
            accountConnections = new List<Connection__c>();
        }    
    }
    
    private void saveConnectivityRollouts(){
    	for (Rollout_Step__c myStep : myConnectivityRollouts){
    		//Rollout Steps built on New Connections don't have the context of ConnectionId until after Connection inserted
    		myStep.Connection__c = myConnection.Id;
    	}
    	RolloutStepClass.insertNewRolloutSteps(myConnectivityRollouts);
    }
    
    private void buildConnectivityRollouts(){
          myConnectivityRollouts = new List<Rollout_Step__c>();
          if (myConnection.Status__c != 'Connected' && myConnection.Status__c !='Disconnected'){
          	myConnectivityRollouts.add(newRolloutStep());
          }
    }
    
    private Rollout_Step__c newRolloutStep(){
        return new Rollout_Step__c(Case__c = originalCaseId
                                  ,Connection__c = myConnection.Id
                                  ,Completed_Date__c = system.now()
                                  ,RecordTypeId = getConnectivityRolloutStepRecordType().Id);
    }    
   
    private void noAccount(){  
        ApexPages.Message myError = new ApexPages.Message(ApexPages.Severity.FATAL, 'Warning - Case has no associated account, please update the case prior to creating a connection.');
        ApexPages.addMessage(myError);
    }
}