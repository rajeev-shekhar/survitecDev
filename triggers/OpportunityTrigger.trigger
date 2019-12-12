//Author: Rajeev S

trigger OpportunityTrigger on Opportunity (after insert,after update) {
    Revenue_Projection_Trigger_Controls__c env = Revenue_Projection_Trigger_Controls__c.getValues('OpportunityTrigger');
    if ((env != null && env.Active__c) || Test.isRunningTest()) {
        if(trigger.isInsert) {
            rp_oppBillingPlans.actionsOnInsert(Trigger.new);
        } else if(trigger.isUpdate) {
            rp_oppBillingPlans.actionsOnUpdate(Trigger.new,trigger.oldMap);
        } 
    }   
}