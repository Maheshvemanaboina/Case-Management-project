@isTest
public with sharing class CommunityKPITestUtility {
    Static String year;
	Static Date startDate;
	Static Date endDate;
	Static String period;
	Static Integer halfYear;
    
    public CommunityKPITestUtility(){
            year = ''+System.Today().year();
            halfYear  = date.today().month();
            if(halfYear <= 6){
                  period = period;
                  startDate = Date.newInstance(Integer.valueof(year), 1, 1);
                  endDate = Date.newInstance(Integer.valueof(year), 6, 30);
            }else{
                  period = '2nd Half Year';
                  startDate = Date.newInstance(Integer.valueof(year), 7, 1);
                  endDate = Date.newInstance(Integer.valueof(year), 12, 31);
            }
   		 }
    
    public static Commercial_Activity__c createCommercialActivityMaster(Account distributorLoc){

        Commercial_Activity__c commAct = new Commercial_Activity__c(Name = 'Master Commercial Activity',
                                                                    RecordTypeId = KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID,
                                                                    Distributor_Account__c = distributorLoc.Id,
                                                                    Fiscal_Year_FY__c = year,
                                                                    Period__c = period,
                                                                    Period_Start_Date__c = startDate,
                                                                    Period_End_Date__c = endDate,
                                                                    OwnerId = distributorLoc.OwnerId);
        return commAct;
    }

    public static Commercial_Activity__c createPromotionActivityBucket(Account distributorLoc, Commercial_Activity__c parentCommAct){

        Commercial_Activity__c commAct = new Commercial_Activity__c(Name = 'Promotion Activity Bucket',
                                                                    RecordTypeId = KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID,
                                                                    Fiscal_Year_FY__c = year,
                                                                    Parent_Commercial_Activity__c = parentCommAct.Id,
                                                                    Period__c = period,
                                                                    Commercial_Activity_Type__c = 'Promotion Activities',
                                                                    Period_Start_Date__c = startDate,
                                                                    Period_End_Date__c = endDate,
                                                                    OwnerId = distributorLoc.OwnerId,
                                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return commAct;
    }

    public static Commercial_Activity__c createCustomerVisitsBucket(Account distributorLoc, Commercial_Activity__c parentCommAct){

        Commercial_Activity__c commAct = new Commercial_Activity__c(Name = 'Customer Visit Bucket',
                                                                    RecordTypeId = KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID,
                                                                    Fiscal_Year_FY__c = year,
                                                                    Parent_Commercial_Activity__c = parentCommAct.Id,
                                                                    Commercial_Activity_Type__c = 'Customer Visits',
                                                                    Period__c = period,
                                                                    Period_Start_Date__c = startDate,
                                                                    Period_End_Date__c = endDate,
                                                                    OwnerId = distributorLoc.OwnerId,
                                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return commAct;
    }

    public static Commercial_Activity__c createSamplesBucket(Account distributorLoc, Commercial_Activity__c parentCommAct){

        Commercial_Activity__c commAct = new Commercial_Activity__c(Name = 'Samples Bucket',
                                                                    RecordTypeId = KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID,
                                                                    Fiscal_Year_FY__c = year,
                                                                    Parent_Commercial_Activity__c = parentCommAct.Id,
                                                                    Commercial_Activity_Type__c = 'Samples',
                                                                    Period__c = period,
                                                                    Period_Start_Date__c = startDate,
                                                                    Period_End_Date__c = endDate,
                                                                    OwnerId = distributorLoc.OwnerId,
                                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return commAct;
    }

    public static Commercial_Activity__c createPromotionActivity(Account distributorLoc, Commercial_Activity__c parentCommercialAct){

        Commercial_Activity__c commAct = new Commercial_Activity__c(Name = 'Promotion Activity',
                                                                    RecordTypeId = KPIConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID,
                                                                    Fiscal_Year_FY__c = year,
                                                                    Commercial_Activity_Promotion_Activity__c = parentCommercialAct.Id,
                                                                    Period__c = period,
                                                                    Commercial_Activity_Type__c = 'Promotion Activities',
                                                                    Period_Start_Date__c = startDate,
                                                                    Period_End_Date__c = endDate,
                                                                    Promotion_Activity_Date__c = Date.today(),
                                                                    Promotion_Activity_Type__c = 'Advertisement',
                                                                    Comments__c = 'Test',
                                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return commAct;
    }

    public static Commercial_Activity__c createSamples(Account distributorLoc, Commercial_Activity__c parentCommercialAct){

        Commercial_Activity__c commAct = new Commercial_Activity__c(Name = 'Samples',
                                                                    RecordTypeId = KPIConstants.SAMPLE_RECORD_TYPE_ID,
                                                                    Fiscal_Year_FY__c = year,
                                                                    Commercial_Activity_Sample__c = parentCommercialAct.Id,
                                                                    Period__c = period,
                                                                    Commercial_Activity_Type__c = 'Samples',
                                                                    Period_Start_Date__c = startDate,
                                                                    Period_End_Date__c = endDate,
                                                                    No_of_Opportunities_Created__c = 10,
                                                                    No_of_Opportunities_Won__c = 5,
                                                                    No_of_Samples_Requested__c = 8,
                                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return commAct;
    }

    public static Commercial_Activity__c createCustomerVisit(Account distributorLoc, Commercial_Activity__c parentCommercialAct){

        Commercial_Activity__c commAct = new Commercial_Activity__c(Name = 'Customer Visit',
                                                                    RecordTypeId = KPIConstants.CUSTOMER_VISIT_RECORD_TYPE_ID,
                                                                    Fiscal_Year_FY__c = year,
                                                                    Commercial_Activity_Customer_Visit__c = parentCommercialAct.Id,
                                                                    Period__c = period,
                                                                    Commercial_Activity_Type__c = 'Customer Visits',
                                                                    Period_Start_Date__c = startDate,
                                                                    Period_End_Date__c = endDate,
                                                                    Visit_Date__c = Date.today(),
                                                                    Visit_Type__c = 'Video Call',
                                                                    Agenda_Discussed__c = 'Test',
                                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return commAct;
    }

    public static Sales_Funnel__c createSalesPerformanceMaster(Account distributorLoc){

        Sales_Funnel__c sMaster = new Sales_Funnel__c(Name = 'Master Sales Performance',
                                                    RecordTypeId = KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID,
                                                    Distributor_Account__c = distributorLoc.Id,
                                                    Fiscal_Year_FY__c = year,
                                                    Period__c = period,
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    OwnerId = distributorLoc.OwnerId);
        return sMaster;
    }

    public static Sales_Funnel__c createDistributorSalesToEndCustomerBucket(Account distributorLoc, Sales_Funnel__c parentSalesFunnel){

        Sales_Funnel__c distributorSalesBucket = new Sales_Funnel__c(Name = 'Distributor Sales To End Customer Bucket',
                                                            RecordTypeId = KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID,
                                                            Fiscal_Year_FY__c = year,
                                                            Sales_Funnel_Type__c = 'Sales-To-End Customer',
                                                            Parent_Sales_Funnel__c = parentSalesFunnel.Id,
                                                            Period__c = period,
                                                            Period_Start_Date__c = startDate,
                                                            Period_End_Date__c = endDate,
                                                            OwnerId = distributorLoc.OwnerId,
                                                            Distributor_Account_Name__c = distributorLoc.Id,
                                                            Distributor_Parent_Account__c = distributorLoc.ParentId);
        return distributorSalesBucket;
    }

    public static Sales_Funnel__c createDistributorSalesToEndCustomer(Account distributorLoc, Sales_Funnel__c parentSalesFunnel){

        Sales_Funnel__c commAct = new Sales_Funnel__c(Name = 'Distributor Sales To End Customer',
                                                    RecordTypeId = KPIConstants.DISTI_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID,
                                                    Fiscal_Year_FY__c = year,
                                                    Sales_Funnel_Sales_To_End_Customer__c = parentSalesFunnel.Id,
                                                    Period__c = period,
                                                    Sales_Funnel_Type__c = 'Sales-To-End Customer',
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    Business_Segment__c = 'Industry',
                                                    Volume_MT__c = 200,
                                                    Comments__c = 'Test',
                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return commAct;
    }

    public static Forecast_Accuracy__c createForecastAccuracyMaster(Account distributorLoc){

        Forecast_Accuracy__c forecastMaster = new Forecast_Accuracy__c(Name = 'Forecast Accuracy Master',
                                                    RecordTypeId = KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID,
                                                    Distributor_Account__c = distributorLoc.Id,
                                                    Fiscal_Year_FY__c = year,
                                                    Period__c = period,
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    OwnerId = distributorLoc.OwnerId);
        return forecastMaster;
    }

    public static Forecast_Accuracy__c createLocalStockBucket(Account distributorLoc, Forecast_Accuracy__c parentForecastAccuracy){

        Forecast_Accuracy__c localStockBucket = new Forecast_Accuracy__c(Name = 'Local Stock Bucket',
                                                            RecordTypeId = KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID,
                                                            Fiscal_Year_FY__c = year,
                                                            Forecast_Type__c = 'Local Stock',
                                                            Parent_Forecast__c = parentForecastAccuracy.Id,
                                                            Period__c = period,
                                                            Period_Start_Date__c = startDate,
                                                            Period_End_Date__c = endDate,
                                                            OwnerId = distributorLoc.OwnerId,
                                                            Distributor_Account_Name__c = distributorLoc.Id,
                                                            Distributor_Parent_Account__c = distributorLoc.ParentId);
        return localStockBucket;
    }

    public static Forecast_Accuracy__c createLocalStock(Account distributorLoc, Forecast_Accuracy__c parentForecastAccuracy){

        Forecast_Accuracy__c localStock = new Forecast_Accuracy__c(Name = 'Local Stock',
                                                    RecordTypeId = KPIConstants.LOCAL_STOCK_RECORD_TYPE_ID,
                                                    Fiscal_Year_FY__c = year,
                                                    Forecast_Accuracy_Local_Stock__c = parentForecastAccuracy.Id,
                                                    Period__c = period,
                                                    Forecast_Type__c = 'Local Stock',
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    Local_Stock_Status__c = 'One month of stock',
                                                    Comments__c = 'Test',
                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return localStock;
    }

    public static FCI_Customer_Support__c createFCICustomerSupportMaster(Account distributorLoc){

        FCI_Customer_Support__c FCISupportMaster = new FCI_Customer_Support__c(Name = 'FCI Customer Support Master',
                                                    RecordTypeId = KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID,
                                                    Distributor_Account__c = distributorLoc.Id,
                                                    Fiscal_Year_FY__c = year,
                                                    Period__c = period,
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    OwnerId = distributorLoc.OwnerId);
        return FCISupportMaster;
    }

    public static FCI_Customer_Support__c createOrderProcessBucket(Account distributorLoc, FCI_Customer_Support__c parentFCICustomerSupport){

        FCI_Customer_Support__c orderProcessBucket = new FCI_Customer_Support__c(Name = 'Order Process Bucket',
                                                        RecordTypeId = KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID,
                                                        Fiscal_Year_FY__c = year,
                                                        Parent_FCI_Customer_Support__c = parentFCICustomerSupport.Id,
                                                        Period__c = period,
                                                        FCI_Customer_Support_Type__c = 'Order Process',
                                                        Period_Start_Date__c = startDate,
                                                        Period_End_Date__c = endDate,
                                                        OwnerId = distributorLoc.OwnerId,
                                                        Distributor_Account_Name__c = distributorLoc.Id,
                                                        Distributor_Parent_Account__c = distributorLoc.ParentId);
        return orderProcessBucket;
    }

    public static FCI_Customer_Support__c createComplaintsBucket(Account distributorLoc, FCI_Customer_Support__c parentFCICustomerSupport){

        FCI_Customer_Support__c orderProcessBucket = new FCI_Customer_Support__c(Name = 'Complaints Bucket',
                                                        RecordTypeId = KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID,
                                                        Fiscal_Year_FY__c = year,
                                                        Parent_FCI_Customer_Support__c = parentFCICustomerSupport.Id,
                                                        Period__c = period,
                                                        FCI_Customer_Support_Type__c = 'Complaints',
                                                        Period_Start_Date__c = startDate,
                                                        Period_End_Date__c = endDate,
                                                        OwnerId = distributorLoc.OwnerId,
                                                        Distributor_Account_Name__c = distributorLoc.Id,
                                                        Distributor_Parent_Account__c = distributorLoc.ParentId);
        return orderProcessBucket;
    }

    public static FCI_Customer_Support__c createOrderProcess(Account distributorLoc, FCI_Customer_Support__c parentFCICustomerSuport){

        FCI_Customer_Support__c orderProcess = new FCI_Customer_Support__c(Name = 'Order Process',
                                                    RecordTypeId = KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID,
                                                    Fiscal_Year_FY__c = year,
                                                    FCI_Customer_Support_Order_Process__c = parentFCICustomerSuport.Id,
                                                    Period__c = period,
                                                    FCI_Customer_Support_Type__c = 'Order Process',
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    Order_policy_adherence__c = '>80 & <90% orders in line with order policy',
                                                    Comments__c = 'Test',
                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return orderProcess;
    }

    public static Business_Strategy__c createBusinessStrategyMaster(Account distributorLoc){

        Business_Strategy__c BusinessStrategyAccMaster = new Business_Strategy__c(Name = 'Master Business Strategy',
                                                    RecordTypeId = KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID,
                                                    Distributor_Account__c = distributorLoc.Id,
                                                    Fiscal_Year_FY__c = year,
                                                    FY_Start_Date__c = startDate,
                                                    FY_End_Date__c = Date.newInstance(2022, 12, 31),
                                                    OwnerId = distributorLoc.OwnerId);
        return BusinessStrategyAccMaster;
    }

    public static Business_Strategy__c createAccountPlanBucket(Account distributorLoc, Business_Strategy__c parentBusinessStrategy){

        Business_Strategy__c BusinessStrategyAccontPlanBucket = new Business_Strategy__c(Name = 'Account Plan Bucket',
                                                    RecordTypeId = KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID,
                                                    Fiscal_Year_FY__c = year,
                                                    Business_Strategy_Type__c = 'Account Plan',
                                                    Parent_Business_Strategy__c = parentBusinessStrategy.Id,
                                                    Period__c = period,
                                                    FY_Start_Date__c = startDate,
                                                    FY_End_Date__c = Date.newInstance(2022, 12, 31),
                                                    OwnerId = distributorLoc.OwnerId,
                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return BusinessStrategyAccontPlanBucket;
    }

    public static Business_Strategy__c createHighLightsBucket(Account distributorLoc, Business_Strategy__c parentBusinessStrategy){

        Business_Strategy__c highLightsBucket = new Business_Strategy__c(Name = 'High Lights Bucket',
                                                        RecordTypeId = KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID,
                                                        Fiscal_Year_FY__c = year,
                                                        Parent_Business_Strategy__c = parentBusinessStrategy.Id,
                                                        Period__c = period,
                                                        Business_Strategy_Type__c = 'High & low Lights',
                                                        Period_Start_Date__c = startDate,
                                                        Period_End_Date__c = endDate,
                                                        OwnerId = distributorLoc.OwnerId,
                                                        Distributor_Account_Name__c = distributorLoc.Id,
                                                        Distributor_Parent_Account__c = distributorLoc.ParentId);
        return highLightsBucket;
    }

    public static Business_Strategy__c createCompetitionBucket(Account distributorLoc, Business_Strategy__c parentBusinessStrategy){

        Business_Strategy__c competitionsBucket = new Business_Strategy__c(Name = 'Competitions Bucket',
                                                        RecordTypeId = KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID,
                                                        Fiscal_Year_FY__c = year,
                                                        Parent_Business_Strategy__c = parentBusinessStrategy.Id,
                                                        Period__c = period,
                                                        Business_Strategy_Type__c = 'Competition',
                                                        Period_Start_Date__c = startDate,
                                                        Period_End_Date__c = endDate,
                                                        OwnerId = distributorLoc.OwnerId,
                                                        Distributor_Account_Name__c = distributorLoc.Id,
                                                        Distributor_Parent_Account__c = distributorLoc.ParentId);
        return competitionsBucket;
    }

    public static Business_Strategy__c createHighLowLights(Account distributorLoc, Business_Strategy__c parentBusinessStrategy){

        Business_Strategy__c highLights = new Business_Strategy__c(Name = 'High & Low Lights',
                                                    RecordTypeId = KPIConstants.HIGH_LOW_LIGHT_RECORD_TYPE_ID,
                                                    Fiscal_Year_FY__c = year,
                                                    Business_Strategy_High_Low_Lights__c = parentBusinessStrategy.Id,
                                                    Period__c = period,
                                                    Business_Strategy_Type__c = 'High & low Lights',
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    High_Lights__c = 'New employee',
                                                    Additional_Info__c = 'Test',
                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return highLights;
    }

    public static Business_Strategy__c createCompetitions(Account distributorLoc, Business_Strategy__c parentBusinessStrategy,Account competitorAccount){

        Business_Strategy__c competitions = new Business_Strategy__c(Name = 'Competitions',
                                                    RecordTypeId = KPIConstants.COMPETITION_RECORD_TYPE_ID,
                                                    Fiscal_Year_FY__c = year,
                                                    Business_Strategy_Competition__c = parentBusinessStrategy.Id,
                                                    Period__c = period,
                                                    Business_Strategy_Type__c = 'Competition',
                                                    Period_Start_Date__c = startDate,
                                                    Period_End_Date__c = endDate,
                                                    Competitor_Account__c = competitorAccount.Id,
                                                    Information__c = 'Market Share',
                                                    Comments__c = 'Test',
                                                    Distributor_Account_Name__c = distributorLoc.Id,
                                                    Distributor_Parent_Account__c = distributorLoc.ParentId);
        return competitions;
    }

    public static Field_of_Play__c createAccountPlan(Business_Strategy__c accountPlanBucket){

        Field_of_Play__c accountPlan = new Field_of_Play__c(Business_Segment__c = 'Industry',
                                                            Additional_Countries__c = 'Afghanistan;Aland Islands',
                                                            Other_Principals__c = 'Agropalma;Bell Flavors & Fragrances',
                                                            Sub_Segment__c = 'Food',
                                                            Distributor_Business_Strategy__c = accountPlanBucket.Id,
                                                            Growth_Opportunities__c = 'Growth',
                                                            RecordTypeId = CountryPlanController.ACCOUNT_PLAN_DISTRIBUTOR_RECORD_TYPE_ID,
                                                            Strength__c = 'Strength',
                                                            Weakness__c = 'Weakness',
                                                            Sweet_Spot__c = 'Opportunity',
                                                            Sour_Spot__c = 'Threats');
        
        return accountPlan;
    }

    public static Share_of_Wallet__c createShareOfWallet(Field_of_Play__c accountPlan){

        Share_of_Wallet__c shareOfWal = new Share_of_Wallet__c(Distributor_Volume_in_mT__c = 200,
                                                                FCI_Budget_Volume_in_mT__c = 100,
                                                                Field_of_Play__c = accountPlan.Id);
        return shareOfWal;
    }

    public static Other_Related_Customer_Location__c createRelatedCustomerLocation(Field_of_Play__c accountPlan, Account acc){

        Other_Related_Customer_Location__c otherRelCustLoc = new Other_Related_Customer_Location__c(Account_Plan__c = accountPlan.Id,
                                                                                                    Distributor_Location__c = acc.Id,
                                                                                                    RecordTypeId = CountryPlanController.OTHER_CUST_LOC_RECORD_TYPE_ID);
        return otherRelCustLoc;
    }

    public static Business_Strategy__c createCompetitorInfoForAccountPlan(Field_of_Play__c accountPlan, Account competitorAccount){

        Business_Strategy__c competitorInfo = new Business_Strategy__c(RecordTypeId = KPIConstants.COMPETITION_ACCOUNT_PLAN_RECORD_TYPE_ID,
                                                                        Name = 'Competitor Account Plan',
                                                                        Direct_Supply__c = 'Yes',
                                                                        Name_of_Distributors__c = 'Test',
                                                                        Competitor_Account__c = competitorAccount.Id,
                                                                        Account_Plan__c = accountPlan.Id);
        return competitorInfo;
    }
}