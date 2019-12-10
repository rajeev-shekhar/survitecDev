//Code to stop code recursion
//Author: Rajeev Shekhar

public Class rp_checkRecursive{
    private static boolean billingPlanCodeFlagInsert = true;
    private static boolean conbillingPlanCodeFlagInsert = true;
    
    public static boolean billingPlanCodeCheckInsert(){
        if(billingPlanCodeFlagInsert){
            billingPlanCodeFlagInsert = false;
            return true;
        }else{
            return billingPlanCodeFlagInsert;
        }
    }
    public static boolean conbillingPlanCodeCheckInsert(){
        if(conbillingPlanCodeFlagInsert){
            conbillingPlanCodeFlagInsert = false;
            return true;
        }else{
            return conbillingPlanCodeFlagInsert;
        }
    }
}