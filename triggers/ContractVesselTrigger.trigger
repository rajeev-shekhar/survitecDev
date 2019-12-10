//Author: Rajeev S
trigger ContractVesselTrigger on Contract_Vessels__c(after insert,after update) {
    if(trigger.isInsert) {
        rp_contractVesselBillingPlans.actionsOnInsert(Trigger.new);
    } else if(trigger.isUpdate) {
        rp_contractVesselBillingPlans.actionsOnUpdate(Trigger.new,trigger.oldMap);
    }    
}