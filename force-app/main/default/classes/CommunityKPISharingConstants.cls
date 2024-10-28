/*
    Author : Sibananda Bhuyan 12-04-2020
    Description : This class is used to store all the Constants required for Distributor KPI Sharing
*/

public without sharing class CommunityKPISharingConstants {

    /*
        Other Constants for KPI Sharing
    */

    public final static String COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE = 'Standard_User__c';
    public final static String COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE = 'Manager_User__c';

    /* Below are the Object API Names Used for Distributor KPIs */

    public final static String COMMERCIAL_ACTIVITY_OBJECT_API_NAME = 'Commercial_Activity__c';
    public final static String SALES_FUNNEL_OBJECT_API_NAME = 'Sales_Funnel__c';
    public final static String FORECAST_ACCURACY_OBJECT_API_NAME = 'Forecast_Accuracy__c' ;
    public final static String FCI_CUSTOMER_SUPPORT_OBJECT_API_NAME = 'FCI_Customer_Support__c';
    public final static String BUSINESS_STRATEGY_OBJECT_API_NAME = 'Business_Strategy__c';
    public final static String ACCOUNT_PLAN_API_NAME = 'Field_of_Play__c';
    public final static String RELATED_CUSTOMER_LOCATION_OBJECT_API_NAME = 'Other_Related_Customer_Location__c';
    
    /*
        Below are all the RecordTypes used for the Distributor Community KPIs. The RecordTypes are for below Objects:
        1. Commercial Activity
        2. Sales Funnel
        3. Forecast
        4. Business Strategy
        5. FCI Customer Support
    */

    /* Below are the RecordTypes used for Commercial Activity Object */

    public final static String COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Commercial_Activity_Master').getRecordTypeId();
    //public final static String COMMERCIAL_ACTIVITY_HIGH_LOW_LIGHT_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Commercial_Activity_High_Low_Lights').getRecordTypeId();
    public final static String COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Commercial_Activity_Promotion_Activities').getRecordTypeId();
    public final static String COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Commercial_Activity_Customer_Visits').getRecordTypeId();
    public final static String COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Commercial_Activity_Samples').getRecordTypeId();
    //public final static String COMMERCIAL_ACTIVITY_COMPETITION_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Commercial_Activity_Competition').getRecordTypeId();
    public final static String PROMOTION_ACTIVITY_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Promotion_Activity').getRecordTypeId();
    public final static String CUSTOMER_VISIT_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Customer_Visit').getRecordTypeId();
    public final static String SAMPLE_RECORD_TYPE_ID = Schema.SObjectType.Commercial_Activity__c.getRecordTypeInfosByDeveloperName().get('Samples').getRecordTypeId();

    /* Below are the RecordTypes used for Sales Funnel Object */

    public final static String SALES_FUNNEL_MASTER_RECORD_TYPE_ID = Schema.SObjectType.Sales_Funnel__c.getRecordTypeInfosByDeveloperName().get('Sales_Funnel_Master').getRecordTypeId();
    public final static String SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID = Schema.SObjectType.Sales_Funnel__c.getRecordTypeInfosByDeveloperName().get('Sales_Funnel_Distributor_Sales_To_End_Customer').getRecordTypeId();
    public final static String DISTI_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID = Schema.SObjectType.Sales_Funnel__c.getRecordTypeInfosByDeveloperName().get('Distributor_Sales_To_End_Customer').getRecordTypeId();

    /* Below are the RecordTypes used for Forecast Object */

    public final static String FORECAST_MASTER_RECORD_TYPE_ID = Schema.SObjectType.Forecast_Accuracy__c.getRecordTypeInfosByDeveloperName().get('Forecast_Master').getRecordTypeId();
    public final static String FORECAST_LOCAL_STOCK_RECORD_TYPE_ID = Schema.SObjectType.Forecast_Accuracy__c.getRecordTypeInfosByDeveloperName().get('Forecast_Accuracy_Local_Stock').getRecordTypeId();
    public final static String LOCAL_STOCK_RECORD_TYPE_ID = Schema.SObjectType.Forecast_Accuracy__c.getRecordTypeInfosByDeveloperName().get('Local_Stock').getRecordTypeId();

    /* Below are the RecordTypes used for Business Strategy Object */

    public final static String BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Business_Strategy_Master').getRecordTypeId();
    public final static String HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('High_Low_Lights_Competition_Master').getRecordTypeId();
    public final static String BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Business_Strategy_Account_Plan').getRecordTypeId();
    public final static String BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Business_Strategy_High_Low_Lights').getRecordTypeId();
    public final static String BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Business_Strategy_Competition').getRecordTypeId();
    public final static String HIGH_LOW_LIGHT_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('High_Low_Lights').getRecordTypeId();
    public final static String COMPETITION_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Competition').getRecordTypeId();

    /* This one RecordType is used to store the competitions for Account Plan */
    public final static String COMPETITION_ACCOUNT_PLAN_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Competition_Account_Plan').getRecordTypeId();

    /* Below are the RecordTypes used for FCI Customer Support Object */

    public final static String FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID = Schema.SObjectType.FCI_Customer_Support__c.getRecordTypeInfosByDeveloperName().get('FCI_Customer_Support_Master').getRecordTypeId();
    public final static String FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID = Schema.SObjectType.FCI_Customer_Support__c.getRecordTypeInfosByDeveloperName().get('FCI_Customer_Support_Order_Process').getRecordTypeId();
    public final static String FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID = Schema.SObjectType.FCI_Customer_Support__c.getRecordTypeInfosByDeveloperName().get('FCI_Customer_Support_Complaints').getRecordTypeId();
    public final static String ORDER_PROCESS_RECORD_TYPE_ID = Schema.SObjectType.FCI_Customer_Support__c.getRecordTypeInfosByDeveloperName().get('Order_Process').getRecordTypeId();

    /* Below are the RecordTypes used for Account plan Object */

    public final static String DISTRIBUTOR_ACCOUNT_PLAN = Schema.SObjectType.Field_of_Play__c.getRecordTypeInfosByDeveloperName().get('Distributor_Account_Plan').getRecordTypeId();
    public final static String DISTRIBUTOR_SHARED_ACCOUNT_PLAN = Schema.SObjectType.Field_of_Play__c.getRecordTypeInfosByDeveloperName().get('Shared_Account_Plan').getRecordTypeId();

    /* Below are the RecordTypes used for Other Related Customer Location Object */

    public final static String DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID = Schema.SObjectType.Other_Related_Customer_Location__c.getRecordTypeInfosByDeveloperName().get('Distributor_Related_Customer_Locations').getRecordTypeId();

    /* The below Constants are for all the parent objects of KPI which will be used as buckets to store all KPIs 
        The H1 constants are used to share with Manager users
        The H5 Constatns are used to share with Standard Users
    */

    /*
        The constants below are for :
        1. Commercial Activity
        2. Sales Funnel
        3. Forecast
        4. Business Strategy
        5. FCI Customer Support
    */

    public final static String PARENT_COMMERCIAL_ACTIVITY_RELATION = 'Parent_Commercial_Activity__c';
    public final static String COMMERCIAL_ACTIVITY_H1_RELATION = 'Parent_Commercial_Activity__r.Distributor_Account__r.ParentId';
    public final static String COMMERCIAL_ACTIVITY_H5_RELATION = 'Parent_Commercial_Activity__r.Distributor_Account__c';

    public final static String PARENT_SALES_FUNNEL_RELATION = 'Parent_Sales_Funnel__c';
    public final static String SALES_FUNNEL_H1_RELATION = 'Parent_Sales_Funnel__r.Distributor_Account__r.ParentId';
    public final static String SALES_FUNNEL_H5_RELATION = 'Parent_Sales_Funnel__r.Distributor_Account__c';

    public final static String PARENT_FORECAST_ACCURACY_RELATION = 'Parent_Forecast__c';
    public final static String FORECAST_ACCURACY_H1_RELATION = 'Parent_Forecast__r.Distributor_Account__r.ParentId';
    public final static String FORECAST_ACCURACY_H5_RELATION = 'Parent_Forecast__r.Distributor_Account__c';

    public final static String PARENT_BUSINESS_STRATEGY_RELATION = 'Parent_Business_Strategy__c';
    public final static String BUSINESS_STRATEGY_H1_RELATION = 'Parent_Business_Strategy__r.Distributor_Account__r.ParentId';
    public final static String BUSINESS_STRATEGY_H5_RELATION = 'Parent_Business_Strategy__r.Distributor_Account__c';
    
    public final static String PARENT_FCI_CUSTOMER_SUPPORT_RELATION = 'Parent_FCI_Customer_Support__c';
    public final static String FCI_CUSTOMER_SUPPORT_H1_RELATION = 'Parent_FCI_Customer_Support__r.Distributor_Account__r.ParentId';
    public final static String FCI_CUSTOMER_SUPPORT_H5_RELATION = 'Parent_FCI_Customer_Support__r.Distributor_Account__c';

    /* The below Constants are for all the Child objects where the KPIs will be inserted 
        The H1 constants are used to share with Manager users
        The H5 Constants are used to share with Standard Users*/

    /* The values below belongs to the child objects to Commercial Activities 
        1. Promotion Activities
        2. Customer Visits
        3. Samples
    */
    
    public final static String PROMOTION_ACTIVITY_H1_RELATION = 'Commercial_Activity_Promotion_Activity__r.Parent_Commercial_Activity__r.Distributor_Account__r.ParentId';
    public final static String PROMOTION_ACTIVITY_H5_RELATION = 'Commercial_Activity_Promotion_Activity__r.Parent_Commercial_Activity__r.Distributor_Account__c';

    public final static String CUSTOMER_VISIT_H1_RELATION = 'Commercial_Activity_Customer_Visit__r.Parent_Commercial_Activity__r.Distributor_Account__r.ParentId';
    public final static String CUSTOMER_VISIT_H5_RELATION = 'Commercial_Activity_Customer_Visit__r.Parent_Commercial_Activity__r.Distributor_Account__c';

    public final static String SAMPLE_H1_RELATION = 'Commercial_Activity_Sample__r.Parent_Commercial_Activity__r.Distributor_Account__r.ParentId';
    public final static String SAMPLE_H5_RELATION = 'Commercial_Activity_Sample__r.Parent_Commercial_Activity__r.Distributor_Account__c';

    /* The values below belongs to the child objects to FCI Customer Support
        1. Order Process
        2. Case ( Complaints )
    */

    public final static String ORDER_PROCESS_H1_RELATION = 'FCI_Customer_Support_Order_Process__r.Parent_FCI_Customer_Support__r.Distributor_Account__r.ParentId';
    public final static String ORDER_PROCESS_H5_RELATION = 'FCI_Customer_Support_Order_Process__r.Parent_FCI_Customer_Support__r.Distributor_Account__c';

    /* The values below belongs to the child objects to Forecast
        1. LocalStock
    */

    public final static String LOCAL_STOCK_H1_RELATION = 'Forecast_Accuracy_Local_Stock__r.Parent_Forecast__r.Distributor_Account__r.ParentId';
    public final static String LOCAL_STOCK_H5_RELATION = 'Forecast_Accuracy_Local_Stock__r.Parent_Forecast__r.Distributor_Account__c';

    /* The values below belongs to the child objects to Sales Funnel
        1. Distributor Sales-To-End Customer
    */

    public final static String DISTI_SALES_TO_END_CUSTOMER_H1_RELATION = 'Sales_Funnel_Sales_To_End_Customer__r.Parent_Sales_Funnel__r.Distributor_Account__r.ParentId';
    public final static String DISTI_SALES_TO_END_CUSTOMER_H5_RELATION = 'Sales_Funnel_Sales_To_End_Customer__r.Parent_Sales_Funnel__r.Distributor_Account__c';

    /* The values below belongs to the child objects to Business Strategy
        1. Account Plan (Field Of Play)
        2. High & Low Lights
        3. Compettions
    */

    public final static String ACCOUNT_PLAN_BUSINESS_STRATEGY_RELATION = 'Distributor_Business_Strategy__c';
    public final static String OTHER_RELATED_LOCATION_BUSINESS_STRATEGY_RELATION = 'Distributor_Business_Strategy__c';
    public final static String ACCOUNT_PLAN_PARENT_BUSINESS_STRATEGY_RELATION = 'Distributor_Business_Strategy__r.Parent_Business_Strategy__c';
    public final static String ACCOUNT_PLAN_H5_RELATION = 'Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__c';
    public final static String ACCOUNT_PLAN_H1_RELATION = 'Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__r.ParentId';
    public final static String SHARED_ACCOUNT_PLAN_H5_RELATION = 'Shared_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__c';
    public final static String SHARED_ACCOUNT_PLAN_H1_RELATION = 'Shared_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__r.ParentId';
    
    public final static String HIGH_LOW_LIGHT_H1_RELATION = 'Business_Strategy_High_Low_Lights__r.Parent_Business_Strategy__r.Distributor_Account__r.ParentId';
    public final static String HIGH_LOW_LIGHT_H5_RELATION = 'Business_Strategy_High_Low_Lights__r.Parent_Business_Strategy__r.Distributor_Account__c';
    
    public final static String COMPETITION_H1_RELATION = 'Business_Strategy_Competition__r.Parent_Business_Strategy__r.Distributor_Account__r.ParentId';
    public final static String COMPETITION_H5_RELATION = 'Business_Strategy_Competition__r.Parent_Business_Strategy__r.Distributor_Account__c';

    /* The values below belongs to the child objects to Account Plan
        1. Other Related Customer Locations
    */
    public final static String OTHER_RELATED_CUSTOMER_H1_RELATION = 'Account_Plan__r.Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__r.ParentId';
    public final static String OTHER_RELATED_CUSTOMER_H5_RELATION = 'Account_Plan__r.Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__c';
    public final static String OTHER_RELATED_DISTRIBUTOR_FIELD_H1_LOCATION = 'Distributor_Location__r.ParentId';
    public final static String OTHER_RELATED_DISTRIBUTOR_FIELD_H5_LOCATION = 'Distributor_Location__c';

}