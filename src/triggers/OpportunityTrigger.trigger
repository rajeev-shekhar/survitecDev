//Author: Rajeev S

trigger OpportunityTrigger on Opportunity (after insert,after update) {
    if(trigger.isInsert) {
        rp_oppBillingPlans.actionsOnInsert(Trigger.new);
    } else if(trigger.isUpdate) {
        rp_oppBillingPlans.actionsOnUpdate(Trigger.new,trigger.oldMap);
    }    
}