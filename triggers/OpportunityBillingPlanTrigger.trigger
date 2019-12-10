/*
 Trigger to update Opportunity Products when a Billing plan is updated
 Author - Rajeev Shekhar
*/
trigger OpportunityBillingPlanTrigger on Opportunity_Billing_Plan__c (before update) {
    Set<String> oppIds = new Set<String>();
    for(Opportunity_Billing_Plan__c o : trigger.new) {
        Opportunity_Billing_Plan__c oldObp = trigger.oldMap.get(o.Id);
        if(o.Billing_Rate__c != oldObp.Billing_Rate__c || (o.Billing_Date__c != oldObp.Billing_Date__c )) {
            oppIds.add(o.Opportunity__c);
        }
    }
    if(oppIds.size() >0) {
        rp_oppBillingPlans.updateOpportunityLineItems(oppIds);
        rp_oppBillingPlans.invalidateRevenueProjections(oppIds);
        System.enqueueJob(new rp_opportunityRevenueProjectionJob(new List<String>(oppIds))); //submit job
    }    
}