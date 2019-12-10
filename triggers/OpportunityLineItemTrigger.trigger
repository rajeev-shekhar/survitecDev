/*
 Trigger to update Opportunity Products when a Billing plan is updated
 Author - Rajeev Shekhar
*/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before update,after insert) {    
    Set<String> oppIds = new Set<String>();
    Set<String> prodIds = new Set<String>();
    for(OpportunityLineItem o : trigger.new) {
        if(trigger.isUpdate) {
            OpportunityLineItem oldObp = trigger.oldMap.get(o.Id);
            if(o.UnitPrice != oldObp.UnitPrice || o.Quantity != oldObp.Quantity) {
                if(o.Revenue_Projection_Batch_Processed__c != 'Pending') o.Revenue_Projection_Batch_Processed__c = 'Pending';
                oppIds.add(o.OpportunityId);
                prodIds.add(o.Product2Id);
            }
        } else if(trigger.isInsert) {
            oppIds.add(o.OpportunityId);
        }
    }
    if(oppIds.size() >0) {
        rp_oppBillingPlans.invalidateRevenueProjectionsByProducts(oppIds,prodIds);
        System.enqueueJob(new rp_opportunityRevenueProjectionJob(new List<String>(oppIds))); //submit job

    }    
}