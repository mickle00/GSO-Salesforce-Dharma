public with sharing class UserClass {
	
	public User getUserByEmail(String email){
		
		// Try to find an exact match of a user by email.
		// If exact match is found return it
		// Otherwise return null
		User thisUser = null;

		User[] requestorList = [SELECT User.Id
		                              ,User.Email
		                              ,User.FirstName
		                              ,User.LastName
		                              ,User.Name
		                              ,User.Phone
                              FROM User
                             WHERE User.email = :email];
                       
    if (requestorList.size() == 1) {
    	for(User requestor : requestorList) {
        thisUser = requestor;
    	}
    }
    return thisUser;
	}
}