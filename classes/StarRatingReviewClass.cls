public with sharing class StarRatingReviewClass {

  // After Update, After Insert of Star Ratings update the lookup fields for
  // Structure Type & Star Rating Review on the Account
  
  // Currently could get data out of Sync if Star Rating Review's are ever deleted.
  // Users will not have the ability to delete Star Rating Reviews though
  public void syncAccountStarRatings(List<Star_Rating_Review__c> myStarRatingsReviews){
    // Loop through all reviews
    for (Star_Rating_Review__c review : myStarRatingsReviews) {
      // If review is complete we want to work with it
      if (review.Review_Complete__c == 'Yes') {
        accountIds.add(review.Account__c);
      }
    }
    
    // Make sure we are getting the details from the NEWEST StarRatingsReview                                            
    for (Star_Rating_Review__c myRelatedStarRating : [SELECT Id
                                                            ,Account__c
                                                            ,CreatedDate
                                                            ,Review_complete__c
                                                            ,Structure_Type__c
                                                        FROM Star_Rating_Review__c  
                                                       WHERE Review_Complete__c = 'Yes' 
                                                         AND Account__c IN :accountIds 
                                                    order by CreatedDate asc]){
       
      // Ordering by CreatedDate will loop through the Map and put the newest into the Map last, overriding any older values                                                
      accountIdToReviewStructureTypeId.put(myRelatedStarRating.Account__c, myRelatedStarRating.Structure_Type__c);
      accountIdToStarRatingReviewId.put(myRelatedStarRating.Account__c, myRelatedStarRating.Id);
    }  
    
    // Get the accounts for the completed reviews
    List<Account> accounts = [SELECT Id
                                    ,Star_Rating_Structure_Type__c
                                    ,Star_Rating_Review_ID__c
                                FROM Account
                               WHERE Account.Id IN :accountIds];    
  
    
    // Loop through accounts to see if we really need to update the structure type                 
    for (Account account : accounts) {
      // check to see if structure type on review is different than account, or if there is a newer rating review
      if (account.Star_Rating_Structure_Type__c <> accountIdToReviewStructureTypeId.get(account.Id)||
          account.Star_Rating_Review_ID__c <> accountIdToStarRatingReviewId.get(account.Id)){
            
        // structure type is updated so update it on the account
        account.Star_Rating_Structure_Type__c = accountIdToReviewStructureTypeId.get(account.Id);
        account.Star_Rating_Review_ID__c = accountIdToStarRatingReviewId.get(account.Id);
      
        // add account to the list of accounts we want to update
        accountsToUpdate.add(account);  
      }   
    }
    // commit changes to the database
    update accountsToUpdate; 
  }
  
  private Set<Id> accountIds = new Set<Id>();
  private Map<Id,Id> accountIdToReviewStructureTypeId = new Map<Id, Id>();
  private Map<Id,Id> accountIdToStarRatingReviewId = new Map<Id, Id>();  
  private List<Account> accountsToUpdate = new List<Account>();
}