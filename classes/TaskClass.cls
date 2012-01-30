public with sharing class TaskClass {
	
	//constructor
	public TaskClass() {}
	
	public void createTask(Id whatId, Id whoId, Id ownerId, String description, String subject, 
	  String status, Date activityDate ) {
		
		system.debug('*** TaskClass.createTask before insert ***');
			
		Task newTask = new Task(WhatId = whatId
		                       ,WhoId = whoId
		                       ,OwnerId = ownerId
		                       ,Description = Utilities.truncateField(description, 32000, '\n')
		                       ,Subject = subject
		                       ,Status = status
		                       ,ActivityDate = activityDate);
		                       
		insert newTask;
	}
	
	public Id getTaskParentId(String subject) {
	  // initialize to null
	  Id parentId = null;
	  
	  //if subject is null return null
	  if(subject == null) return parentId;
	  
	  // check for a parent case if has :ref tags
	  if (subject.contains(':ref') && subject.contains(':ref')) {
	    parentId = this.emailThreadTaskParentId(subject);	
	  }	
	  // return parentId ... null if no parent found
		return parentId;
	}
    
    public static List<Task> findEmailsByParentId(Id parentId){
        List<Task> allEmails = new List<Task>();
        allEmails = [SELECT Id
                           ,Subject
                           ,Description
                           ,ActivityDate 
                       FROM Task 
                      WHERE WhatId = :parentId 
                        AND Subject like 'Email%'
                   order by ActivityDate desc];
                        
        return allEmails;
    }
	
	
	   private Id emailThreadTaskParentId(String subject) {
	  // Returns the parent Case id by matching the reference id from and associated task
		
      Id parentId = null;
		
	  String queryWhere = '%' + this.emailThreadTaskReferenceId(subject) + '%';
	  system.debug(queryWhere);
	  
	  /**
	  List<Task> tasks = [Select whatId
	                        From Task
	                       Where Subject like :queryWhere];
	  **/
	  	  
	  List<EmailMessage> emails = [SELECT ParentId, Subject FROM EmailMessage WHERE Subject like :queryWhere];
	 
	    system.debug('>>>>>>>>>>>>>>do we get here?');
	    //system.debug('>>>>>>> TASKS = ' + tasks);                                     
	  //if(tasks.size() == 0){
	  if(emails.size() == 0){
	 	  parentId = null;
	  }
	  else {
	    //parentId =  tasks[0].WhatId;
	    //parentId =  emails[0].ParentId;
	    
	    //MPS Added to trap for IDs that are the same case insensitive, but not case sensitive.
	    for (EmailMessage em : emails){
	    	//.equals() method is case sensitive whereas == is not case sensitive
	    	if (this.emailThreadTaskReferenceId(subject).equals(this.emailThreadTaskReferenceId(em.Subject))){
	    		return em.ParentId;
	    	}	    	    	
	    }	    
	  }
	  return parentId;
	}
	
	private String emailThreadTaskReferenceId(String subject) {
	
    Integer firstRef = subject.indexof('ref:');
    Integer lastRef = subject.lastindexof(':ref') + 4;
    
    return subject.substring(firstRef,lastRef);
		
	}
	

}