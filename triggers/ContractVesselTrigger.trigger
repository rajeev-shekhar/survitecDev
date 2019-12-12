//Author: Rajeev S
trigger ContractVesselTrigger on Contract_Vessels__c(after insert,after update) {
    Revenue_Projection_Trigger_Controls__c env = Revenue_Projection_Trigger_Controls__c.getValues('ContractVesselTrigger');
    if((env != null && env.Active__c) || Test.isRunningTest()) {
        if(trigger.isInsert) {
            rp_contractVesselBillingPlans.actionsOnInsert(Trigger.new);
        } else if(trigger.isUpdate) {
            rp_contractVesselBillingPlans.actionsOnUpdate(Trigger.new,trigger.oldMap);
        }    
    }    
}