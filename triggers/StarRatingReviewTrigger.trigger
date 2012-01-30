trigger StarRatingReviewTrigger on Star_Rating_Review__c (after update, after insert) {
	
	StarRatingReviewClass objStarRating = new StarRatingReviewClass();
	objStarRating.syncAccountStarRatings(trigger.New);	
}