//Author: Rajeev Shekhar

public inherited sharing class rp_opportunityRevenueProjectionFunctions {

    public static List<Revenue_Projection_Opportunity__c> getOpportunityProjectionsToDelete(Set<Id> oppIds, Set<Id> productIds) {
        Revenue_Projection_Opportunity__c[] rpdelete = [SELECT Id FROM Revenue_Projection_Opportunity__c WHERE Opportunity__c IN :oppIds
                                                        AND Product__c IN :productIds AND Status__c = 'Invalid'];
       return rpdelete;                                                
    }

}