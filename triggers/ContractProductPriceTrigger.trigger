/*
 * Author: Rajeev Shekhar
*/
trigger ContractProductPriceTrigger on Contract_Product_Price__c (after insert,after update) {
    Revenue_Projection_Trigger_Controls__c env = Revenue_Projection_Trigger_Controls__c.getValues('ContractProductPriceTrigger');
    if ((env != null && env.Active__c) || Test.isRunningTest()) {
        if(trigger.isUpdate && trigger.isAfter) {
            Set<Id> vproducts = new Set<Id>();
            List<String> cvIds  = new List<String>();
            for(Contract_Product_Price__c c: trigger.new) {
                if(c.Unit_Price__c != null && (trigger.oldMap.get(c.Id).Unit_Price__c != c.Unit_Price__c)) {
                    vproducts.add(c.Vessel_Product__c);
                }
                else if(c.Start_Date__c != null && (trigger.oldMap.get(c.Id).Start_Date__c != c.Start_Date__c)) {
                    vproducts.add(c.Vessel_Product__c);
                }
                else if(c.End_Date__c != null && (trigger.oldMap.get(c.Id).End_Date__c != c.End_Date__c)) {
                    vproducts.add(c.Vessel_Product__c);
                }
            }
                                         
            if(vproducts.size() >0) {
                for(Vessel_Product__c v : [SELECT Contract_Vessel__c FROM Vessel_Product__c WHERE Id IN :vproducts]) {
                    cvIds.add(v.Contract_Vessel__c);    
                }
                System.enqueueJob(new rp_contractRevenueProjectionJob(cvIds));
            }       
        }
    
        if(trigger.isInsert && trigger.isAfter) {
            Set<Id> vproducts = new Set<Id>();
            List<String> cvIds  = new List<String>();
            for(Contract_Product_Price__c c: trigger.new) {
                vproducts.add(c.Vessel_Product__c);
            }
        
            if(vproducts.size() >0) {
                for(Vessel_Product__c v : [SELECT Contract_Vessel__c FROM Vessel_Product__c WHERE Id IN :vproducts]) {
                    cvIds.add(v.Contract_Vessel__c);    
                }
                System.enqueueJob(new rp_contractRevenueProjectionJob(cvIds));
            }  
        }   
    }           
}