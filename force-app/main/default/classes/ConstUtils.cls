/* *******************************************************************************************************
 * Name               : ConstUtils                                                                       *
 * Description        : SRM - Constants - static final Strings                                                 *
 * Created Date       : 06-07-2020                                                                       *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-07-2020 Initial version                                               *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class ConstUtils {
    
    /* Trigger Names */
    public static final String TRG_NAME_ASSESSMENT = 'AssessmentTrigger';
    public static final String TRG_NAME_ASSESSMENT_SCORING = 'AssessmentScoringTrigger';
    public static final String TRG_NAME_SUPPLIER_HUB = 'SupplierHubTrigger';
    public static final String TRG_NAME_SUPPLIER_RATING = 'SupplierRatingTrigger';
    public static final String TRG_NAME_VALUE_ELEMENT = 'ValueElementTrigger';
    public static final String TRG_NAME_SUPPLIER_LOCATION = 'SupplierLocationTrigger';
    public static final String TRG_NAME_SUPPLIER_TEAM = 'SupplierTeamTrigger';
    public static final String TRG_NAME_SUPPLIER_CONTRACT = 'SupplierContractTrigger';
    public static final String TRG_NAME_SRM_TASK = 'SRM_TaskTrigger';
    public static final String TRG_NAME_SUPPLIER_KPI = 'SupplierKpiTrigger';
    public static final String TRG_NAME_SRM_CONTENT_VERSION = 'SRM_ContentVersionTrigger';
    public static final String TRG_NAME_JOINT_BUSINESS_PLAN = 'JointBusinessPlanTrigger';
    public static final String TRG_NAME_SRM_USER_TRIGGER = 'SRM_UserTrigger';
    public static final String TRG_NAME_SUPPLIER_PROJECT = 'SupplierProjectTrigger';
    public static final String TRG_NAME_FEEDITEM = 'SRM_FeedItem';
    public static final String TRG_NAME_ASSESSMENT_SCORING_ITEM = 'SRM_AssessmentScorItmTrigger';


    /* Object Names */
    public static final String OBJ_NAME_SUPPLIER_RATING = 'Account';
    public static final String OBJ_NAME_ACCOUNT = 'Supplier_Rating__c';

    /* Picklist Values */

    /* obj Account -> * */
    public static final String ACCOUNT_RECORD_TYPE_NAME_SRM_ACCOUNT = 'SRM_Account';
    public static final String ACCOUNT_RECORD_TYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SRM_Account').getRecordTypeId();

    /* obj Assessment__c -> field Assessment_Type__c */
    public static final String ASSESSMENT_TYPE_SUPPLIER_RISK = 'Supplier Risk';
    public static final String ASSESSMENT_TYPE_HEALTH_CHECK_RELATIONSHIP_QUALITY = 'Health Check (Relationship Quality)';
    public static final String ASSESSMENT_TYPE_GET_WELL = 'Get Well';
    public static final String ASSESSMENT_TYPE_CUSTOM = 'Custom';
    public static final String ASSESSMENT_TYPE_JOINT_INITIATIVES = 'Joint Initiatives';
    public static final String ASSESSMENT_TYPE_PERFORMANCE_SLA = 'Performance (SLA)';
    public static final String ASSESSMENT_TYPE_SUPPLIER_AUDIT = 'Supplier Audit';
    public static final String ASSESSMENT_TYPE_SURVEY = 'Survey';

    /* obj Assessment__c -> field Dimensions__c */
    public static final String ASSESSMENT_DIMENSIONS_ONE_DIMENSIONAL = 'One-Dimensional';
    public static final String ASSESSMENT_DIMENSIONS_TWO_DIMENSIONAL = 'Two-Dimensional';
    public static final String ASSESSMENT_DIMENSIONS_THREE_DIMENSIONAL = 'Three-Dimensional';

    /* obj Assessment__c -> field Visibility__c */
    public static final String ASSESSMENT_VISIBILITY_INTERNAL = 'Internal';
    public static final String ASSESSMENT_VISIBILITY_EXTERNAL = 'External';
    public static final String ASSESSMENT_VISIBILITY_BOTH = 'Both';

    /* obj Assessment__c -> field Status__c */
    public static final String ASSESSMENT_STATUS_READY = 'Ready';
    public static final String ASSESSMENT_STATUS_IN_PROGRESS = 'In Progress';
    public static final String ASSESSMENT_STATUS_INACTIVE = 'Inactive';


    /* obj Assessment_Question__c -> field Dimension__c */
    public static final String ASSESSMENT_QUESTION_DIMENSION_X = 'X';
    public static final String ASSESSMENT_QUESTION_DIMENSION_Y = 'Y';
    public static final String ASSESSMENT_QUESTION_DIMENSION_Z = 'Z';

    /* obj Contact -> * */
    public static final String CONTACT_RECORD_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SRM_Contact').getRecordTypeId();

    /* obj Supplier_Hub__c -> field Segment__c */
    public static final String SUPPLIER_HUB_SEGMENT_STRATEGIC = 'Strategic';
    public static final String SUPPLIER_HUB_SEGMENT_KEY = 'Key';
    public static final String SUPPLIER_HUB_SEGMENT_MANAGED = 'Managed';
    public static final String SUPPLIER_HUB_SEGMENT_TRANSACTIONAL = 'Transactional';

    /* obj User -> field UserType */
    public static final String USER_USER_TYPE_STANDARD = 'Standard';

    /* obj Supplier_Team__c -> field Type__c */
    public static final String SUPPLIER_TEAM_TYPE_INTERNAL = 'Internal';
    public static final String SUPPLIER_TEAM_TYPE_EXTERNAL = 'External';

    /* obj Supplier_Team__c -> field Role__c */
    public static final String SUPPLIER_TEAM_ROLE_BUYER = 'Buyer';
    public static final String SUPPLIER_TEAM_ROLE_CONTRACT_MANAGER = 'Contract Manager';

    /* obj Supplier_Project__c -> field Type__c */
    public static final String SUPPLIER_PROJECT_TYPE_INTERNAL = 'Internal';
    public static final String SUPPLIER_PROJECT_TYPE_EXTERNAL = 'External';

    /* obj Task -> field Type */
    public static final String TASK_TYPE_CONTRACT_EXPIRY = 'Contract Expiry';
    public static final String TASK_TYPE_CLAUSE_CHECK = 'Clause Check';
    public static final String TASK_TYPE_ASSESSMENT = 'Assessment';

    /* obj Supplier_KPI__c -> field Source__c */
    public static final String SUPPLIER_KPI_SOURCE_SUPPLIER = 'Supplier';

    /* obj Joint_Business_Plan__c -> field Status__c */
    public static final String JOINT_BUSINESS_PLAN_STATUS_APPROVED = 'Approved';

    /* obj Assessment__c -> field Assessment_Scoring_Group_Status__c */
    public static final String ASSESSMENT_ASS_SCORING_GROUP_STATUS_SUBMITTED = 'Submitted';

    
    /* obj __Share -> field Share */
    public static final String SHARE_OBJECT_ACCESS_LEVEL_READ = 'Read';
    public static final String SHARE_OBJECT_ACCESS_LEVEL_EDIT = 'Edit';
    public static final String SHARE_OBJECT_ROW_CAUSE_MANUAL = 'Manual';

    /* Profile Names */
    public static final String PROFILE_NAME_SRM_CUSTOMER_COMMUNITY_PLUS = 'SRM Customer Community Plus User';
	public static final String PROFILE_NAME_SRM_PARTNER_COMMUNITY_LOGIN_USER = 'SRM Partner Community Login User';
    public static final String PROFILE_NAME_SRM_PARTNER_COMMUNITY_USER = 'SRM Partner Community User';


    //global describe
    public static final Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();




}