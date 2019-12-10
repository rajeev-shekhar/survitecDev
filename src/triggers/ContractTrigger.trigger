/*
 * Author: Rajeev Shekhar
*/
trigger ContractTrigger on Contract (after update) {
    
    if(trigger.isUpdate && trigger.isAfter) {
        Set<Id> contractIds = new Set<Id>();
        for(Contract c: trigger.new) {
            if(c.Invoicing_Intervals__c != null && (trigger.oldMap.get(c.Id).Invoicing_Intervals__c != c.Invoicing_Intervals__c)) {
                contractIds.add(c.Id);
            }
        }
        
        Contract_Vessels__c[] vessels = [SELECT Id FROM Contract_Vessels__c WHERE Contract__c IN :contractIds];
                                         
        if(vessels.size() >0) {
            delete [SELECT Id From Contract_Billing_Plan__c WHERE Contract_Vessel__c IN :vessels];
            rp_contractVesselBillingPlans.actionsOnInsert(vessels);
        }       
    }                                   
}