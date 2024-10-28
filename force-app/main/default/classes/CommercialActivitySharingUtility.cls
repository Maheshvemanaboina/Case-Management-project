/*       
@Name           - CommercialActivitySharingUtility
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 12-04-2020
@UsedBy         - 1. CommercialActivityTriggerHandler
                  2. CommercialActivitySharingBatch
                  3. RelatedCustomerLocationSharingUtility
                  4. UserSharingUtility

@Description    - This class will share all KPIs related to Commercial Activity Object

UserId              | Author-Email                  | Date                  | Comment
====================|===============================|=======================|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 18-05-2020    | Remove High & Low Lights, Competition. To be moved to Business Strategy
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 04-02-2021    | Updated class to according to new Account restructure & moving logic from shared Class to its own class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 22-09-2021    | Updated class to accomodate new KPI structure and new arrangement for related distributor locations
*/
public without sharing class CommercialActivitySharingUtility {

    /* @Description
        Method Name : shareAllCommercialActivitiesAndKPIsWithCommunityUsers( List<Commercial_Activity__c> )

        This method will share Commercial Activities and All related KPIs for Commercial Activity
        Related KPIs are:
        1. Promotion Activities
        2. Customer Visits
        3. Samples
        
        @PARAMS
            1. NAME ( newCommercialActivities ) => TYPE ( List<Commercial_Activity__c> ) => DESCRIPTION ( All new Commercial Activity coming from Trigger.New when Commercial Activities are created )
    */
    public static void  shareAllCommercialActivitiesAndKPIsWithCommunityUsers( List<Commercial_Activity__c> newCommercialActivities ){
        
        List<Commercial_Activity__c> comActivityToRecalculate = new List<Commercial_Activity__c>(); // Valid Commercial Activity records to consider to sharing
        
        for ( Commercial_Activity__c comActivity : newCommercialActivities ) {
            
            /* Checks if the Commercial Activity is valid to be shared */
            if ( isRecalculationRequiredToShare( comActivity ) ) {
                comActivityToRecalculate.add( comActivity );
            } 
        }
        
        /* if not Empty, then initiate sharing */
        if( !comActivityToRecalculate.isEmpty() ){
            initiateComActivitySharing( UserUtility.getAllPartnerCommunityUsers(), comActivityToRecalculate );
        }
        
    }
    
    /* @Description
        Method Name : initiateComActivitySharing( List<User> , List<Commercial_Activity__c> )

        This method will separate the Ids to call the future or non - future methods based on the caller function
            1. If it is called from Trigger then future method "createSharingForComActivityFuture" is called
            2. If it is called from Batch, then no future is called and direct "createSharingForComActivity" is called.
        
        @PARAMS
            1. NAME ( userList )        => TYPE ( List<User> )                      => DESCRIPTION ( All Partner community users )
            2. NAME ( comActivityList ) => TYPE ( List<Commercial_Activity__c> )    => DESCRIPTION ( All commercial activity records considered for re-calculation )
    */

    public static void initiateComActivitySharing( List<User> userList, List<Commercial_Activity__c> comActivityList ){
        
        Set<Id> usersIds = new Set<Id>();
        for ( User usr : userList ) {
            usersIds.add( usr.Id );
        }
        
        Set<Id> comActivityIds = new Set<Id>();
        Set<Id> masterComActivityIds = new Set<Id>();

        for ( Commercial_Activity__c comActivity : DAOUtilityWithoutShar.getComActivityForSharing( (new Map<Id, Commercial_Activity__c>( comActivityList )).keySet() ) ) {
            comActivityIds.add( comActivity.Id );

            /* Added for Related Customer Location Sharing */
            //comActivityBucketIds.add( comActivity.Id );
            masterComActivityIds.add( comActivity.Parent_Commercial_Activity__c );
            masterComActivityIds.add( comActivity.Commercial_Activity_Customer_Visit__r?.Parent_Commercial_Activity__c );
            masterComActivityIds.add( comActivity.Commercial_Activity_Promotion_Activity__r?.Parent_Commercial_Activity__c );
            masterComActivityIds.add( comActivity.Commercial_Activity_Sample__r?.Parent_Commercial_Activity__c );
        }
        
        masterComActivityIds.remove( null );

        if( System.isBatch() ){

            createSharingForComActivity( usersIds, comActivityIds, masterComActivityIds );
        }else{
            
            createSharingForComActivityFuture( usersIds, comActivityIds, masterComActivityIds );
        }
    }

    /* @Description
        Method Name : createSharingForComActivityFuture( Set<Id> , Set<Id> , Set<Id> )

        1. future method to call non-future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )                => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( comActivityIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All commercial activity records Ids )
            3. NAME ( masterComActivityIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All commercial activity master Bucket records Ids )
    */

    @future
    public static void createSharingForComActivityFuture( Set<Id> usersIds, Set<Id> comActivityIds, Set<Id> masterComActivityIds ) {
        createSharingForComActivity( usersIds, comActivityIds, masterComActivityIds );
    }
    
    /* @Description
        Method Name : createSharingForComActivity( Set<Id> , Set<Id> , Set<Id> )

        1. non - future method called from future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )                => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( comActivityIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All commercial activity records Ids )
            3. NAME ( masterComActivityIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All commercial activity master Bucket records Ids )
    */

    public static void createSharingForComActivity( Set<Id> usersIds, Set<Id> comActivityIds, Set<Id> masterComActivityIds ) {
        
        //Query all Users from the userIds
        List<User> users = [SELECT Id, UserName, Contact.Name, Contact.Account.Name, Contact.Additional_Country_Responsibility__c, Contact.Business_Segment__c, Contact.Sub_Segment__c, Contact.Exclude_Customer_Location_Country__c, Community_Account_Role__c, Contact.Parent_Account__c, Contact.Account.BillingCountry, Contact.AccountId, Community_User_Role__c, IsPortalEnabled FROM User WHERE Id IN :usersIds];
        
        //Query all CommercialActivity from the comActivityIds
        List<Commercial_Activity__c> comActivityList = DAOUtilityWithoutShar.getComActivityForSharing( comActivityIds );

        //Query all Other Related Customer Location records to share Commercial Activities with them
        List<Other_Related_Customer_Location__c> relatedCustList = DAOUtilityWithoutShar.getRelatedCustomerLocationForCommercialActivity( masterComActivityIds );
        
        //Map of <Commercial Activity Master Bucket,List<Related Customer Loc>>
        Map<Id,List<Id>> commercialActivityDistributorLocsMap = getCommercialActivityDistributorLocsMap( relatedCustList );
        
        //Map of UserIds with Additional Customer Locations added at contact Level - ENH-4815
        Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(users);

        List<Commercial_Activity__Share> comActivityShares = new List<Commercial_Activity__Share>(); // commercialActivity share list to insert

        for ( Commercial_Activity__c comActivity : comActivityList ) {
            
            for ( User currUser : users ) {        
                
                //Skip sharing if user already owns the Commercial Activity.
                if ( comActivity.OwnerId.equals( currUser.Id ) ) {
                    continue;
                }
                
                Commercial_Activity__Share comActivityShare;
                
                /* Checks if current user is standard user and initiates sharing for it or else initiate sharing for Manager user */
                if ( UserUtility.isUserStandardCommunityUser( currUser ) ) {
                    comActivityShare = createSharingForStandardUser( currUser, comActivity, commercialActivityDistributorLocsMap, usersWithAddCustLocsMap );
                } else {
                    comActivityShare = createSharingForManagerUser( currUser, comActivity );
                }
                
                if ( comActivityShare == null ) {
                    continue;
                }
                
                if( !comActivityShares.contains( comActivityShare ) ){
                    comActivityShares.add( comActivityShare );
                }   
            }
        }

        DAOUtilityWithoutShar.insertWithoutAccess( comActivityShares );
    }
    
    /* @Description
        Method Name : createSharingForStandardUser( User , Commercial_Activity__c , Map<Id,List<Id>> )

        1. non - future method called from future to start sharing
        2. This is for standard community user
        
        @PARAMS
            1. NAME ( currUser )                                => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( comActivity )                             => TYPE ( Commercial_Activity__c )  => DESCRIPTION ( Current Commercial Activity record from loop )
            3. NAME ( commercialActivityDistributorLocsMap )    => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each Commercial Activity record can be shared with multiple distributors, this is the map to store that )
    */

    private static Commercial_Activity__Share createSharingForStandardUser(
        User currUser,
        Commercial_Activity__c comActivity,
        Map<Id,List<Id>> commercialActivityDistributorLocsMap,
        Map<Id, Set<Id>> usersWithAddCustLocsMap
        ){
            
            /* This part does the check for Commercial Activity Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only , included record types: 
                    a. KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID
                    b. KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID
                    c. KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID

                2. If created by distributor then it is Read/Write, included Record Types:
                    a. KPIConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID
                    a. KPIConstants.CUSTOMER_VISIT_RECORD_TYPE_ID
                    a. KPIConstants.SAMPLE_RECORD_TYPE_ID
            */
            
            if( isEligibleForStandardUserComActivitySharing( currUser, comActivity, commercialActivityDistributorLocsMap, usersWithAddCustLocsMap ) ){
                
                return createComActivityShareRecord(

                    currUser.Id, 
                    comActivity.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE,
                    isCommercialActivityAccessLevelREAD(comActivity) ? 'READ' : 'EDIT'
                );
            }
            
            return null;
        }

    /* @Description
        Method Name : createSharingForManagerUser( User , Commercial_Activity__c )

        1. non - future method called from future to start sharing
        2. This is for Manager user
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( comActivity ) => TYPE ( Commercial_Activity__c )  => DESCRIPTION ( Current Commercial Activity record from loop )
    */

    private static Commercial_Activity__Share createSharingForManagerUser(
        User currUser,
        Commercial_Activity__c comActivity
        ){

            /* This part does the check for Commercial Activity Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only , included record types: 
                    a. KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID
                    b. KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID
                    c. KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID

                2. If created by distributor then it is Read/Write, included Record Types:
                    a. KPIConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID
                    a. KPIConstants.CUSTOMER_VISIT_RECORD_TYPE_ID
                    a. KPIConstants.SAMPLE_RECORD_TYPE_ID
            */

            if( isEligibleForManagerUserComActivitySharing( currUser, comActivity ) ){

                return createComActivityShareRecord(

                    currUser.Id, 
                    comActivity.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE,
                    isCommercialActivityAccessLevelREAD( comActivity ) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    /* @Description
        Method Name : isCommercialActivityAccessLevelREAD( Commercial_Activity__c )

        1. Share the bucket records with Read Only access to Community users or else it will be EDIT access
        
        @PARAMS
            1. NAME ( comActivity ) => TYPE ( Commercial_Activity__c )  => DESCRIPTION ( Current Commercial Activity record from loop )
    */

    private static Boolean isCommercialActivityAccessLevelREAD(Commercial_Activity__c comActivity){

        return comActivity.RecordTypeId.equals(KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID) || 
            comActivity.RecordTypeId.equals(KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID) ||
            comActivity.RecordTypeId.equals(KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID);
    }
    
    /* @Description
        Method Name : isEligibleForStandardUserComActivitySharing( User , Commercial_Activity__c , Map<Id,List<Id>> )

        This checks whether a commercial activity record is eligible to be shared with standard user & does the following things:
            1. Checks if a Commercial Activity KPI record's distributor location = Contact's H5
            2. Checks if a Commercial Activity KPI record's distributor location's country = one of the contact's additional Countries
            3. Checks if a Commercial Activity KPI record's Related Customer location's distributor location = Contact's H5
        
        @PARAMS
            1. NAME ( currUser )                                    => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( comActivity )                                 => TYPE ( Commercial_Activity__c )  => DESCRIPTION ( Current Commercial Activity record from loop )
            3. NAME ( masterCommercialActivityDistributorLocsMap )  => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each Commercial Activity record can be shared with multiple distributors, this is the map to store that )
    */

    private static Boolean isEligibleForStandardUserComActivitySharing(User stdUser,  Commercial_Activity__c comActivity, Map<Id,List<Id>> masterCommercialActivityDistributorLocsMap, Map<Id, Set<Id>> usersWithAddCustLocsMap){
        
        return stdUser.Contact.AccountId != null &&
            stdUser.Contact.Parent_Account__c != null &&
            (  
                /* Account Match Sharing for Master */
                (
                    !String.isBlank( comActivity.Distributor_Account__c ) &&
                    ( 
                        /* Account Match Sharing for Master Bucket */
                        comActivity.Distributor_Account__c.equals( stdUser.Contact.AccountId ) 
                        ||
                        /* Account Match Sharing for Master Bucket for related distributor locations */
                        ( 
                            masterCommercialActivityDistributorLocsMap.containsKey( comActivity.Id ) && 
                            masterCommercialActivityDistributorLocsMap.get( comActivity.Id ).contains( stdUser.Contact.AccountId )
                        )
                        ||
                        /* Account Match Sharing for Master Bucket for additional customer locations */
                        (
                        	usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null &&
                            usersWithAddCustLocsMap.get(stdUser.Id).contains(comActivity.Distributor_Account__c)
                        )
                    )
                )
                ||
                /* Account Match Sharing for all buckets except Master */
                (
                    comActivity.Distributor_Account_Name__c != null &&
                    comActivity.Distributor_Parent_Account__c != null &&
                    String.isBlank( comActivity.Distributor_Account__c ) &&
                    stdUser.Contact.Parent_Account__c.equals( comActivity.Distributor_Parent_Account__c ) &&
                    (
                        stdUser.Contact.AccountId.equals( comActivity.Distributor_Account_Name__c ) || 
                        /* Additional Country Responsibility Sharing */
                        (
                            stdUser.Contact.Additional_Country_Responsibility__c != null &&
                            comActivity.Distributor_Account_Name__r.BillingCountry != null &&
                            stdUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase( comActivity.Distributor_Account_Name__r.BillingCountry )
                        ) ||

                        /* Related Customer Location Sharing */
                        (    
                            //if current Commercial Activity Record is Bucket Record
                            (
                                masterCommercialActivityDistributorLocsMap.containsKey( comActivity.Parent_Commercial_Activity__c ) && 
                                masterCommercialActivityDistributorLocsMap.get( comActivity.Parent_Commercial_Activity__c ).contains( stdUser.Contact.AccountId ) 
                            ) ||

                            //if current Commercial Activity Record is Promotion Activity Record
                            (   
                                !String.isBlank( comActivity.Commercial_Activity_Promotion_Activity__c ) &&
                                masterCommercialActivityDistributorLocsMap.containsKey( comActivity.Commercial_Activity_Promotion_Activity__r.Parent_Commercial_Activity__c ) &&
                                masterCommercialActivityDistributorLocsMap.get( comActivity.Commercial_Activity_Promotion_Activity__r.Parent_Commercial_Activity__c ).contains( stdUser.Contact.AccountId ) 
                            ) ||

                            //if current Commercial Activity Record is Customer Visit Record
                            (
                                !String.isBlank( comActivity.Commercial_Activity_Customer_Visit__c ) &&
                                masterCommercialActivityDistributorLocsMap.containsKey( comActivity.Commercial_Activity_Customer_Visit__r.Parent_Commercial_Activity__c ) && 
                                masterCommercialActivityDistributorLocsMap.get( comActivity.Commercial_Activity_Customer_Visit__r.Parent_Commercial_Activity__c ).contains( stdUser.Contact.AccountId ) 
                            ) ||

                            //if current Commercial Activity Record is Samples Record
                            (
                                !String.isBlank( comActivity.Commercial_Activity_Sample__c ) &&
                                masterCommercialActivityDistributorLocsMap.containsKey( comActivity.Commercial_Activity_Sample__r.Parent_Commercial_Activity__c ) && 
                                masterCommercialActivityDistributorLocsMap.get( comActivity.Commercial_Activity_Sample__r.Parent_Commercial_Activity__c ).contains( stdUser.Contact.AccountId ) 
                            ) 
                        ) ||
                        
                        /* Additional Customer Location Sharing */
                        (   
                            (usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null) &&
                            //if current Commercial Activity Record is Bucket Record
                            ((
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(comActivity.Distributor_Account_Name__c)
                            ) ||

                            //if current Commercial Activity Record is Promotion Activity Record
                            (
                                !String.isBlank( comActivity.Commercial_Activity_Promotion_Activity__c ) &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(comActivity.Commercial_Activity_Promotion_Activity__r.Distributor_Account_Name__c)
                            ) ||

                            //if current Commercial Activity Record is Customer Visit Record
                            (
                                !String.isBlank( comActivity.Commercial_Activity_Customer_Visit__c ) &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(comActivity.Commercial_Activity_Customer_Visit__r.Distributor_Account_Name__c)
                            ) ||
                            
                            //if current Commercial Activity Record is Samples Record
                            (
                                !String.isBlank( comActivity.Commercial_Activity_Sample__c ) &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(comActivity.Commercial_Activity_Sample__r.Distributor_Account_Name__c)
                            ))
                        )
                    )
                )
            );
    }
    
    /* @Description
        Method Name : isEligibleForManagerUserComActivitySharing( User , Commercial_Activity__c )

        This checks whether a commercial activity record is eligible to be shared with Manager user & does the following things:
            1. Checks if a Commercial Activity KPI record's distributor location = Contact's H5
            2. Checks if a Commercial Activity KPI record's distributor location's H1 = Contact's H1
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )                    => DESCRIPTION ( Current Manager community user from loop )
            2. NAME ( comActivity ) => TYPE ( Commercial_Activity__c )  => DESCRIPTION ( Current Commercial Activity record from loop )
    */

    private static Boolean isEligibleForManagerUserComActivitySharing( User mngUser,  Commercial_Activity__c comActivity ){

        return mngUser.Contact.AccountId != null &&
            mngUser.Contact.Parent_Account__c != null &&
            
            (
                /* Account Match Sharing for Master bucket */
                (
                    !String.isBlank( comActivity.Distributor_Account__c ) &&
                    (
                        comActivity.Distributor_Account__c.equals( mngUser.Contact.AccountId ) ||
                        comActivity.Distributor_Account__r.ParentId.equals( mngUser.Contact.Parent_Account__c )
                    )
                )
                ||
                /* Account Match Sharing for all buckets except Master */
                ( 
                    comActivity.Distributor_Parent_Account__c != null &&
                    comActivity.Distributor_Account_Name__c != null &&
                    String.isBlank( comActivity.Distributor_Account__c ) &&
                    ( 
                        mngUser.Contact.AccountId.equals( comActivity.Distributor_Account_Name__c ) ||
                        mngUser.Contact.Parent_Account__c.equals( comActivity.Distributor_Parent_Account__c ) 
                    )
                )
            );
    }
    
    /* @Description
        Method Name : createComActivityShareRecord( Id , Id , String , String )

        1. Creates & returns an Commercial_Activity__Share instance
        
        @PARAMS
            1. NAME ( comActivityId )   => TYPE ( Id )      => DESCRIPTION ( Commercial Activity's Id )
            2. NAME ( userId )          => TYPE ( Id )      => DESCRIPTION ( Current user's Id )
            3. NAME ( accessLevel )     => TYPE ( String )  => DESCRIPTION ( Access Level )
            4. NAME ( rowCause )        => TYPE ( String )  => DESCRIPTION ( RowCause )
    */

    public static Commercial_Activity__Share createComActivityShareRecord( Id userId, Id comActivityId, String rowCause, String accessLevel ){
        return new Commercial_Activity__Share(
            ParentId = comActivityId,
            AccessLevel = accessLevel,
            RowCause = rowCause,
            UserOrGroupId = userId
        );
    }
    
    /* @Description
        Method Name : isRecalculationRequiredToShare( Commercial_Activity__c )

        Only shares a Commercial Activity if:
            1. It is a bucket record
            2. It is record created by distributor
        This method is used on Commercial Activity Insert  
        
        @PARAMS
            1. NAME ( comActivity )  => TYPE ( Commercial_Activity__c ) => DESCRIPTION ( New Commercial Activity from Trigger.New )
    */

    private static Boolean isRecalculationRequiredToShare(Commercial_Activity__c comActivity){
        
        return comActivity.RecordTypeId.equals(KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID) ||
            comActivity.RecordTypeId.equals(KPIConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID) ||
            comActivity.RecordTypeId.equals(KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID) ||
            comActivity.RecordTypeId.equals(KPIConstants.CUSTOMER_VISIT_RECORD_TYPE_ID) ||
            comActivity.RecordTypeId.equals(KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID) ||
            comActivity.RecordTypeId.equals(KPIConstants.SAMPLE_RECORD_TYPE_ID) ||
            comActivity.RecordTypeId.equals(KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID);
    }

    /* @Description
        Method Name : getCommercialActivityDistributorLocsMap( List<Other_Related_Customer_Location__c> )

        1. A commercial activity can be shared with multiple distributors
        2. Once such sharing comes from Related Customer Location object as well.
        3. If a commercial Activity KPI record has multiple Related customer location's record then a Map<Commercial Activity Id, List<Distributor Location Id>> is prepared 
        
        @PARAMS
            1. NAME ( relatedCustList ) => TYPE ( List<Other_Related_Customer_Location__c> )    => DESCRIPTION ( Each Commercial Activity record can be shared with multiple distributors, this is the map to store that )
    */

    private static Map<Id,List<Id>> getCommercialActivityDistributorLocsMap( List<Other_Related_Customer_Location__c> relatedCustList ){

        Map<Id,List<Id>> tempMap = new Map<Id,List<Id>>();

        for( Other_Related_Customer_Location__c othRelCust : relatedCustList ){

            if( !tempMap.containsKey( othRelCust.Related_Commercial_Activity__c ) ){
                
                tempMap.put( othRelCust.Related_Commercial_Activity__c, new List<Id>() );
            }
            tempMap.get( othRelCust.Related_Commercial_Activity__c ).add( othRelCust.Distributor_Location__c );
        }

        return tempMap;
    }

    /* @Description
        Method Name : deleteCommercialActivitySharing( Set<Id> , Set<Id> )

        1. Deletes sharing of commercial Activity records for given users and Commercial Activities
        
        @PARAMS
            1. NAME ( userIds )                 => TYPE ( Set<Id> ) => DESCRIPTION ( All users considered for commercial Activity sharing deletion )
            1. NAME ( commercialActivityIds )   => TYPE ( Set<Id> ) => DESCRIPTION ( All Commercial activities considered for sharing deletion )
    */

    public static void deleteCommercialActivitySharing(Set<Id> userIds, Set<Id> commercialActivityIds){

        delete [SELECT Id FROM Commercial_Activity__Share
                WHERE UserOrGroupId IN: userIds
                AND ParentId IN: commercialActivityIds
                AND RowCause =: KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE];

    }
    
    public static List<Commercial_Activity__c> allCommercialActivitiesRelatedToAccounts(Set<Id> AccountIds){
        return [
            SELECT Id,Distributor_Account__c,Distributor_Account_Name__c,Distributor_Parent_Account__c,RecordTypeId,
            OwnerId, CreatedById
            FROM Commercial_Activity__c
            WHERE (RecordTypeId = :KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND Distributor_Account__c != null
                   AND Distributor_Account__c IN: AccountIds)
            OR ((RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_PROMOTION_ACTIVITY_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_CUSTOMER_VISIT_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_SAMPLE_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.CUSTOMER_VISIT_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.SAMPLE_RECORD_TYPE_ID) AND
                Distributor_Account_Name__c != null AND Distributor_Parent_Account__c != null
                AND Distributor_Account__c = null AND
                (Distributor_Account_Name__c IN: AccountIds OR Distributor_Parent_Account__c IN: AccountIds))
        ];
    }
}