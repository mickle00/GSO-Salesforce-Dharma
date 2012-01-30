trigger ContractLoadingStepTrigger on Contract_Loading_Step__c (after update) {
  
  ContractLoadingStepClass objStep = new ContractLoadingStepClass();
  objStep.marketManagerTaskComplete(trigger.new);

}