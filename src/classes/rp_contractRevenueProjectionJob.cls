//Author: Rajeev Shekhar
public with sharing class rp_contractRevenueProjectionJob implements Queueable {
    
    List<String> cvIds;
    
    public rp_contractRevenueProjectionJob(List<String> cvIds) {
        this.cvIds = cvIds;    
    }
    
    public void execute(QueueableContext context) {
        if(!cvIds.isEmpty()) { 
            Set<Id> vesselIds = new Set<Id>();
            Set<Id> vesselProductIds = new Set<Id>();
            Set<Id> productIds = new Set<Id>();
            Map<Id,List<Contract_Billing_Plan__c>> obpsmap = new Map<Id,List<Contract_Billing_Plan__c>>();
            Revenue_Projection_Contract__c[] rpolist = new List<Revenue_Projection_Contract__c>();
            Set<Id> ToUpdate = new Set<Id>(); 
            Map<Id,Map<Date,Decimal>> priceDateMap = new Map<Id,Map<Date,Decimal>>();     
            List<Contract_Vessels__c> toUpdateCVs = new List<Contract_Vessels__c>();
            Vessel_Product__c[] vesselProducts = [SELECT Id,Name,Contract_Vessel__c,Contract_Vessel__r.Contract__c,Contract_Vessel__r.Contract__r.CurrencyIsoCode,Currency__c,Product2__c,Quantity__c,Unit_Price__c,Contract_Vessel__r.Contract__r.AccountId,Contract_Vessel__r.Name FROM
                                                  Vessel_Product__c WHERE Contract_Vessel__c IN :cvIds AND Contract_Vessel__r.Create_Revenue_Projections__c = true];
            
            for(Vessel_Product__c oli : vesselProducts) {
                vesselProductIds.add(oli.Id);
                vesselIds.add(oli.Contract_Vessel__c);
                productIds.add(oli.Product2__c);
            }
            
            for(Contract_Product_Price__c cpp : [SELECT Id, Start_Date__c,End_Date__c, Vessel_Product__c, Unit_Price__c FROM Contract_Product_Price__c WHERE Vessel_Product__c IN :vesselProductIds]) {
                Date startDate = cpp.Start_Date__c;
                Date endDate = cpp.End_Date__c;
                Map<Date,Decimal> tempMap = new Map<Date,Decimal>();
                if(startDate != null && endDate != null) {
                    while(startDate < endDate) {
                        tempMap.put(startDate,cpp.Unit_Price__c);
                        startDate = startDate.addDays(1);
                    }
                }
                if(!priceDateMap.containsKey(cpp.Vessel_Product__c))
                    priceDateMap.put(cpp.Vessel_Product__c,tempMap);
                else
                    priceDateMap.get(cpp.Vessel_Product__c).putAll(tempMap);        
            }
            
            for(Contract_Billing_Plan__c obp : [SELECT Id, Billing_Date__c, Billing_Rate__c, Contract_Vessel__c, Order__c FROM Contract_Billing_Plan__c WHERE Contract_Vessel__c In :vesselIds]) {
                if(obpsmap.containsKey(obp.Contract_Vessel__c)) {
                    obpsmap.get(obp.Contract_Vessel__c).add(obp);
                } else {
                    obpsmap.put(obp.Contract_Vessel__c,new List<Contract_Billing_Plan__c>{obp});
                }
            }
            
            Revenue_Projection_Contract__c[] rpdelete = [SELECT Id FROM Revenue_Projection_Contract__c WHERE Contract_Vessel__c In :vesselIds AND Product__c IN :productIds];
             
            for(Vessel_Product__c oli : vesselProducts) {
                if(obpsmap.containsKey(oli.Contract_Vessel__c) && obpsmap.get(oli.Contract_Vessel__c) != null) {
                    for(Contract_Billing_Plan__c obp : obpsmap.get(oli.Contract_Vessel__c)) {
                        Revenue_Projection_Contract__c rpo = new Revenue_Projection_Contract__c();
                        rpo.Contract_Vessel__c = oli.Contract_Vessel__c;
                        rpo.Contract__c = oli.Contract_Vessel__r.Contract__c;
                        rpo.Date__c = obp.Billing_Date__c;
                        Decimal price = 0;
                        if(priceDateMap.containsKey(oli.Id)) {
                            if(priceDateMap.get(oli.Id).containsKey(obp.Billing_Date__c)) {
                                price = (priceDateMap.get(oli.Id).get(obp.Billing_Date__c) * oli.Quantity__c * obp.Billing_Rate__c) / 100;
                            }
                        }
                        rpo.Amount__c = price;
                        rpo.Account__c = oli.Contract_Vessel__r.Contract__r.AccountId;
                        rpo.Mode__c = 'Code';
                        rpo.Product__c = oli.Product2__c;
                        rpo.Status__c = 'Valid';
                        rpo.Name = oli.Contract_Vessel__r.Name;
                        rpo.CurrencyISOCode = oli.Contract_Vessel__r.Contract__r.CurrencyIsoCode;
                        rpolist.add(rpo);
                    }
                    ToUpdate.add(oli.Contract_Vessel__c);
                }        
            }
            
            if(rpolist.size() > 0) {
                try{
                    insert rpolist;
                    if(rpdelete.size() >0) delete rpdelete;
                } Catch(Exception e) {
                    System.debug('Exception: '+e);    
                }
            }
        }          
    }
}