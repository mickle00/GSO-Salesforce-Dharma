public class AccountTeamController {
	
	public Id extAccountId {get;set;}
	public List<PSG_User_Role__c> memberList {get;set;}
	public Boolean showPage {
		get{
			return extAccountId != null;
		}
	}
  public Boolean showTable {
  	get{
  		this.getAccountTeamMembers();
  		return memberlist.size() > 0;
  	}	
  }
  	
  public List<PSG_User_Role__c> getAccountTeamMembers() {
    if(memberList == null) {
      memberList = PSGUserRoleClass.findByAccount(extAccountId);       
    }
    return memberList;   
  }
}