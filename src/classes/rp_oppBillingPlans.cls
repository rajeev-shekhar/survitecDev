//Author: Rajeev S

public with sharing class rp_oppBillingPlans {
    
    //Create the Opportunity Billing Plan data
    public static void actionsOnInsert(List<Opportunity> opps) {
        createBillingPlans(opps);
    }
    
    //Recreate the Opportunity Billing Plan data
    public static void actionsOnUpdate(List<Opportunity> opps,Map<Id,Opportunity> oldMap) {
        Set<String> oppIds = new Set<String>();
        Set<String> oppIdsUpdate = new Set<String>();
        
        for(Opportunity o : opps) {
            if(o.Create_Revenue_Projections__c) {
                Opportunity oldOpp = oldMap.get(o.Id);
                if((o.Create_Revenue_Projections__c) && (oldOpp.Create_Revenue_Projections__c == false))
                    oppIds.add(o.Id);
                if((o.Billing_Method__c != null) && (o.Billing_Method__c != oldOpp.Billing_Method__c))
                    oppIds.add(o.Id);
                if((o.Time_to_full_Contract_implementation__c != null) && (o.Time_to_full_Contract_implementation__c != oldOpp.Time_to_full_Contract_implementation__c))
                    oppIds.add(o.Id);
                if((o.Potential_Deal_Duration_months__c != null) && (o.Potential_Deal_Duration_months__c != oldOpp.Potential_Deal_Duration_months__c))
                    oppIds.add(o.Id);    
                if((o.Time_to_revenue_days__c != null) && (o.Time_to_revenue_days__c != oldOpp.Time_to_revenue_days__c))
                    oppIdsUpdate.add(o.Id);
                if((o.CloseDate != null) && (o.CloseDate != oldOpp.CloseDate))
                    oppIdsUpdate.add(o.Id);        
            }            
        }
        
        if(oppIds.size() >0) {
            deleteBillingPlans(oppIds);
            invalidateRevenueProjections(oppIds);
            createBillingPlans(opps);
            updateOpportunityLineItems(oppIds);
        }
        
        if(oppIdsUpdate.size() >0 && oppIds.size() == 0) {
            updateBillingPlans(oppIdsUpdate,oldMap);
        }    
    }
    
    //Create Billing Plan record when Opportunities are inserted
    private static void createBillingPlans(List<Opportunity> opps) {
        Boolean allowRun = rp_checkRecursive.billingPlanCodeCheckInsert();
        List<String> opportunityIds = new List<String>();
        if(allowRun) {
            Map<String,Schema.RecordTypeInfo> oppRT = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            String contractRT_Id = oppRT.get('Deal').getRecordTypeId();
            String spotRT_Id = oppRT.get('Spot').getRecordTypeId();
            List<Opportunity_Billing_Plan__c> billingPlans = new List<Opportunity_Billing_Plan__c>();
            Map<String,Integer> billingMethodMap = new Map<String,Integer>();
            for(Schema.PicklistEntry F : Opportunity.Billing_Method__c.getDescribe().getPicklistValues()) {
                billingMethodMap.put(F.getValue(),Integer.valueOf(F.getValue().substringAfter('-')));
            }
            for(Opportunity o : opps) {
                if(o.RecordTypeId == contractRT_Id && o.StageName == 'Preparing Proposal' && o.Create_Revenue_Projections__c) {
                    if(String.IsNotBlank(o.Billing_Method__c) && o.Time_to_full_Contract_implementation__c != null) {
                        opportunityIds.add(o.Id);
                        Integer potentialDealDuration = null;
                        if(o.Potential_Deal_Duration_months__c != null) potentialDealDuration = Integer.valueOf(o.Potential_Deal_Duration_months__c);
                        Integer totalDuration = (o.Time_to_full_Contract_implementation__c + potentialDealDuration).intValue();
                        Integer billingMethodValue = billingMethodMap.get(o.Billing_Method__c);
                        Decimal iterations = null;
                        if(billingMethodValue != null) iterations = Math.floor(o.Time_to_full_Contract_implementation__c / billingMethodValue);
                        Date billingDate = null;
                        Integer order = 0;
                        for(integer i=1;i<=iterations.intValue();i++) {
                            Opportunity_Billing_Plan__c obp = new Opportunity_Billing_Plan__c();
                            obp.Opportunity__c = o.Id;
                            obp.Name = o.Name;
                            obp.Order__c = i;
                            if(i == 1) billingDate = o.CloseDate.addDays(o.Time_to_revenue_days__c.intValue());
                            if(i > 1) billingDate = billingDate.addMonths(billingMethodValue);
                            obp.Billing_Date__c = billingDate;
                            obp.Billing_Rate__c = (100 / iterations) * i;
                            order++;                         
                            billingPlans.add(obp);
                        }
                        if(billingDate != null) billingDate = billingDate.addMonths(billingMethodValue);
                        order++;
                        for(integer i=1;i<=((totalDuration/billingMethodValue)-iterations-iterations);i++) {
                            Opportunity_Billing_Plan__c obp = new Opportunity_Billing_Plan__c();
                            obp.Opportunity__c = o.Id;
                            obp.Name = o.Name;
                            obp.Order__c = order;
                            if(i > 1) billingDate = billingDate.addMonths(billingMethodValue);
                            obp.Billing_Date__c = billingDate;
                            obp.Billing_Rate__c = 100;
                            order++;                         
                            billingPlans.add(obp);
                        }
                        if(billingDate != null) billingDate = billingDate.addMonths(billingMethodValue);
                        for(integer i=1;i<iterations.intValue();i++) {
                            Opportunity_Billing_Plan__c obp = new Opportunity_Billing_Plan__c();
                            obp.Opportunity__c = o.Id;
                            obp.Name = o.Name;
                            obp.Order__c = order;
                            if(i > 1) billingDate = billingDate.addMonths(billingMethodValue);
                            obp.Billing_Date__c = billingDate;
                            obp.Billing_Rate__c = 100 - ((100 / iterations) * i);
                            order++;                         
                            billingPlans.add(obp);
                        }
                    }
                } else if(o.RecordTypeId == spotRT_Id && o.StageName == 'Preparing Proposal' && o.Create_Revenue_Projections__c) {
                    opportunityIds.add(o.Id);
                    Opportunity_Billing_Plan__c obpSpot = new Opportunity_Billing_Plan__c(Name = o.Name,Order__c = 1,
                        Billing_Rate__c = 100, Billing_Date__c = o.CloseDate.addDays(o.Time_to_revenue_days__c.intValue()),Opportunity__c = o.Id);
                        insert obpSpot;
                }   
            }
            if(billingPlans.size() >0) insert billingPlans;
            if(opportunityIds.size() >0) System.enqueueJob(new rp_opportunityRevenueProjectionJob(opportunityIds)); //submit job
        }        
    }
    
    //Update Opportunity Billing Plans when certain fields change on Opportunity
    private static void updateBillingPlans(Set<String> oppIds,Map<Id,Opportunity> oldMap) {
        Opportunity_Billing_Plan__c[] obps = [SELECT Id, Billing_Date__c, Order__c, Opportunity__r.CloseDate,Opportunity__r.Time_to_revenue_days__c FROM Opportunity_Billing_Plan__c
                                              WHERE Opportunity__c IN :oppIds Order By Opportunity__c,Order__c ASC];
        for(Opportunity_Billing_Plan__c o : obps) {
            Decimal ttrdiff = o.Opportunity__r.Time_to_revenue_days__c - oldmap.get(o.Opportunity__c).Time_to_revenue_days__c; 
            Integer datedifference = oldmap.get(o.Opportunity__c).CloseDate.daysBetween(o.Opportunity__r.CloseDate);
            o.Billing_Date__c = o.Billing_Date__c.addDays(datedifference + ttrdiff.intValue()); 
        }
        update obps;                                      
    }
    
    //Delete the Opportunity Billing Plan data
    private static void deleteBillingPlans(Set<String> oppIds) {
        Opportunity_Billing_Plan__c[] obp = [SELECT Id FROM Opportunity_Billing_Plan__c WHERE Opportunity__c IN :oppIds];
        delete obp;
    }
    
    //Invalidate the Opportunity Revenue Projection data
    public static void invalidateRevenueProjections(Set<String> oppIds) {
        Revenue_Projection_Opportunity__c[] rpo = [SELECT Id,Status__c FROM Revenue_Projection_Opportunity__c WHERE Opportunity__c IN :oppIds];
        List<Revenue_Projection_Opportunity__c> updateRpo = new List<Revenue_Projection_Opportunity__c>();
        for(Revenue_Projection_Opportunity__c r : rpo) {
            if(r.Status__c != 'Invalid') {
                r.Status__c = 'Invalid';
                updateRpo.add(r);
            }
        }
        if(updateRpo.size() >0) update updateRpo;
    }
    
    //Invalidate the Opportunity Revenue Projection data based on Products
    public static void invalidateRevenueProjectionsByProducts(Set<String> oppIds, Set<String> prodIds) {
        Revenue_Projection_Opportunity__c[] rpo = [SELECT Id,Status__c FROM Revenue_Projection_Opportunity__c WHERE Opportunity__c IN :oppIds
                                                   AND Product__c IN :prodIds];
        List<Revenue_Projection_Opportunity__c> updateRpo = new List<Revenue_Projection_Opportunity__c>();
        for(Revenue_Projection_Opportunity__c r : rpo) {
            if(r.Status__c != 'Invalid') {
                r.Status__c = 'Invalid';
                updateRpo.add(r);
            }
        }
        if(updateRpo.size() >0) update updateRpo;
    }
    
    //Update the Opportunity Products
    public static void updateOpportunityLineItems(Set<String> oppIds) {
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for(OpportunityLineItem o : [SELECT Id, Revenue_Projection_Batch_Processed__c FROM OpportunityLineItem WHERE OpportunityId IN :oppIds]) {
            if(o.Revenue_Projection_Batch_Processed__c != 'Pending') {
                o.Revenue_Projection_Batch_Processed__c = 'Pending';
                lineItems.add(o);
            }
        }
        if(lineItems.size() > 0) update lineItems;
    }    
}