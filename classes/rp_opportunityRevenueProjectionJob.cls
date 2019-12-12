//Author: Rajeev Shekhar
public class rp_opportunityRevenueProjectionJob implements Queueable {
    
    List<String> opportunityIds;
    
    public rp_opportunityRevenueProjectionJob(List<String> opportunityIds) {
        this.opportunityIds = opportunityIds;    
    }
    
    public void execute(QueueableContext context) {
        if(!opportunityIds.isEmpty()) { 
            Set<Id> oppIds = new Set<Id>();
            Set<Id> productIds = new Set<Id>();
            Map<Id,List<Opportunity_Billing_Plan__c>> obpsmap = new Map<Id,List<Opportunity_Billing_Plan__c>>();
            Revenue_Projection_Opportunity__c[] rpolist = new List<Revenue_Projection_Opportunity__c>();
            List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();      

            OpportunityLineItem[] scope = [SELECT Id, Opportunity.Name, OpportunityId, Opportunity.AccountId, TotalPrice, Revenue_Projection_Batch_Processed__c,
                                           Opportunity.Create_Revenue_Projections__c, Product2Id, Opportunity.CurrencyISOCode FROM OpportunityLineItem WHERE
                                           OpportunityId IN :opportunityIds AND Opportunity.Create_Revenue_Projections__c = true AND Revenue_Projection_Batch_Processed__c = 'Pending'];
            
            for(OpportunityLineItem oli : scope) {
                oppIds.add(oli.OpportunityId);
                productIds.add(oli.Product2Id);
            }
            
            for(Opportunity_Billing_Plan__c obp : [SELECT Id, Billing_Date__c, Billing_Rate__c, Opportunity__c, Order__c FROM Opportunity_Billing_Plan__c WHERE Opportunity__c In :oppIds]) {
                if(obpsmap.containsKey(obp.Opportunity__c)) {
                    obpsmap.get(obp.Opportunity__c).add(obp);
                } else {
                    obpsmap.put(obp.Opportunity__c,new List<Opportunity_Billing_Plan__c>{obp});
                }
            }
            
            Revenue_Projection_Opportunity__c[] rpdelete = rp_opportunityRevenueProjectionFunctions.getOpportunityProjectionsToDelete(obpsmap.keySet(),productIds);
             
            for(OpportunityLineItem oli : scope) {
                if(obpsmap.containsKey(oli.OpportunityId) && obpsmap.get(oli.OpportunityId) != null) {
                    for(Opportunity_Billing_Plan__c obp : obpsmap.get(oli.OpportunityId)) {
                        Revenue_Projection_Opportunity__c rpo = new Revenue_Projection_Opportunity__c();
                        rpo.Opportunity__c = oli.OpportunityId;
                        rpo.Date__c = obp.Billing_Date__c;
                        if(oli.TotalPrice != null) rpo.Amount__c = ((obp.Billing_Rate__c) * (oli.TotalPrice) / 100);
                        rpo.Account__c = oli.Opportunity.AccountId;
                        rpo.Mode__c = 'Code';
                        rpo.Product__c = oli.Product2Id;
                        rpo.Status__c = 'Valid';
                        rpo.Name = oli.Opportunity.Name;
                        rpo.CurrencyISOCode = oli.Opportunity.CurrencyISOCode;
                        rpolist.add(rpo);
                    }
                    oliToUpdate.add(oli);
                }        
            }
            
            if(rpolist.size() > 0) {
                try{
                    insert rpolist;
                    if(rpdelete.size() >0) delete rpdelete;
                    for(OpportunityLineItem o : oliToUpdate) {
                        o.Revenue_Projection_Batch_Processed__c = 'Processed';
                    }
                    update oliToUpdate;
                } Catch(Exception e) {
                    System.debug('Exception: '+e);    
                }
            }
        }          
    }
}