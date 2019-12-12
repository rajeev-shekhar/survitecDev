//Author: Rajeev Shekhar

public with sharing class rp_contractVesselBillingPlans {
    //Create the Opportunity Billing Plan data
    public static void actionsOnInsert(List<Contract_Vessels__c> vessels) {
        Set<Id> recordIds = new Set<Id>();
        for(Contract_Vessels__c v : vessels) {
            recordIds.add(v.Id);
        }
        createBillingPlans(recordIds);
    }
    
    //Recreate the Opportunity Billing Plan data
    public static void actionsOnUpdate(List<Contract_Vessels__c> vessels, Map<Id,Contract_Vessels__c> oldMap) {
        Set<Id> recordIds = new Set<Id>();
        for(Contract_Vessels__c v : vessels) {
            Contract_Vessels__c oldrec = oldMap.get(v.Id);
            if(v.Create_Revenue_Projections__c != oldrec.Create_Revenue_Projections__c) {
                recordIds.add(v.Id);
            }
            else if(v.Vsl_End_Date__c != oldrec.Vsl_End_Date__c) {
                recordIds.add(v.Id);
            }
            else if(v.Vsl_Start_Date__c != oldrec.Vsl_Start_Date__c) {
                recordIds.add(v.Id);
            }
        }
        delete [SELECT Id From Contract_Billing_Plan__c WHERE Contract_Vessel__c IN :recordIds];
        createBillingPlans(recordIds);
    }
    
    //Create Billing Plan record when Opportunities are inserted
    private static void createBillingPlans(Set<Id> vesselIds) {
        Boolean allowRun = rp_checkRecursive.conbillingPlanCodeCheckInsert();
        List<String> recordIds = new List<String>();
        if(allowRun) {
            List<Contract_Billing_Plan__c> billingPlans = new List<Contract_Billing_Plan__c>();
            Map<String,Integer> billingMethodMap = new Map<String,Integer>{'Monthly' => 1, 'Quarterly' => 3, 'Half yearly' => 6, 'Yearly' => 12};
            Map<String,Schema.RecordTypeInfo> contRT = Contract.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            String contractRT_Id = contRT.get('Safety_Contract').getRecordTypeId();
            
            Contract_Vessels__c[] vesselRecords = [SELECT Id, Contract__c, Vsl_End_Date__c, Vsl_Start_Date__c,Contract__r.Status,Contract__r.RecordTypeId,Contract__r.Invoicing_Intervals__c,
                                                   Create_Revenue_Projections__c,Name FROM Contract_Vessels__c WHERE Id IN :vesselIds];

            for(Contract_Vessels__c o : vesselRecords) {
                if(o.Contract__r.RecordTypeId == contractRT_Id && o.Contract__r.Status == 'Active' && o.Create_Revenue_Projections__c && String.IsNotBlank(o.Contract__r.Invoicing_Intervals__c)) {
                    Integer durationMonths = null;
                    Decimal iterations = null;
                    Date billingDate = null;
                    Integer order = 0;
                    if(o.Vsl_Start_Date__c != null && o.Vsl_End_Date__c != null) {
                        durationMonths = o.Vsl_Start_Date__c.monthsBetween(o.Vsl_End_Date__c);    
                        if (o.Vsl_End_Date__c.day() > o.Vsl_Start_Date__c.day()) durationMonths++;
                    }
                    Decimal billingMethodValue = billingMethodMap.get(o.Contract__r.Invoicing_Intervals__c);
                    if(billingMethodValue != null) iterations = Math.floor(durationMonths / billingMethodValue);
                    for(integer i=1;i<=iterations.intValue();i++) {
                        Contract_Billing_Plan__c cbp = new Contract_Billing_Plan__c();
                        cbp.Contract_Vessel__c = o.Id;
                        cbp.Name = o.Name;
                        cbp.Order__c = i;
                        if(i == 1) billingDate = o.Vsl_Start_Date__c;
                        if(i > 1) billingDate = billingDate.addMonths(billingMethodValue.intValue());
                        cbp.Billing_Date__c = billingDate;
                        cbp.Billing_Rate__c = ((billingMethodValue * 100) / 12);
                        order++;                         
                        billingPlans.add(cbp);
                    }
                    recordIds.add(o.Id);
                }  
            }
            if(billingPlans.size() >0) insert billingPlans;
            if(recordIds.size() >0) System.enqueueJob(new rp_contractRevenueProjectionJob(recordIds));
        }        
    }
}