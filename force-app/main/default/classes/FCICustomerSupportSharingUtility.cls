/*       
@Name           - CommercialActivitySharingUtility
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 12-04-2020

@Description    - This class will share all KPIs related to FCI Customer Support Object

UserId              | Author-Email                  | Date                  | Comment
====================|===============================|=======================|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 05-02-2021    | Updated class to according to new Account restructure & moving logic from shared Class to its own class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 22-09-2021    | Updated class to accomodate new KPI structure and new arrangement for related distributor locations
*/
public without sharing class FCICustomerSupportSharingUtility {

    /* This method will share Forecast Accuracies and All related KPIs for FCI Customer Support
        Related KPIs are:
        1. Order Process
        2. Complaints ( Cases ) ( This is not shared in this code even if it is present in the mock up because Case sharing is already enabled in Case Trigger) ( We use the standard Case object )
    */

    public static void shareAllFCICustomerSupprortAndKPIsWithCommunityUsers( List<FCI_Customer_Support__c> newFCISupports ){

        List<FCI_Customer_Support__c> fciCustSuppToRecalculate = new List<FCI_Customer_Support__c>();
        for ( FCI_Customer_Support__c fciSupp : newFCISupports ) {

            /* Checks if the FCI Customer Support is valid to be shared */
            if ( isRecalculationRequiredToShare( fciSupp ) ) {
                fciCustSuppToRecalculate.add( fciSupp );
            } 
        }

        /* if not Empty, then initiate sharing */
        if( !fciCustSuppToRecalculate.isEmpty() ){
            initiateFCICustomerSupportSharing( UserUtility.getAllPartnerCommunityUsers(), fciCustSuppToRecalculate );
        }

    }

    /* @Description
        Method Name : initiateFCICustomerSupportSharing( List<User> , List<FCI_Customer_Support__c> )

        This method will separate the Ids to call the future or non - future methods based on the caller function
            1. If it is called from Trigger then future method "createSharingForFCICustomerSupportFuture" is called
            2. If it is called from Batch, then no future is called and direct "createSharingForFCICustomerSupport" is called.
        
        @PARAMS
            1. NAME ( userList )    => TYPE ( List<User> )                      => DESCRIPTION ( All Partner community users )
            2. NAME ( fciSuppList ) => TYPE ( List<FCI_Customer_Support__c> )   => DESCRIPTION ( All FCI Customer Support records considered for re-calculation )
    */

    public static void initiateFCICustomerSupportSharing( List<User> userList, List<FCI_Customer_Support__c> fciSuppList ){

        Set<Id> usersIds = new Set<Id>();
        for( User usr : userList ) {
            usersIds.add( usr.Id );
        }

        Set<Id> fciSuppIds = new Set<Id>();
        Set<Id> masterfciSuppIds = new Set<Id>();

        for ( FCI_Customer_Support__c fciSupp : DAOUtilityWithoutShar.getFCICustomerSupportsForSharing( (new Map<Id, FCI_Customer_Support__c>( fciSuppList )).keySet() ) ) {
            fciSuppIds.add( fciSupp.Id );

            /* Added for Related Customer Location Sharing */
            masterfciSuppIds.add( fciSupp.Parent_FCI_Customer_Support__c );
            masterfciSuppIds.add( fciSupp.FCI_Customer_Support_Order_Process__r?.Parent_FCI_Customer_Support__c );
        }

        masterfciSuppIds.remove( null );

        if(System.isBatch()){

            createSharingForFCICustomerSupport( usersIds, fciSuppIds, masterfciSuppIds );
        }else{

            createSharingForFCICustomerSupportFuture( usersIds, fciSuppIds, masterfciSuppIds );
        }
    }

    /* @Description
        Method Name : createSharingForFCICustomerSupportFuture( Set<Id> , Set<Id> , Set<Id> )

        1. future method to call non-future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )            => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( fciSuppIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All FCI Customer Support records Ids )
            3. NAME ( masterfciSuppIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All FCI Customer Support master Bucket records Ids )
    */

    @future
    public static void createSharingForFCICustomerSupportFuture( Set<Id> usersIds, Set<Id> fciSuppIds, Set<Id> masterfciSuppIds ) {
        createSharingForFCICustomerSupport( usersIds, fciSuppIds, masterfciSuppIds );
    }

    /* @Description
        Method Name : createSharingForFCICustomerSupport( Set<Id> , Set<Id> , Set<Id> )

        1. non - future method called from future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )            => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( fciSuppIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All FCI Customer Support records Ids )
            3. NAME ( masterfciSuppIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All FCI Customer Support master Bucket records Ids )
    */

    public static void createSharingForFCICustomerSupport( Set<Id> usersIds, Set<Id> fciSuppIds, Set<Id> masterfciSuppIds ) {

        //Query all Users from the userIds
        List<User> users = [SELECT Id, UserName, Contact.Name, Contact.Account.Name, Contact.Additional_Country_Responsibility__c, Contact.Business_Segment__c, Contact.Sub_Segment__c, Contact.Exclude_Customer_Location_Country__c, Community_Account_Role__c, Contact.Parent_Account__c, Contact.Account.BillingCountry, Contact.AccountId, Community_User_Role__c, IsPortalEnabled FROM User WHERE Id IN :usersIds];

        //Query all FCI Customer Support from the fciSuppIds
        List<FCI_Customer_Support__c> fciCustSuppList = DAOUtilityWithoutShar.getFCICustomerSupportsForSharing( fciSuppIds );

        //Query all Other Related Customer Location records to share Sales Performance with them
        List<Other_Related_Customer_Location__c> relatedCustList = DAOUtilityWithoutShar.getRelatedCustomerLocationForFCICustomerSupport( masterfciSuppIds );

        //Map of <FCI Customer Bucket,List<Related Customer Loc>>
        Map<Id,List<Id>> fciCustSuppDistributorLocsMap = getfciCustSuppDistributorLocsMap( relatedCustList );
        
        //Map of UserIds with Additional Customer Locations added at contact Level - ENH-4815
        Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(users);

        List<FCI_Customer_Support__Share> fciCustSuppShares = new List<FCI_Customer_Support__Share>();
        for ( FCI_Customer_Support__c fciCustSupp : fciCustSuppList ) {

            for ( User currUser : users ) {        

                    //Skip sharing if user already owns the FCI Customer Support.
                    if ( fciCustSupp.OwnerId.equals( currUser.Id ) ) {
                        continue;
                    }

                    FCI_Customer_Support__Share fciCustSuppShare;

                    /* Checks if current user is standard user and initiates sharing for it or else initiate sharing for Manager user */
                    if ( UserUtility.isUserStandardCommunityUser( currUser ) ) {
                        fciCustSuppShare = createSharingForStandardUser( currUser, fciCustSupp, fciCustSuppDistributorLocsMap, usersWithAddCustLocsMap );
                    } else {
                        fciCustSuppShare = createSharingForManagerUser( currUser, fciCustSupp );
                    }

                    if ( fciCustSuppShare == null ) {
                        continue;
                    }

                    if( !fciCustSuppShares.contains( fciCustSuppShare ) ){
                        fciCustSuppShares.add( fciCustSuppShare );
                    }   
            }
        }

        DAOUtilityWithoutShar.insertWithoutAccess( fciCustSuppShares );
    }

    /* @Description
        Method Name : createSharingForStandardUser( User , FCI_Customer_Support__c , Map<Id,List<Id>> )

        1. non - future method called from future to start sharing
        2. This is for standard community user
        
        @PARAMS
            1. NAME ( currUser )                        => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( fciCustSupp )                     => TYPE ( FCI_Customer_Support__c ) => DESCRIPTION ( Current FCI Customer Support record from loop )
            3. NAME ( fciCustSuppDistributorLocsMap )   => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each FCI Customer Support record can be shared with multiple distributors, this is the map to store that )
    */

    private static FCI_Customer_Support__Share createSharingForStandardUser(
        User currUser,
        FCI_Customer_Support__c fciCustSupp,
        Map<Id,List<Id>> fciCustSuppDistributorLocsMap,
        Map<Id, Set<Id>> usersWithAddCustLocsMap
    ){

            /* This part does the check for FCI Customer Support Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only , includes recordTypes:
                    a. KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID
                    b. KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID

                2. If created by distributor then it is Read/Write, includes recordType"
                    a. KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID
            */

            if( isEligibleForStandardUserFCICustomerSupportSharing( currUser, fciCustSupp, fciCustSuppDistributorLocsMap, usersWithAddCustLocsMap ) ){

                return createFCICustomerSupportShareRecord(
                    currUser.Id, 
                    fciCustSupp.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE,
                    !fciCustSupp.RecordTypeId.equals( KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID ) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    /* @Description
        Method Name : createSharingForManagerUser( User , FCI_Customer_Support__c )

        1. non - future method called from future to start sharing
        2. This is for Manager user
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( fciCustSupp ) => TYPE ( FCI_Customer_Support__c ) => DESCRIPTION ( Current FCI Customer Support record from loop )
    */

    private static FCI_Customer_Support__Share createSharingForManagerUser(
        User currUser,
        FCI_Customer_Support__c fciCustSupp){

            /* This part does the check for FCI Customer Support Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only , includes recordTypes:
                    a. KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID
                    b. KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID

                2. If created by distributor then it is Read/Write, includes recordType"
                    a. KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID
            */

            if( isEligibleForManagerUserFCICustomerSupportSharing( currUser, fciCustSupp ) ){

                return createFCICustomerSupportShareRecord(
                    currUser.Id, 
                    fciCustSupp.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE,
                    !fciCustSupp.RecordTypeId.equals(KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    /* @Description
        Method Name : isEligibleForStandardUserFCICustomerSupportSharing( User , FCI_Customer_Support__c , Map<Id,List<Id>> )

        This checks whether a FCI Customer Support record is eligible to be shared with standard user & does the following things:
            1. Checks if a FCI Customer Support KPI record's distributor location = Contact's H5
            2. Checks if a FCI Customer Support KPI record's distributor location's country = one of the contact's additional Countries
            3. Checks if a FCI Customer Support KPI record's Related Customer location's distributor location = Contact's H5
        
        @PARAMS
            1. NAME ( currUser )                        => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( fciCustSupp )                     => TYPE ( FCI_Customer_Support__c )  => DESCRIPTION ( Current FCI Customer Support record from loop )
            3. NAME ( fciCustSuppDistributorLocsMap )   => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each FCI Customer Support record can be shared with multiple distributors, this is the map to store that )
    */

    private static Boolean isEligibleForStandardUserFCICustomerSupportSharing( User stdUser, FCI_Customer_Support__c fciCustSupp, Map<Id,List<Id>> fciCustSuppDistributorLocsMap, Map<Id, Set<Id>> usersWithAddCustLocsMap ){

        return stdUser.Contact.AccountId != null &&
        stdUser.Contact.Parent_Account__c != null &&
        (  
            /* Account Match Sharing for Master */
            (
                !String.isBlank( fciCustSupp.Distributor_Account__c ) &&
                ( 
                    /* Account Match Sharing for Master Bucket */
                    fciCustSupp.Distributor_Account__c.equals( stdUser.Contact.AccountId ) 
                    ||
                    /* Account Match Sharing for Master Bucket for related distributor locations */
                    ( 
                        fciCustSuppDistributorLocsMap.containsKey( fciCustSupp.Id ) && 
                        fciCustSuppDistributorLocsMap.get( fciCustSupp.Id ).contains( stdUser.Contact.AccountId )
                    )
                    ||
                        /* Account Match Sharing for Master Bucket for additional customer locations */
                        (
                        	usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null &&
                            usersWithAddCustLocsMap.get(stdUser.Id).contains(fciCustSupp.Distributor_Account__c)
                        )
                )
            )
            ||
            /* Account Match Sharing for all buckets except Master */
            (
                fciCustSupp.Distributor_Account_Name__c != null &&
                fciCustSupp.Distributor_Parent_Account__c != null &&
                String.isBlank( fciCustSupp.Distributor_Account__c ) &&
                stdUser.Contact.Parent_Account__c.equals( fciCustSupp.Distributor_Parent_Account__c ) &&
                (
                    stdUser.Contact.AccountId.equals( fciCustSupp.Distributor_Account_Name__c ) || 
                    /* Additional Country Responsibility Sharing */
                    (
                        stdUser.Contact.Additional_Country_Responsibility__c != null &&
                        fciCustSupp.Distributor_Account_Name__r.BillingCountry != null &&
                        stdUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase( fciCustSupp.Distributor_Account_Name__r.BillingCountry )
                    ) ||

                    /* Related Customer Location Sharing */
                    (   
                        //if current FCI Customer Support Record is Bucket Record
                        (
                            fciCustSuppDistributorLocsMap.containsKey( fciCustSupp.Parent_FCI_Customer_Support__c ) && 
                            fciCustSuppDistributorLocsMap.get( fciCustSupp.Parent_FCI_Customer_Support__c ).contains( stdUser.Contact.AccountId ) 
                        ) ||

                        //if current FCI Customer Support Record is Order Process Record
                        (
                            !String.isBlank( fciCustSupp.FCI_Customer_Support_Order_Process__c ) &&
                            fciCustSuppDistributorLocsMap.containsKey( fciCustSupp.FCI_Customer_Support_Order_Process__r.Parent_FCI_Customer_Support__c ) && 
                            fciCustSuppDistributorLocsMap.get( fciCustSupp.FCI_Customer_Support_Order_Process__r.Parent_FCI_Customer_Support__c ).contains( stdUser.Contact.AccountId )
                        )
                    ) ||
                    /* Additional Customer Location Sharing */
                        (   
                            (usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null) &&
                            //if current FCI Customer Support Record is Bucket Record
                            ((
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(fciCustSupp.Distributor_Account_Name__c)
                            ) ||

                            //if current FCI Customer Support Record is Order Process Record
                            (
                                !String.isBlank( fciCustSupp.FCI_Customer_Support_Order_Process__c ) &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(fciCustSupp.FCI_Customer_Support_Order_Process__r.Distributor_Account_Name__c)
                            ))
                        )
                )
            )
        );
    }

    /* @Description
        Method Name : isEligibleForManagerUserFCICustomerSupportSharing( User , FCI_Customer_Support__c )

        This checks whether a FCI Customer Support record is eligible to be shared with Manager user & does the following things:
            1. Checks if a FCI Customer Support KPI record's distributor location = Contact's H5
            2. Checks if a FCI Customer Support KPI record's distributor location's H1 = Contact's H1
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )                    => DESCRIPTION ( Current Manager community user from loop )
            2. NAME ( fciCustSupp ) => TYPE ( FCI_Customer_Support__c ) => DESCRIPTION ( Current FCI Customer Support record from loop )
    */

    private static Boolean isEligibleForManagerUserFCICustomerSupportSharing( User mngUser, FCI_Customer_Support__c fciCustSupp ){

        return mngUser.Contact.AccountId != null &&
            mngUser.Contact.Parent_Account__c != null &&
            (
                /* Account Match Sharing for Master bucket */
                (
                    !String.isBlank( fciCustSupp.Distributor_Account__c ) &&
                    (
                        fciCustSupp.Distributor_Account__c.equals( mngUser.Contact.AccountId ) ||
                        fciCustSupp.Distributor_Account__r.ParentId.equals( mngUser.Contact.Parent_Account__c )
                    )
                )
                ||
                /* Account Match Sharing for all buckets except Master */
                (
                    fciCustSupp.Distributor_Parent_Account__c != null &&
                    fciCustSupp.Distributor_Account_Name__c != null &&
                    String.isBlank( fciCustSupp.Distributor_Account__c ) &&
                    (
                        mngUser.Contact.AccountId.equals( fciCustSupp.Distributor_Account_Name__c ) ||
                        mngUser.Contact.Parent_Account__c.equals( fciCustSupp.Distributor_Parent_Account__c ) 
                    )
                    
                )
            );
            
    }

    /* @Description
        Method Name : createFCICustomerSupportShareRecord( Id , Id , String , String )

        1. Creates & returns an FCI_Customer_Support__Share instance
        
        @PARAMS
            1. NAME ( userId )          => TYPE ( Id )      => DESCRIPTION ( Current user's Id )
            2. NAME ( fciCustSuppId )   => TYPE ( Id )      => DESCRIPTION ( FCI Customer Support's Id )
            3. NAME ( rowCause )        => TYPE ( String )  => DESCRIPTION ( RowCause )
            4. NAME ( accessLevel )     => TYPE ( String )  => DESCRIPTION ( Access Level )
    */

    private static FCI_Customer_Support__Share createFCICustomerSupportShareRecord( Id userId, Id fciCustSuppId, String rowCause, String accessLevel ){
        return new FCI_Customer_Support__Share(
            ParentId = fciCustSuppId,
            AccessLevel = accessLevel,
            RowCause = rowCause,
            UserOrGroupId = userId
        );
    }

    /* @Description
        Method Name : isRecalculationRequiredToShare( FCI_Customer_Support__c )

        Only shares a FCI Customer Support if:
            1. It is a bucket record
            2. It is record created by distributor
        This method is used on FCI Customer Support Insert  
        
        @PARAMS
            1. NAME ( fciCustSupp )  => TYPE ( FCI_Customer_Support__c ) => DESCRIPTION ( New FCI Customer Support from Trigger.New )
    */

    private static Boolean isRecalculationRequiredToShare( FCI_Customer_Support__c fciCustSupp ){

        return fciCustSupp.RecordTypeId.equals( KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID ) ||
            fciCustSupp.RecordTypeId.equals( KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID ) ||
            fciCustSupp.RecordTypeId.equals( KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID ) ||
            fciCustSupp.RecordTypeId.equals( KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID );
    }

    /* @Description
        Method Name : getfciCustSuppDistributorLocsMap( List<Other_Related_Customer_Location__c> )

        1. A FCI Customer Support can be shared with multiple distributors
        2. Once such sharing comes from Related Customer Location object as well.
        3. If a FCI Customer Support KPI record has multiple Related customer location's record then a Map<FCI Customer Support Id, List<Distributor Location Id>> is prepared 
        
        @PARAMS
            1. NAME ( relatedCustList ) => TYPE ( List<Other_Related_Customer_Location__c> )    => DESCRIPTION ( Each FCI Customer Support record can be shared with multiple distributors, this is the map to store that )
    */

    private static Map<Id,List<Id>> getfciCustSuppDistributorLocsMap( List<Other_Related_Customer_Location__c> relatedCustList ){

        Map<Id,List<Id>> tempMap = new Map<Id,List<Id>>();

        for( Other_Related_Customer_Location__c othRelCust : relatedCustList ){

            if( !tempMap.containsKey( othRelCust.Related_FCI_Customer_Support__c ) ){
                
                tempMap.put( othRelCust.Related_FCI_Customer_Support__c, new List<Id>() );
            }
            tempMap.get( othRelCust.Related_FCI_Customer_Support__c ).add( othRelCust.Distributor_Location__c );
        }

        return tempMap;
    } 

    /* @Description
        Method Name : deleteFCICustomerSupportSharing( Set<Id> , Set<Id> )

        1. Deletes sharing of FCI Customer Support records for given users and FCI Customer Supports
        
        @PARAMS
            1. NAME ( userIds )         => TYPE ( Set<Id> ) => DESCRIPTION ( All users considered for FCI Customer Support sharing deletion )
            1. NAME ( fciCustSuppIds )  => TYPE ( Set<Id> ) => DESCRIPTION ( All FCI Customer Supports considered for sharing deletion )
    */

    public static void deleteFCICustomerSupportSharing( Set<Id> userIds, Set<Id> fciCustSuppIds ){

        delete [SELECT Id FROM FCI_Customer_Support__Share
                WHERE UserOrGroupId IN: userIds
                AND ParentId IN: fciCustSuppIds
                AND RowCause =: KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE];

    }
    
    public static List<FCI_Customer_Support__c> allFCICustomerSupportsRelatedToAccounts(Set<Id> AccountIds){
        return [
            SELECT Id,Distributor_Account__c,Distributor_Account_Name__c,Distributor_Parent_Account__c,RecordTypeId,
            OwnerId, CreatedById
            FROM FCI_Customer_Support__c
            WHERE (RecordTypeId = :KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND Distributor_Account__c != null
                   AND Distributor_Account__c IN: AccountIds)
            OR ((RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID) AND
                Distributor_Account_Name__c != null AND Distributor_Parent_Account__c != null
                AND Distributor_Account__c = null AND
                (Distributor_Account_Name__c IN: AccountIds OR Distributor_Parent_Account__c IN: AccountIds))
        ];
    }

}