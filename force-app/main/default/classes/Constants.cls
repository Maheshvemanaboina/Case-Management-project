/**
 * Created by KJM on 02/04/2019.
 */
/**
* @UserStory		:	143693-Optimize the Current Approval Process in LSD SCAF object
* @Author   		:   LSD SCAF Expedition 2030 Dev Team
* @ModifiedDate 	:   21 May 2024
* @Desc 			:   Added constans LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE & LEGAL_SALES_PROCESS_INSTANCE_STATUS_Started
* */
  /*
		* Method Name				:	Constants
		* Description				:	Class to for all constants. 
	*/
public with sharing class Constants {
    
    public static final String COMMUNITY_ARTICLE_LINK = '/s/article/';
    public static final String COMMUNITY_TILE_LINK = '/s/tile/';
    public static final String COMMUNITY_OBJECT_LINK = '/s/detail/';
    public static final String COMMUNITY_CONTENTDOCUMENT_LINK = '/s/contentdocument/';
    public static final String TILE_LINKS_CUSTOM_SETTING_MAIN = 'Main SR Name';
    
    public static final String 	FCI_CUSTOMER_CONNECT = 'FCI Customer Community';
    public static final String 	FCI_DISTRIBUTOR_CONNECT = 'FCI Distributor Community';
    public static final String 	FC_EMPLOYEE_CONNECT = 'FC Employee Community';
    
    public static final String 	FCI_CUSTOMER_PROFILE_NAME = 'FCI Customer Community User';
    public static final String 	FCI_EMPLOYEE_PROFILE_NAME = 'FC Employee Community User';

    public static final String CSV_FILE_CODDING = 'UTF-8';
    public static final String CSV_ROW_SPLIT = '\r\n';

    public static final String ACCOUNT_API_NAME = 'Account';
    public static final String OPPORTUNITY_API_NAME = 'Opportunity';
    public static final String API_USER = 'API User';

    public static final String CSV_FILE_TYPE_LOCALE = 'locale';
    public static final String CSV_FILE_TYPE_NON_LOCALE = 'nonLocale';

    public static final String CSV_FIELD_SEPARATOR = ';';
    public static final String CSV_FIELD_DEFAULT_SEPARATOR = ';';
    public static final String CSV_FIELD_SEPARATOR_NON_LOCALE = ',';
    public static final String CSV_FIELD_SEPARATOR_NON_LOCALE_REPORT = '","';
    public static final String CSV_FIELD_SEPARATOR_LOCALE_REPORT = '";"';
    public static final String QUOTATION_MARK = '"';

    public static final String CSV_DECIMAL_SEPARATOR_FILE = '\\,';
    public static final String CSV_DECIMAL_SEPARATOR_SYSTEM = '\\.';

    public static final String CSV_DATE_SEPARATOR_FILE = '/';
    public static final String CSV_DATE_SEPARATOR_SYSTEM = '-';

    public static final String CSV_PICKLIST_SEPARATOR = ',';
    public static final String CSV_PICKLIST_DEFAULT_SEPARATOR = ',';
    public static final String CSV_PICKLIST_SEPARATOR_NON_LOCALE = ';';
    public static final String CSV_PICKLIST_SEPARATOR_SYSTEM = ';';

    public static final String CSV_VALUE_TRUE = 'true';
    public static final String CSV_VALUE_FALSE = 'false';

    public static final String RECORD_TYPE_ID_FIELD_NAME = 'RecordTypeId';
    public static final String OPPORTUNITY_ID_FIELD_NAME = 'OpportunityId';
    public static final String PRODUCT2_ID_FIELD_NAME = 'Product2Id';
    public static final String NAME_FIELD_NAME = 'Name';
    public static final String ID_FIELD_NAME = 'Id';
    public static final String END_CUSTOMER_FIELD_NAME = 'End_Customer__c';

    public static final String ERROR_UPLOAD_TYPE_DUPLICATE = 'VAL-DUPL';
    public static final String ERROR_UPLOAD_TYPE_MANDATORY = 'VAL-MAND';
    public static final String ERROR_UPLOAD_TYPE_VALUE = 'VAL-VAL';
    public static final String ERROR_UPLOAD_TYPE_UPSERT = 'DB-UPSERT';

    public static final String CSV_UPSERT_OPTION_INSERT = 'insertWithoutErr';
    public static final String CSV_UPSERT_OPTION_WITH_OVERWRITE = 'insertWithOverwrite';
    public static final String CSV_UPSERT_OPTION_ONLY_NEW = 'insertOnlyNew';

    public static final String ACCOUNT_TEAM_ROLE_SALES_MANAGER = 'Sales Manager';
    public static final String ACCOUNT_TEAM_ROLE_CMO = 'CMO';
    public static final String ACCOUNT_TEAM_ROLE_SALES_ASSISTANT = 'Sales Assistant';
    public static final String ACCOUNT_TEAM_ROLE_PERSON_RESPONSIBLE = 'Person Responsible';
    public static final String ACCOUNT_TEAM_ROLE_OFO = 'OFO';
    
    public static final String ACCOUNT_TEAM_HEADER_VALUE_BLANK = '';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_NAME = 'Name';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_TITLE = 'Title';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_TEAM_ROLE = 'Team Role';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_ABOUT_ME = 'About Me';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_ACTION = 'Action';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_EMAIL = 'Email';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_MOBILE = 'Mobile';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_WORK_LOCATION = 'Work Location';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_OUT_OF_OFFICE = 'In the Office';
    public static final String ACCOUNT_TEAM_HEADER_VALUE_BUSINESS_SEGMENT='Business Segment';

    public static final String CUSTOMER_TEAM_HEADER_VALUE_BLANK = '';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_NAME = 'Name';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_JOB_TITLE = 'Job Title';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_DEPARTMENT = 'Department';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_OPERATING_COMPANY = 'Operating Company';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_ACTION = 'Action';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_BUSINESS_SEGMENT = 'Business Segment';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_SUB_SEGMENT = 'Sub Segment';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_WORK_LOCATION = 'Work Location';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_EMAIL = 'Email';
    public static final String CUSTOMER_TEAM_HEADER_VALUE_MOBILE = 'Mobile';

    public static final String OBJECT_NAME_RECORD_TYPE = 'RecordType';
    public static final String OBJECT_NAME_OPPORTUNITY = 'Opportunity';
    public static final String OBJECT_NAME_CASE = 'Case';
    public static final String OBJECT_NAME_PRODUCT = 'Product2';
    public static final String OBJECT_NAME_ACCOUNT = 'Account';
    public static final String OBJECT_NAME_CONTACT = 'Contact';
    public static final String OBJECT_NAME_PRICEBOOK = 'Pricebook2';
    public static final String OBJECT_NAME_OPPORTUNITY_LINE_ITEM = 'OpportunityLineItem';
    public static final String OBJECT_NAME_USER = 'User';
    public static final String OBJECT_NAME_CONTRACT = 'Contract';

    public static final String OBJECT_UI_DISPLAY_NAME_PRODUCT = 'Product';

    public static final String ACCOUNT_RECORD_TYPE_END_CUSTOMER = 'End Customer';
    public static final String ACCOUNT_RECORD_TYPE_PROSPECT = 'Prospect';
    public static final String ACCOUNT_RECORD_TYPE_DEVELOPERNAME_AGENT = 'BGI_Agent';

    public static final String Opportunity_INSTRUCTION_DOCUMENT_DEVELOPER_NAME = 'InstructionOpportunityUpload';	
    public static final String ACCOUNT_INSTRUCTION_DOCUMENT_DEVELOPER_NAME = 'InstructionAccountsUpload';

    public static final String CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME = 'AccountUploadTemplateLocale';
    public static final String CSV_TEMPLATE_ACCOUNT_NON_LOCALE_DEVELOPER_NAME = 'AccountUploadTemplateNonLocaleXls';
    public static final String CSV_TEMPLATE_OPPORTUNITY_LOCALE_DEVELOPER_NAME = 'OpportunitiesUploadTemplateLocale';
    public static final String CSV_TEMPLATE_OPPORTUNITY_NON_LOCALE_DEVELOPER_NAME = 'OpportunitiesUploadTemplateNonLocaleXls';

    public static final String SALESFORCE_PICKLIST_SEPARATOR = ';';

    public static final String TILE_TYPE_PRODUCT_SPECIFICATION = 'Product Specification';
    public static final String TILE_TYPE_CERTIFICATE = 'Certificate';
    public static final String TILE_TYPE_PRODUCT = 'Product';
    public static final String TILE_TYPE_RECIPE = 'Recipe';

    public static final String TILE_FIELD_COMMUNITY_NAME = 'Community_Name__c';
    public static final String TILE_FIELD_BUSINESS_SEGMENT = 'Business_Segment__c';
    public static final String TILE_FIELD_SALES_REGION = 'Sales_Region__c';
    public static final String TILE_FIELD_SUB_SEGMENT = 'Sub_Segment__c';
    public static final String TILE_FIELD_APPLICATION = 'Application__c';
    public static final String TILE_FIELD_WORK_LOCATION = 'Work_Location__c';
    public static final String TILE_FIELD_COMMERCIAL_CUSTOMER = 'Parent_Account__c';

    public static final String TILE_CHILD_TYPE_LIST = 'List';
    public static final String TILE_CHILD_TYPE_NESTED = 'Nested';
    public static final String TILE_CHILD_TYPE_TILES = 'Tiles';

    public static final String TILE_SUB_QUERY_PREFIX = 'Tile__r.';
    public static final String RELATED_TILE_SUB_QUERY_PREFIX = 'Related_Tile__r.';

    public static final String TILE_ACCOUNT_CRITERIA_SHARE_WITH = 'Share with';
    public static final String TILE_ACCOUNT_CRITERIA_DO_NOT_SHARE_WITH = 'Do not share with';
    
    public static final String QUERY_AND = ' AND ';
    public static final String QUERY_OR = ' OR ';
    public static final String QUERY_IN = ' IN ';
    public static final String EMPTY_STRING = '';

    public static final String RELATED_TILE_TYPE_RECOMMENDED_PRODUCTS = 'Recommended Products';

    public static final String TEST_COMMUNITY_FAKE_NAME = 'FCI Distributor Community';
    public static final String TEST_COMMUNITY_FAKE_URL = 'https://'+DomainCreator.getExperienceCloudSitesHostname()+'/IngredientsMyCustomercommunity';

    public static final String DEFAULT_OPPORTUNITY_RECORD_TYPE_FROM_CSV_FILE ='Partner Opportunity';   //'FCI New Business Opportunity';Changed on 08/05/2020
    public static final String DEFAULT_ACCOUNT_RECORD_TYPE_FROM_CSV_FILE = 'End Customer';

    public static final String CSV_UPLOAD_FILE_CREATION_OPTION_TEMPLATE = 'csvFileTemplate';
    public static final String CSV_UPLOAD_FILE_CREATION_OPTION_REPORT = 'csvReportExport';

    public static final String COMMUNITY_USER_ROLE_STANDARD_USER = 'Standard User';
    public static final String COMMUNITY_USER_ROLE_MANAGER_USER = 'Manager User';

    public static final String TEST_FCI_DISTRIBUTOR_PROFILE = 'FCI Distributor Community User';
    public static final String TEST_FCI_CUSTOMER_PROFILE = 'FCI Customer Community User';
    public static final String TEST_DE_CUSTOMER_USER = 'DE Customer Community User';
    public static final String FCI_DISTRIBUTOR_PROFILE_LICENSE = 'Partner Community';
    public static final String FCI_CUSTOMER_PROFILE_LICENSE = 'Customer Community Plus';

    public static final String USER_COMMUNITY_ACCOUNT_ROLE_BUSINESS_SEGMENT = 'Business Segment Responsible User';
    public static final String USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT = 'Sub-Segment Responsible User';
    public static final String USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION = 'Application Responsible User';

    public static final String SHARE_ACCESS_LEVEL_READ = 'Read';
    public static final String SHARE_ACCESS_LEVEL_EDIT = 'Edit';
    public static final String SHARE_ACCESS_LEVEL_NONE = 'None';

    // public static final String ACCOUNT_MIRROR_SHARE_ROW_CAUSE_COMMERCIAL_CUSTOMER = 'Commercial_Customer__c';
    // public static final String ACCOUNT_MIRROR_SHARE_ROW_CAUSE_CUSTOMER_LOCATION = 'Customer_Location__c';
    // public static final String ACCOUNT_MIRROR_SHARE_ROW_CAUSE_BUSINESS_SEGMENT = 'Business_Segment__c';
    // public static final String ACCOUNT_MIRROR_SHARE_ROW_CAUSE_SUB_SEGMENT = 'Sub_Segment__c';
    // public static final String ACCOUNT_MIRROR_SHARE_ROW_CAUSE_APPLICATION = 'Application__c';
    // public static final String ACCOUNT_MIRROR_SHARE_ROW_CAUSE_END_CUSTOMER_LOCATION = 'End_Customer_Location__c';
    // public static final String ACCOUNT_MIRROR_SHARE_ROW_CAUSE_ADDITIONAL_COUNTRY_RESPONSIBILITY = 'Additional_Country_Responsibility__c';

    public static final String SHARE_ROW_CAUSE_MANUAL = 'Manual';
    public static final String SHARE_ROW_CAUSE_OWNER = 'Owner';

    public static final Id OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Current_Business').getRecordTypeId();
    public static final Id OPPORTUNITY_RECORD_TYPE_FCI_NEW_BUSINESS_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FCI New Business Opportunity').getRecordTypeId();
    public static final Id OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();//Added newly to use it in Opportunity related class instead of FCI record type for Comm Users.
    public static final Id ACCOUNT_RECORD_TYPE_COMMERCIAL_CUSTOMER_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId();
    public static final Id ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
    public static final Id ACCOUNT_RECORD_TYPE_PROSPECT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Prospect').getRecordTypeId();
    //public static final Id ACCOUNT_MIRROR_RECORD_TYPE_CUSTOMER_LOCATION_ID = Schema.SObjectType.Account_Mirror__c.getRecordTypeInfosByDeveloperName().get('Customer_Location').getRecordTypeId();
    public static final Id ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();
    //public static final Id ACCOUNT_MIRROR_RECORD_TYPE_END_CUSTOMER_ID = Schema.SObjectType.Account_Mirror__c.getRecordTypeInfosByDeveloperName().get('End_Customer').getRecordTypeId();
    public static final Id TILE_ORDER_AND_DELIVERY_RECORD_TYPE = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Order_And_Delivery').getRecordTypeId();
    public static final Id LEGAL_SALES_DEVIATION_RECORD_TYPE = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_With_Deviation').getRecordTypeId();
    public static final Id SCAF_DEVIATION_RECORD_TYPE = Schema.SObjectType.SCAF__c.getRecordTypeInfosByDeveloperName().get('Submission_of_approval_request_SCAF').getRecordTypeId();
    
    public static final Id VISIT_VBS_RECORD_TYPE_ID = Schema.SObjectType.Visit_Report__c.getRecordTypeInfosByDeveloperName().get('FCI_Visit_Report_VBS').getRecordTypeId();

    public static final String SEARCH_OBJECT_TYPE_FILE = 'File';
    public static final String SEARCH_OBJECT_TYPE_CONFIDENTIAL_CONTENT = 'Confidential Content';
    public static final String SEARCH_OBJECT_TYPE_ARTICLE = 'Article';

    public static final String TILE_CHILD_ORDER_OPTION_BY_NAME = 'By Name';
    public static final String TILE_CHILD_ORDER_OPTION_BY_ORDER_NUMBER = 'By Order Number';

    public static final String SEND_VISIT_NOTE_CUSTOMER_ATTENDEE_VALUE = 'Customer Attendees';
    public static final String SEND_VISIT_NOTE_RFC_ATTENDEE_VALUE = 'RFC Attendees';

    public static final Integer CONSTANT_VALUE_ZERO = 0;
    public static final String CONSTANT_VALUE_OPPORTUNITY_STAGE_MAPPING_ZERO_BY_ZERO = '0/0';
    public static final String TRIGGER_IS_INSERT_VALUE = 'isInsert';
    public static final String TRIGGER_IS_UPDATE_VALUE = 'isUpdate';

    public static final String LEGAL_SALES_GREATER_THAN_SIGN = '>';
    public static final String LEGAL_SALES_LESS_THAN_SIGN = '<';
    public static final String LEGAL_SALES_GREATER_THAN_EQUALTO_SIGN = '>=';
    public static final String LEGAL_SALES_LESS_THAN_EQUALTO_SIGN = '<=';
    public static final String LEGAL_SALES_COMPARISION_FIELDS = 'Total_Net_Sales_Value__c,Liability_Cap_Per_Year_EUR__c,Aggregate_Liability_Cap_Amount_EUR__c,Initial_Term_of_LSD_In_Months__c,Termination_Notice_Period_In_Months__c';
    
    public static final String LEGAL_SALES_COMPARISION_FIELDS_TEST = 'Total_Net_Sales_Value__c,Initial_Term_of_LSD_In_Months__c,Termination_Notice_Period_In_Months__c';

   	public static final String QUOTING_ORDERING_WITHOUT_LSD ='Approval_Duration_In_Months__c,Total_Net_Sales_Value__c';
    public static final String LEGAL_SALES_FCI_LEGAL_ENTITY_API_NAME = 'FC_Legal_Entity__c';
    public static final List<String> LEGAL_SALES_BUSINESS_SEGMENT_DEPENDENT = new List<String>{'FrieslandCampina Nederland B.V.', 'FrieslandCampina France SAS', 'FrieslandCampina Italy S.r.l.', 'FrieslandCampina Iberia SL', 'FrieslandCampina Belgium N.V.', 'FrieslandCampina DOMO B.V.'};
    public static final String LEGAL_SALES_STRING_SPLIT_CHAR = '//';
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUSES = 'Pending,Rejected,Approved';
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING = 'Pending';
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUS_REJECTED = 'Rejected';
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUS_APPROVED = 'Approved';
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUS_RECALLED = 'Removed';
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUS_REASSIGNED = 'Reassigned';
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE = 'Yet To Approve';//143693
    public static final String LEGAL_SALES_PROCESS_INSTANCE_STATUS_Started = 'Started';//143693
    public static final String LEGAL_SALES_LEADING_BUSINESS_SEGMENT_API_NAME = 'Leading_Business_Segment__c';
	public static final String QUOTING_ORDER_DELIVERY_STATUS ='Draft';
    public static final String ACCOUNT_CUSTOMER_LOCATION_SOLD_TO_VALUE = 'Sold-to';
    public static final String ACCOUNT_CUSTOMER_LOCATION_DIRECT_CUSTOMER_VALUE = 'Direct Customer';
    public static final String LEGAL_SALES_SCAF_APPROVAL_FIELD_API_NAMES = ' Approval_Legal__c, Approval_FD__c, Approval_MD__c, Approval_BG_FD__c, Approval_BG_President__c, Approval_Company_Secretory__c ';
    public static final String CHILD_LEAD_SUB_SEGMENT = 'Cell Nutrition';
}