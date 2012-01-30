public with sharing class EmailWidgetWrapper {
	
	public EmailWidgetWrapper (Connection__c myConnection, id myCaseId, Set<String> templateFolders, string fromAddress){
		this.templateFolders = templateFolders;
		this.myConnection = myConnection;
		this.templates = findTemplates();		
		this.hotelContacts = findHotelContacts();
		this.vendorContacts = findVendorContacts();
		this.systemContacts = findSystemContacts();
		this.marketManagers = findMarketManagers();
		this.accountTeamMembers = findAccountTeamMembers();
		this.myCaseId = myCaseId;
		this.fromAddress = fromAddress;
	}
	
	public List<SelectOption> templates {get; set;}
	public List<SelectOption> hotelContacts {get; set;}
	public List<SelectOption> vendorContacts {get; set;}
	public List<SelectOption> systemContacts {get; set;}
	public List<SelectOption> marketManagers {get; set;}
	public List<SelectOption> accountTeamMembers {get; set;}
	public Connection__c myConnection {get; set;}
	public string hotelContact{get; set;}
	public id myCaseId{get; set;}
	
    public List<String> selectedVendorContacts{
		get{
			if (selectedVendorContacts == null) selectedVendorContacts = new List<String>();
			return selectedVendorContacts;
		} set;
	}
    public List<String> selectedSystemContacts{
		get{
			if (selectedSystemContacts == null) selectedSystemContacts = new List<String>();
			return selectedSystemContacts;
		} set;
	}
    public List<String> selectedMarketManagers{
		get{
			if (selectedMarketManagers == null) selectedMarketManagers = new List<String>();
			return selectedMarketManagers;
		} set;
	}
    public List<String> selectedAccountTeamMembers{
		get{
			if (selectedAccountTeamMembers == null) selectedAccountTeamMembers = new List<String>();
			return selectedAccountTeamMembers;
		} set;
	}
	
	public string template {
		get{
			if (template == null) return '';
			return template;							
		}set;
	}
		
    public PageReference sendConnectivityEmail(){
    	String retURL = EncodingUtil.urlEncode('/apex/ManageConnection?Id=' + this.myConnection.Id + '&' + ConnectionController.getCaseQueryString(this.myCaseId), 'UTF-8');
    	
    	PageReference emailURL = new PageReference ('/email/author/emailauthor.jsp?'
    												+ 'retURL=' + retURL // RETURN URL 
    												+ '&p2_lkid=' + this.hotelContact // ContactID
    												+ '&p3_lkid=' + myConnection.Id // RELATED TO WHATID
    												//+ '&p2=' + '' // TO: (CONTACT NAME)									
    												//+ '&p24=' + ccAddresses() // ADDITIONAL TO
    												+ '&p4=' + ccAddresses() // CC ADDRESS
    												+ '&p26=' + this.fromAddress // FROM ADDRESS
    												+ '&template_id=' + this.template
    												); 
    	emailURL.setRedirect(true);
    	return emailURL;   	
	}
	
	// PRIVATE METHODS		
	
	private Set<String> templateFolders;
	private String fromAddress;
	
	private string ccAddresses(){
		string ccAddresses = '';		
		ccAddresses += flattenStringList(this.selectedVendorContacts);		
		ccAddresses += flattenStringList(this.selectedSystemContacts);
		ccAddresses += flattenStringList(this.selectedAccountTeamMembers);
		ccAddresses += this.connectivityAccountManager(); //Added by Steve 10/6
		
		return ccAddresses;
	}
	
	
	// Turn a list into a semicolon separated string
    private string flattenStringList(List<String> myList){
    	String myStrings = '';
    	if (myList != null){
			for (String myString : myList){
				myStrings = myStrings + myString + '; ';
			}
		}
    	return myStrings;
	}
	
	private List<SelectOption> findTemplates() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','-- None -- '));		
		
    	List<EmailTemplate> emailTemplates = [SELECT Id 
    										   		,Name
    										   		,Folder.Name
    									   		FROM EmailTemplate 
    									  	   WHERE FolderId IN (SELECT Id 
    									  			    			FROM Folder 
    									  					  	   WHERE Name IN :templateFolders)
					  				   		order by Folder.Name, Name asc];

        
        for (EmailTemplate myTemplate : emailTemplates){
        	options.add(new SelectOption(myTemplate.Id,myTemplate.Folder.Name + ': ' + myTemplate.Name));
        }           
        
        return options;
	}

    private List<SelectOption> findHotelContacts() {
        List<SelectOption> options = new List<SelectOption>();      

        for (Account_Contact__c hotelContact : AccountContactClass.findByAccountId(myConnection.Account__c)){
        	options.add(new SelectOption(hotelContact.Contact__c,hotelContact.Contact__r.FirstName + ' ' + hotelContact.Contact__r.LastName));
        }
        options.add(new SelectOption('','-- None -- '));
        return options;
    } 

    private List<SelectOption> findVendorContacts() {
        List<SelectOption> options = new List<SelectOption>();        

        for (Account_Contact__c vendorContact : AccountContactClass.findByAccountId(myConnection.Connectivity_System__r.Connectivity_Vendor__c)){
        	options.add(new SelectOption(vendorContact.Contact__r.Email,vendorContact.Contact__r.FirstName + ' ' + vendorContact.Contact__r.LastName));
        }
        return options;
    } 
 
    private List<SelectOption> findSystemContacts() {
        List<SelectOption> options = new List<SelectOption>();
     
        for (Connectivity_System_Contact__c systemContact : ConnectivitySystemContactClass.findByConnectivitySystemId(myConnection.Connectivity_System__c)){
        	options.add(new SelectOption(systemContact.Contact__r.Email,systemContact.Contact__r.FirstName + ' ' + systemContact.Contact__r.LastName));
        }
        return options;
    }

    private List<SelectOption> findMarketManagers() {
        List<SelectOption> options = new List<SelectOption>(); 
        if (myConnection.Account__r.Market_Manager_Email__c != null && myConnection.Account__r.Market_Manager_Name__c != null){       
        	options.add(new SelectOption(myConnection.Account__r.Market_Manager_Email__c, myConnection.Account__r.Market_Manager_Name__c));
        }
        return options;
    }
    private List<SelectOption> findAccountTeamMembers() {
        List<SelectOption> options = new List<SelectOption>(); 	        
        List<PSG_User_Role__c> accountTeamMembers = PSGUserRoleClass.findByAccount(myConnection.Account__c);
        										   
        for (PSG_User_Role__c accountTeamMember : accountTeamMembers){
        	options.add(new SelectOption(accountTeamMember.PSG_User__r.Email__c,accountTeamMember.PSG_User__r.Name + ' (' + accountTeamMember.Role__c + ')'));
        }	        
        return options;
    }     	
    
    //Added by Steve 10/6
    private String connectivityAccountManager() {
      if (myConnection.Connectivity_System__r.Connectivity_Vendor__r.Market_Manager_Email__c != null){
        return myConnection.Connectivity_System__r.Connectivity_Vendor__r.Market_Manager_Email__c;
      } 
      return '';  
    }
}