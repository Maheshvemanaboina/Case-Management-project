/*       
@Name           - CommunityKPICreationHandler , TestClass = "CommunityKPICreationHandlerTest"
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 12-08-2020

@Description    - This is used to create all KPI Master and Buckets records for distributors
@Changes        - 1. Changed to accomodate new KPI Structure

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 12-08-2020    | Created Class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 20-09-2021    | Updated class to accomodate new KPI Structure
*/
public without sharing class CommunityKPICreationHandler {
    
    private static Map<String,Date> halfYearStartDates;
    private static Map<String,Date> halfYearEndDates;
    private static Map<Id,User> cusLocOwnerMap;
    private static Map<Id,Decimal> recordTypeWeightMap;
    private static List<String> halfYears;

    public static void createKPIRecords(String fiscalYear){

        /* Null Parameter ( new List<String>() ) to create records for all distributors and period blank to indicate for both the half years */
        createMasterKPIRecords(fiscalYear, new Set<Id>());
        createBucketKPIRecords(fiscalYear, '', new Set<Id>());
    }

    public static void createKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        /* Null Parameter ( new List<String>() ) to create records for all distributors and period blank to indicate for both the half years */
        createMasterKPIRecords(fiscalYear, distributorLocationIds);
        createBucketKPIRecords(fiscalYear, '', distributorLocationIds);
    }

    public static void createKPIRecords(String fiscalYear,String period){

        /* Null Parameter ( new List<String>() ) to create records for all distributors */
        createMasterKPIRecords(fiscalYear, new Set<Id>());
        createBucketKPIRecords(fiscalYear, period, new Set<Id>());
    }

    /* Overloaded CreateKPIRecords to create KPIs for specific Distributors */
    public static void createKPIRecords(String fiscalYear,String period, Set<Id> distributorLocationIds){

        createMasterKPIRecords(fiscalYear, distributorLocationIds);
        createBucketKPIRecords(fiscalYear, period, distributorLocationIds);
    }

    /* The below 3 methods are only for Account Plan KPI creation because it needs more records to be created beforehand, like for 2020,2021,2022,2023 etc */
    public static void createAccountPlanKPIRecords(String fiscalYear){

        createMasterAccountPlanKPIRecords(fiscalYear, new Set<Id>());
        createAccountPlanBucketKPIRecords(fiscalYear, new Set<Id>());
    }

    /* Overloaded createAccountPlanKPIRecords to create KPIs for specific Distributors */
    public static void createAccountPlanKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        createMasterAccountPlanKPIRecords(fiscalYear, distributorLocationIds);
        createAccountPlanBucketKPIRecords(fiscalYear, distributorLocationIds);
    }

    public static void createMasterAccountPlanKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> allMasterKPIList = new List<SObject>();
        allMasterKPIList.addAll(getBusinessStrategyMasterKPIRecords(fiscalYear, distributorLocationIds));

        if(!allMasterKPIList.isEmpty()){
            insert allMasterKPIList;
        }
    }

    public static void createAccountPlanBucketKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> allBucketKPIList = new List<SObject>();
        allBucketKPIList.addAll(getBusinessStrategyAccountPlanBucketKPIRecords(fiscalYear, distributorLocationIds));
        
        if(!allBucketKPIList.isEmpty()){
            insert allBucketKPIList;
        }
    }

    public static void createMasterKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> allMasterKPIList = new List<SObject>();
        allMasterKPIList.addAll(getCommercialActivityMasterKPIRecords(fiscalYear, distributorLocationIds));
        allMasterKPIList.addAll(getForecastAccuracyMasterKPIRecords(fiscalYear, distributorLocationIds));
        allMasterKPIList.addAll(getSalesPerformanceMasterKPIRecords(fiscalYear, distributorLocationIds));
        allMasterKPIList.addAll(getFCICustomerSupportMasterKPIRecords(fiscalYear, distributorLocationIds));
        allMasterKPIList.addAll(getBusinessStrategyMasterKPIRecords(fiscalYear, distributorLocationIds));
        //allMasterKPIList.addAll(getHighLowCompetitionMasterKPIRecords(fiscalYear, distributorLocationIds));

        if(!allMasterKPIList.isEmpty()){
            insert allMasterKPIList;
        }
    }

    public static void createBucketKPIRecords(String fiscalYear, String period, Set<Id> distributorLocationIds){

        List<SObject> allBucketKPIList = new List<SObject>();
        allBucketKPIList.addAll(getCommercialActivityBucketKPIRecords(fiscalYear, period, distributorLocationIds));
        allBucketKPIList.addAll(getForecastAccuracyBucketKPIRecords(fiscalYear, period, distributorLocationIds));
        allBucketKPIList.addAll(getSalesPerformanceBucketKPIRecords(fiscalYear, period, distributorLocationIds));
        allBucketKPIList.addAll(getFCICustomerSupportBucketKPIRecords(fiscalYear, period, distributorLocationIds));
        allBucketKPIList.addAll(getBusinessStrategyBucketKPIRecords(fiscalYear, period, distributorLocationIds));
        
        if(!allBucketKPIList.isEmpty()){
            insert allBucketKPIList;
        }
    }

    /* Handles creation of all the bucket records after the master records are created. */
    private static List<SObject> getCommercialActivityBucketKPIRecords(String fiscalYear, String period, Set<Id> distributorLocationIds){

        Set<Id> recordTypeIds = new Set<Id>{KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID,
                                            KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID,
                                            KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID};
        
        List<SObject> bucketListToInsert = new List<SObject>();

        List<String> existingBucketRecords = getBucketNameIdList(getExistingBucketKPIRecords('Commercial_Activity__c', recordTypeIds, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        Map<String,Id> parentNameIdMap = getParentNameIdMap(getExistingMasterKPIRecords('Commercial_Activity__c', KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        
        if(!String.isBlank(period)){

            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Promotion Activity', fiscalYear, period, 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Promotion Activities', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Samples', fiscalYear, period, 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Samples', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Customer Visit', fiscalYear, period, 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Customer Visits', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        } else{

            /* 1st call for 1st Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Promotion Activity', fiscalYear, getHalfYears().get(0) , 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Promotion Activities', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Samples', fiscalYear, getHalfYears().get(0), 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Samples', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Customer Visit', fiscalYear, getHalfYears().get(0), 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Customer Visits', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

            /* 2nd call for 2nd Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Promotion Activity', fiscalYear, getHalfYears().get(1), 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Promotion Activities', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Samples', fiscalYear, getHalfYears().get(1), 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Samples', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID, 'Commercial_Activity__c', 'Customer Visit', fiscalYear, getHalfYears().get(1), 'Commercial Activity', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_COMMERCIAL_ACTIVITY_RELATION,'Commercial_Activity_Type__c','Customer Visits', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        }

        return bucketListToInsert;
    }

    private static List<SObject> getForecastAccuracyBucketKPIRecords(String fiscalYear, String period, Set<Id> distributorLocationIds){

        Set<Id> recordTypeIds = new Set<Id>{KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID};
        
        List<SObject> bucketListToInsert = new List<SObject>();

        List<String> existingBucketRecords = getBucketNameIdList(getExistingBucketKPIRecords('Forecast_Accuracy__c', recordTypeIds, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        Map<String,Id> parentNameIdMap = getParentNameIdMap(getExistingMasterKPIRecords('Forecast_Accuracy__c', KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

        if(!String.isBlank(period)){

            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID, 'Forecast_Accuracy__c', 'Local Stock', fiscalYear, period, 'Forecast Accuracy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FORECAST_ACCURACY_RELATION,'Forecast_Type__c','Local Stock', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        }else{

            /* 1st call for 1st Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID, 'Forecast_Accuracy__c', 'Local Stock', fiscalYear, getHalfYears().get(0), 'Forecast Accuracy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FORECAST_ACCURACY_RELATION,'Forecast_Type__c','Local Stock', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

            /* 2nd call for 2nd Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID, 'Forecast_Accuracy__c', 'Local Stock', fiscalYear, getHalfYears().get(1), 'Forecast Accuracy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FORECAST_ACCURACY_RELATION,'Forecast_Type__c','Local Stock', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        }

        return bucketListToInsert;
    }

    private static List<SObject> getSalesPerformanceBucketKPIRecords(String fiscalYear, String period, Set<Id> distributorLocationIds){

        Set<Id> recordTypeIds = new Set<Id>{KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID,
            								KPIConstants.SALES_FUNNEL_SALES_TO_DISTRIBUTOR_NEW_BUSINESS_RECORD_TYPE_ID};
        
        List<SObject> bucketListToInsert = new List<SObject>();

        List<String> existingBucketRecords = getBucketNameIdList(getExistingBucketKPIRecords('Sales_Funnel__c', recordTypeIds, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        Map<String,Id> parentNameIdMap = getParentNameIdMap(getExistingMasterKPIRecords('Sales_Funnel__c', KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

        if(!String.isBlank(period)){
            
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID, 'Sales_Funnel__c', 'Sales To End Customer', fiscalYear, period, 'Sales Performance', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_SALES_FUNNEL_RELATION,'Sales_Funnel_Type__c','Sales-To-End Customer', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
		    bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.SALES_FUNNEL_SALES_TO_DISTRIBUTOR_NEW_BUSINESS_RECORD_TYPE_ID, 'Sales_Funnel__c', 'New Business End Customers', fiscalYear, period, 'Sales Performance', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_SALES_FUNNEL_RELATION,'Sales_Funnel_Type__c','New Business', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        }else{

            /* 1st call for 1st Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID, 'Sales_Funnel__c', 'Sales To End Customer', fiscalYear, getHalfYears().get(0), 'Sales Performance', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_SALES_FUNNEL_RELATION,'Sales_Funnel_Type__c','Sales-To-End Customer', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
		    bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.SALES_FUNNEL_SALES_TO_DISTRIBUTOR_NEW_BUSINESS_RECORD_TYPE_ID, 'Sales_Funnel__c', 'New Business End Customers', fiscalYear, getHalfYears().get(0), 'Sales Performance', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_SALES_FUNNEL_RELATION,'Sales_Funnel_Type__c','New Business', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

            /* 2nd call for 2nd Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID, 'Sales_Funnel__c', 'Sales To End Customer', fiscalYear, getHalfYears().get(1), 'Sales Performance', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_SALES_FUNNEL_RELATION,'Sales_Funnel_Type__c','Sales-To-End Customer', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
		    bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.SALES_FUNNEL_SALES_TO_DISTRIBUTOR_NEW_BUSINESS_RECORD_TYPE_ID, 'Sales_Funnel__c', 'New Business End Customers', fiscalYear, getHalfYears().get(1), 'Sales Performance', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_SALES_FUNNEL_RELATION,'Sales_Funnel_Type__c','New Business', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        }

        return bucketListToInsert;
    }

    private static List<SObject> getFCICustomerSupportBucketKPIRecords(String fiscalYear, String period, Set<Id> distributorLocationIds){

        Set<Id> recordTypeIds = new Set<Id>{KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID,
                                            KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID};
        
        List<SObject> bucketListToInsert = new List<SObject>();

        List<String> existingBucketRecords = getBucketNameIdList(getExistingBucketKPIRecords('FCI_Customer_Support__c', recordTypeIds, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        Map<String,Id> parentNameIdMap = getParentNameIdMap(getExistingMasterKPIRecords('FCI_Customer_Support__c', KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

        if(!String.isBlank(period)){

            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID, 'FCI_Customer_Support__c', 'Order Process', fiscalYear, period, 'FC Support', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FCI_CUSTOMER_SUPPORT_RELATION,'FCI_Customer_Support_Type__c','Order Process', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID, 'FCI_Customer_Support__c', 'Complaints', fiscalYear, period, 'FC Support', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FCI_CUSTOMER_SUPPORT_RELATION,'FCI_Customer_Support_Type__c','Complaints', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        }else{

            /* 1st call for 1st Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID, 'FCI_Customer_Support__c', 'Order Process', fiscalYear, getHalfYears().get(0), 'FC Support', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FCI_CUSTOMER_SUPPORT_RELATION,'FCI_Customer_Support_Type__c','Order Process', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID, 'FCI_Customer_Support__c', 'Complaints', fiscalYear, getHalfYears().get(0), 'FC Support', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FCI_CUSTOMER_SUPPORT_RELATION,'FCI_Customer_Support_Type__c','Complaints', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

            /* 2nd call for 2nd Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID, 'FCI_Customer_Support__c', 'Order Process', fiscalYear, getHalfYears().get(1), 'FC Support', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FCI_CUSTOMER_SUPPORT_RELATION,'FCI_Customer_Support_Type__c','Order Process', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID, 'FCI_Customer_Support__c', 'Complaints', fiscalYear, getHalfYears().get(1), 'FC Support', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_FCI_CUSTOMER_SUPPORT_RELATION,'FCI_Customer_Support_Type__c','Complaints', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

        }

        return bucketListToInsert;
    }

    private static List<SObject> getBusinessStrategyBucketKPIRecords(String fiscalYear, String period, Set<Id> distributorLocationIds){

        Set<Id> recordTypeIds = new Set<Id>{KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID,
                                            KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID,
                                            KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID};
        
        List<SObject> bucketListToInsert = new List<SObject>();

        List<String> existingBucketRecords = getBucketNameIdList(getExistingBucketKPIRecords('Business_Strategy__c', recordTypeIds, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        Map<String,Id> parentNameIdMap = new Map<String,Id>();
        parentNameIdMap.putAll(getParentNameIdMap(getExistingMasterKPIRecords('Business_Strategy__c', KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds)));
        //parentNameIdMap.putAll(getParentNameIdMap(getExistingMasterKPIRecords('Business_Strategy__c', KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds)));
        
        //bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID, 'Business_Strategy__c', 'Account Plan', fiscalYear, period, 'Business Update', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Account Plan', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

        if(!String.isBlank(period)){

            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID, 'Business_Strategy__c', 'Account Plan', fiscalYear, period, 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Account Plan', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID, 'Business_Strategy__c', 'High & Low Lights', fiscalYear, period, 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','High & low Lights', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID, 'Business_Strategy__c', 'Competitor Information', fiscalYear, period, 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Competition', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        }else{

            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID, 'Business_Strategy__c', 'Account Plan', fiscalYear, getHalfYears().get(0), 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Account Plan', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

            /* 1st call for 1st Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID, 'Business_Strategy__c', 'High & Low Lights', fiscalYear, getHalfYears().get(0), 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','High & low Lights', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID, 'Business_Strategy__c', 'Competitor Information', fiscalYear, getHalfYears().get(0), 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Competition', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

            /* 2nd call for 2nd Half Year */
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID, 'Business_Strategy__c', 'High & Low Lights', fiscalYear, getHalfYears().get(1), 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','High & low Lights', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
            bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID, 'Business_Strategy__c', 'Competitor Information', fiscalYear, getHalfYears().get(1), 'Business Strategy', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Competition', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

        }

        return bucketListToInsert;
    }

    /* */
    private static List<SObject> getBusinessStrategyAccountPlanBucketKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        Set<Id> recordTypeIds = new Set<Id>{ KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID };
        
        List<SObject> bucketListToInsert = new List<SObject>();

        List<String> existingBucketRecords = getBucketNameIdList(getExistingBucketKPIRecords('Business_Strategy__c', recordTypeIds, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        Map<String,Id> parentNameIdMap = new Map<String,Id>();
        parentNameIdMap.putAll(getParentNameIdMap(getExistingMasterKPIRecords('Business_Strategy__c', KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds)));
        //parentNameIdMap.putAll(getParentNameIdMap(getExistingMasterKPIRecords('Business_Strategy__c', KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds)));
        
        //bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID, 'Business_Strategy__c', 'Account Plan', fiscalYear, period, 'Business Update', parentNameIdMap,existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Account Plan', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));
        bucketListToInsert.addAll(getBucketRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID, 'Business_Strategy__c', 'Account Plan', fiscalYear, '', 'Business Strategy', parentNameIdMap, existingBucketRecords, KPIConstants.PARENT_BUSINESS_STRATEGY_RELATION,'Business_Strategy_Type__c','Account Plan', distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds));

        return bucketListToInsert;
    }

    private static Map<String,Id> getParentNameIdMap(List<SObject> sObjectList){

        Map<String,Id> parentNameIdMap = new Map<String,Id>();
        for(SObject eachSObj : sObjectList){

            parentNameIdMap.put(String.valueOf(eachSObj.get('Name')) + String.valueOf(eachSObj.get('Distributor_Account__c')), (Id)eachSObj.get('Id'));
        }

        return parentNameIdMap;
    }

    /* Handle creation of all the Master KPI records from here */

    private static List<SObject> getCommercialActivityMasterKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> masterSObjList = getExistingMasterKPIRecords('Commercial_Activity__c', KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
        return getMasterRecordsToInsert(KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID, 'Commercial Activity', 'Commercial_Activity__c', getMasterNameIdList(masterSObjList), fiscalYear, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
    }

    private static List<SObject> getForecastAccuracyMasterKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> masterSObjList = getExistingMasterKPIRecords('Forecast_Accuracy__c', KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
        return getMasterRecordsToInsert(KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID, 'Forecast Accuracy', 'Forecast_Accuracy__c', getMasterNameIdList(masterSObjList), fiscalYear, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
    }

    private static List<SObject> getSalesPerformanceMasterKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> masterSObjList = getExistingMasterKPIRecords('Sales_Funnel__c', KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
        return getMasterRecordsToInsert(KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID, 'Sales Performance', 'Sales_Funnel__c', getMasterNameIdList(masterSObjList), fiscalYear, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
    }

    private static List<SObject> getFCICustomerSupportMasterKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> masterSObjList = getExistingMasterKPIRecords('FCI_Customer_Support__c', KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
        return getMasterRecordsToInsert(KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID, 'FC Support', 'FCI_Customer_Support__c', getMasterNameIdList(masterSObjList), fiscalYear, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
    }

    private static List<SObject> getBusinessStrategyMasterKPIRecords(String fiscalYear, Set<Id> distributorLocationIds){

        List<SObject> masterSObjList = getExistingMasterKPIRecords('Business_Strategy__c', KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
        return getMasterRecordsToInsert(KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID, 'Business Strategy', 'Business_Strategy__c', getMasterNameIdList(masterSObjList), fiscalYear, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
    }

    /*private static List<SObject> getHighLowCompetitionMasterKPIRecords(String fiscalYear,String period, Set<Id> distributorLocationIds){

        List<SObject> masterSObjList = getExistingMasterKPIRecords('Business_Strategy__c', KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
        return getMasterRecordsToInsert(KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID, 'Business Strategy', 'Business_Strategy__c', getMasterNameIdList(masterSObjList), fiscalYear, period, distributorLocationIds.isEmpty() ? getAllPartnerEnabledAccounts().keySet() : distributorLocationIds);
    }*/

    /* Creation of all master records ends here  */

    private static List<SObject> getMasterRecordsToInsert(Id RecordTypeId, String sObjLabelName, String sObjAPIName, List<String> nameIdList, String fiscalYear, Set<Id> distributorLocationIds){

        cusLocOwnerMap = getAllPartnerEnabledAccounts();
        List<SObject> masterRecords = new List<SObject>();
        for(Id eachCustLocId : distributorLocationIds){

            if(
                !nameIdList.isEmpty() &&
                (nameIdList.contains(getKPILabelName(sObjLabelName, fiscalYear) + eachCustLocId))
                ) {
                //|| nameIdList.contains(getKPILabelName(sObjLabelName, fiscalYear) + eachCustLocId)){

                continue;
            }

            masterRecords.add(createMasterRecord(RecordTypeId, fiscalYear, sObjAPIName, sObjLabelName, eachCustLocId, cusLocOwnerMap.get(eachCustLocId)));
        }

        return masterRecords;
    }

    private static List<SObject> getBucketRecordsToInsert(Id RecordTypeId, String sObjectAPIName, String LabelName, String fiscalYear, String period, String masterPrefixName, Map<String,Id> parentNameIdMap,List<String> existingBucketRecords, String parentLookupAPIName,String TypeAPIName,String TypeValue, Set<Id> distributorLocationIds){

        cusLocOwnerMap = getAllPartnerEnabledAccounts();
        List<SObject> bucketRecords = new List<SObject>();
        for(Id eachCustLocId : distributorLocationIds){

            if(!parentNameIdMap.isEmpty() && 
                /* (parentNameIdMap.containsKey(getKPILabelName(masterPrefixName, fiscalYear, period) + eachCustLocId) && !existingBucketRecords.contains(getKPILabelName(LabelName, fiscalYear, period) + eachCustLocId)) ||*/
                (parentNameIdMap.containsKey(getKPILabelName(masterPrefixName, fiscalYear) + eachCustLocId) 
                && (
                    !existingBucketRecords.contains(getKPILabelName(LabelName, fiscalYear) + eachCustLocId) &&
                    !existingBucketRecords.contains(getKPILabelName(LabelName, fiscalYear, period) + eachCustLocId)
                    ))
                ){

                bucketRecords.add(createBucketRecord(sObjectAPIName, LabelName, fiscalYear, period, RecordTypeId, 
                                /*!String.isBlank(parentNameIdMap.get(getKPILabelName(masterPrefixName, fiscalYear, period) + eachCustLocId)) ? parentNameIdMap.get(getKPILabelName(masterPrefixName, fiscalYear, period) + eachCustLocId) : parentNameIdMap.get(getKPILabelName(masterPrefixName, fiscalYear) + eachCustLocId),*/
                                parentNameIdMap.get(getKPILabelName(masterPrefixName, fiscalYear) + eachCustLocId), 
                                cusLocOwnerMap.get(eachCustLocId), parentLookupAPIName,
                                TypeAPIName, TypeValue));
            }
        }

        return bucketRecords;
    }

    public static List<SObject> getExistingMasterKPIRecords(String sObjectAPIName, Id masterRecordTypeId, Set<Id> customerLocationIds){

        String query = 'SELECT Id, Name, Distributor_Account__c';
        query += ' FROM ' + sObjectAPIName;
        query += ' WHERE Distributor_Account__c IN: customerLocationIds';
        query += ' AND RecordTypeId =: masterRecordTypeId';

        return (List<SObject>)Database.query(query);
    }

    public static List<SObject> getExistingBucketKPIRecords(String sObjectAPIName, Set<Id> recordTypeIds, Set<Id> customerLocationIds){

        String query = 'SELECT Id, Name, Distributor_Account_Name__c';
        query += ' FROM ' + sObjectAPIName;
        query += ' WHERE Distributor_Account_Name__c IN: customerLocationIds';
        query += ' AND RecordTypeId IN: recordTypeIds';

        return (List<SObject>)Database.query(query);
    }

    public static List<String> getMasterNameIdList(List<SObject> sObjList){

        List<String> nameIdList = new List<String>();
        for(SObject eachSObj : sObjList){

            nameIdList.add(String.valueOf(eachSObj.get('Name')) + String.valueOf(eachSObj.get('Distributor_Account__c')));
        }
        return nameIdList;
    }

    public static List<String> getBucketNameIdList(List<SObject> sObjList){

        
        List<String> nameIdList = new List<String>();
        for(SObject eachSObj : sObjList){

            nameIdList.add(String.valueOf(eachSObj.get('Name')) + String.valueOf(eachSObj.get('Distributor_Account_Name__c')));
        }
        return nameIdList;
    }

    private static SObject createMasterRecord(String recordTypeId, String fiscalYear, String sObjectAPIName, String LabelName, String customerLocationId, User commUser){

        SObject sObj = (SObject)(Type.forName('Schema.'+ sObjectAPIName).newInstance());
        sObj.put('Name', getKPILabelName(LabelName, fiscalYear) );
        sObj.put('Fiscal_Year_FY__c', fiscalYear);
        sObj.put('Period_Start_Date__c', Date.newInstance(Integer.valueOf(fiscalYear), 1, 1));
        sObj.put('Period_End_Date__c', Date.newInstance(Integer.valueOf(fiscalYear), 12, 31));
        sObj.put('RecordTypeId', recordTypeId);
        sObj.put('Distributor_Account__c', customerLocationId);
        sObj.put('OwnerId', commUser.Contact.Account.OwnerId);
        return sObj;
    }

    private static sObject createBucketRecord(String sObjectAPIName, String LabelName, String fiscalYear, String period, Id RecordTypeId, Id masterKPIId, User commUser, String parentKPILookupAPIName,String TypeAPIName,String TypeValue){

        SObject sObj = (SObject)(Type.forName('Schema.'+ sObjectAPIName).newInstance());
        sObj.put('Name', RecordTypeId.equals(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID) ? getKPILabelName(LabelName, fiscalYear) : getKPILabelName(LabelName, fiscalYear, period));
        sObj.put('Fiscal_Year_FY__c', fiscalYear);
        sObj.put('Period__c', RecordTypeId.equals(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID) ? NULL : period);
        sObj.put('Period_Start_Date__c', RecordTypeId.equals(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID) ? NULL : getHalfYearStartDates(fiscalYear).get(period));
        sObj.put('Period_End_Date__c', RecordTypeId.equals(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID) ? NULL : getHalfYearEndDates(fiscalYear).get(period));
        sObj.put(TypeAPIName,TypeValue);
        if(RecordTypeId.equals(KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID)){

            fillFYStartEndDates(sObj, fiscalYear);
        }
        sObj.put('RecordTypeId', recordTypeId);
        sObj.put(parentKPILookupAPIName, masterKPIId);
        sObj.put('Distributor__c',commUser.Contact.Parent_Account__r.Name);
        sObj.put('Distributor_Location__c', commUser.Contact.Account.Name);
        sObj.put('OwnerId', commUser.Contact.Account.OwnerId);
        sObj.put('Distributor_Account_Name__c', commUser.Contact.AccountId);
        sObj.put('Distributor_Parent_Account__c', commUser.Contact.Parent_Account__c);

        /* Added Score & Weight */
        sObj.put('Score__c', 0);
        sObj.put('Weight__c', getRecordTypeIdWeightMap().containsKey(RecordTypeId) ? getRecordTypeIdWeightMap().get(RecordTypeId) : 0);
        return sObj;
    }

    private static void fillFYStartEndDates(SObject sObj,String fiscalYear){

        sObj.put('FY_Start_Date__c', Date.newInstance(Integer.valueOf(fiscalYear), 1, 1));
        sObj.put('FY_End_Date__c', Date.newInstance(Integer.valueOf(fiscalYear), 12, 31));
    }

    private static String getKPILabelName(String LabelName, String fiscalYear){

        return LabelName + ' - ' + fiscalYear;
    }

    private static String getKPILabelName(String LabelName, String fiscalYear, String period){

        return LabelName + ' - ' + fiscalYear + ' - ' + period;
    }

    private static Map<String,Date> getHalfYearStartDates(String fiscalYear){

        if(halfYearStartDates == null){

            halfYearStartDates = new Map<String,Date>{'1st Half Year' => Date.newInstance(Integer.valueOf(fiscalYear), 1, 1),
                                                        '2nd Half Year' => Date.newInstance(Integer.valueOf(fiscalYear), 7, 1)};
        }

        return halfYearStartDates;
    }

    private static Map<String,Date> getHalfYearEndDates(String fiscalYear){

        if(halfYearEndDates == null){

            halfYearEndDates = new Map<String,Date>{'1st Half Year' => Date.newInstance(Integer.valueOf(fiscalYear), 6, 30),
                                                      '2nd Half Year' => Date.newInstance(Integer.valueOf(fiscalYear), 12, 31)};
        }

        return halfYearEndDates;
    }

    private static Map<Id,User> getAllPartnerEnabledAccounts(){

        if(cusLocOwnerMap == null || cusLocOwnerMap.isEmpty()){
            
            cusLocOwnerMap = new Map<Id,User>();
            for(User eachUser : UserUtility.getAllPartnerCommunityUsers()){

                /*if(eachUser.Contact.Work_Location__c != null){
                    cusLocOwnerMap.put(eachUser.Contact.Work_Location__c,eachUser);
                }*/

                if(eachUser.Contact.AccountId != null){
                    cusLocOwnerMap.put(eachUser.Contact.AccountId,eachUser);
                }
            }
        }
        
        return cusLocOwnerMap;
    }

    private static Map<Id,Decimal> getRecordTypeIdWeightMap(){

        if(recordTypeWeightMap == null){

            recordTypeWeightMap = new Map<Id,Decimal>{
                KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID  => 2,
                KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID      => 1,
                KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID              => 1,
                KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID          => 2,
                KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID           => 1,
                KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID       => 1,
                KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID      => 1,
                KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID                    => 1,
                KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID      => 1      
            };
        }

        return recordTypeWeightMap;
    }

    private static List<String> getHalfYears(){

        if(halfYears == NULL){

            halfYears = new List<String>{
                '1st Half Year',
                '2nd Half Year'
            };
        }
        
        return halfYears;
    }


}