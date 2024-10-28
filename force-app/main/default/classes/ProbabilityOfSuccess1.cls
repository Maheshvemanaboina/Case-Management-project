public without sharing class ProbabilityOfSuccess1 {
    public List<Project__c> listOfProj{get;set;}
    public Id proid{get;set;}
    
    public String currentuser{get;set;}
    public Project__c pro{get;set;}

    public ProbabilityOfSuccess1(ApexPages.StandardController controller) {
        listOfProj = new List<Project__c>();
        currentuser = UserInfo.getUserRoleId();
        proid = ApexPages.currentPage().getParameters().get('id');
        this.pro=(Project__c)controller.getrecord();

        fetchMydtpList();
    }
    
    public void fetchMydtpList(){
        
        listOfProj = new List<Project__c>([SELECT id, Name, Launch_Year_2018__c, Year_1_after_Launch__c, Year_2_after_Launch__c , Year_3_after_Launch__c, Year_4_after_Launch__c, Year_5_after_Launch__c,Launch_year_2018_Net_Sales__c,Year_1_after_Launch_Net_Sales__c,Year_2_after_Launch_Net_Sales__c,Year_3_after_Launch_Net_Sales__c, Year_4_after_Launch_Net_Sales__c, Year_5_after_Launch_Net_Sales__c,Year_6_after_Launch_Net_sales__c,
        Total_Net_Sales__c,Total_Volume__c,Gross_Profit__c,Gross_Profit_per_1_yr_after_Launch__c,Gross_Profit_2_yr_after_Launch__c  ,Gross_Profit_3_yr_after_launch__c,Gross_Profit_4_yr_after_launch__c,Gross_Profit_5_yr_after_launch__c,Gross_Profit_6_yr_after_launch__c,Gross_Profit1_7_yr_after_launch__c,Gross_Profit1_8_yr_after_launch__c,Gross_Profit1_9_yr_after_launch__c,
        Cross_Profit_Launch_Year_2018__c ,Cross_Profit_1_Yr_after_Launch__c,Cross_Profit_2_yr_after_launch__c,Cross_Profit_3_yr_after_launch__c,Cross_Profit_4_yr_after_Launch__c, Cross_Profit_5_yr_after_launch__c,Cross_Profit_6_yr_after_launch__c,Gross_Profit_7_yr_after_launch__c,Gross_profit_8_yr_after_launch__c, Gross_profit_9_yr_after_launch__c,Incremental_Volume__c,Total_Incrementall_volume__c,
                                           Year_1_after_Incremental_value__c,Year_2_after_Incremental_value__c,Year_3_after_Incremental_volume__c,Year_4_after_Incremental_volume__c,Year_5_after_Incremental_volume__c,Year_6_after_Incremental_volume__c,Year_7_after_Incremental_volume__c,Year_8_after_Incremental_volume__c,Year_9_after_Incremental_volume__c,Total_Inc_Net_Sales__c,Launch_year_2018_Incremental_Net_Sales__c,Year_1_after_Launch_Inc_Net_Sales__c,
                                           Year_2_after_Launch_Inc_Net_Sales__c,Year_3_after_Launch_Inc_Net_Sales__c,Year_4_after_Launch_Inc_Net_Sales__c,Year_5_after_Launch_Inc_Net_Sales__c,Year_6_after_Launch_Inc_Net_Sales__c,Year_7_after_Launch_Inc_Net_Sales__c,Year_8_after_Launch_Inc_Net_Sales__c,Year_9_after_Launch_Inc_Net_Sales__c,Inc_Gross_Profit_Launch__c,
                                           Inc_Gross_Profit_1_Yr_after_Launch_c__c,Inc_Gross_Profit_2_yr_after_Launch__c,Inc_Gross_Profit_3_yr_after_Launch__c,Inc_Gross_Profit_4_yr_after_Launch__c,Inc_Gross_Profit_5_yr_after_Launch__c,Inc_Gross_Profit_6_yr_after_Launch__c,
                                           Inc_Gross_Profit_7_yr_after_Launch__c,Inc_Gross_Profit_8_yr_after_Launch__c,Inc_Gross_Profit_9_yr_after_Launch__c,Total_inc_Gross_Profit__c
                                           FROM Project__c WHERE Id =: proid]);

        }
        
    public void save(){
        System.debug(' before pro'+pro);
        update pro; 
        System.debug('pro'+pro);
        
    }    
    
}