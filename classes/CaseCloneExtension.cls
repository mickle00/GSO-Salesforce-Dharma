public class CaseCloneExtension {

    private final Case parentCase;
    
    public List<String> LanguagesSelected{get;set;} 
    
    public List<Case> RelatedCases {
    	get { return [Select CaseNumber, Team__c, Subject, Priority, CreatedDate, Status, OwnerId From Case Where ParentId = : this.parentCase.Id order by Team__c asc]; }
    }

    public CaseCloneExtension(ApexPages.StandardController controller) {
	  this.parentCase = (Case)controller.getRecord();
	  
	  this.LanguagesSelected = new List<String>();

    }
    
    public Pagereference CloneCases() {
        if(LanguageSelected()) {
            // clone cases
            CaseClass objCase = new CaseClass();
            objCase.assignCaseToLinguist(parentCase, LanguagesSelected);
                
            // update parent status
            this.UpdateParent();
            
            return new Apexpages.StandardController(parentCase).view();
        }else {
                // a language was not selected
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Language: You must enter a value'));
            return Apexpages.currentPage();
        }
    }
    
    public List<SelectOption> getLanguages() {
        List<SelectOption> options = new List<SelectOption>();
        
        // get a list of languages
        for(Language__c item : [Select Id, Name From Language__c order by Name]) {
            options.add(new SelectOption(item.Id, item.Name));
        }
        
        return options;
    }

    ///// Private
    private Boolean LanguageSelected() {
        return LanguagesSelected.isEmpty() == false;
    }
    
    private void UpdateParent() {
    	this.parentCase.Status = 'Assigned to Linguist';
        this.parentCase.Allocated__c = true;
        update this.parentCase;
    }
    
}