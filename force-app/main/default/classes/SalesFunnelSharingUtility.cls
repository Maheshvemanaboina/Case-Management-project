/*       
@Name           - SalesFunnelSharingUtility
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 12-04-2020
@UsedBy         - 1. RelatedCustomerLocationSharingUtility
                  2. SalesFunnelSharingBatch
                  3. SalesFunnelTriggerHandler

@Description    - This class will share all KPIs related to Sales Performane Object

UserId              | Author-Email                  | Date                  | Comment
====================|===============================|=======================|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 04-02-2021    | Updated class to according to new Account restructure & moving logic from shared Class to its own class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 22-09-2021    | Updated class to accomodate new KPI structure and new arrangement for related distributor locations
*/

public without sharing class SalesFunnelSharingUtility {
    
    /* @Description
        Method Name : shareAllSalesFunnelAndKPIsWithCommunityUsers( List<Sales_Funnel__c> )

        This method will share Sales Funnels and All related KPIs for Sales Funnel
        Related KPIs are:
            1. Distributor Sales To End Customer
        
        @PARAMS
            1. NAME ( newSalesFunnels ) => TYPE ( List<Sales_Funnel__c> ) => DESCRIPTION ( All new Sales Performances coming from Trigger.New when Sales performance KPIs are created )
    */
    public static void shareAllSalesFunnelAndKPIsWithCommunityUsers(List<Sales_Funnel__c> newSalesFunnels){

        List<Sales_Funnel__c> salesFunnelsToRecalculate = new List<Sales_Funnel__c>(); // Valid Sales Performance records to consider to sharing
        for ( Sales_Funnel__c sFunnel : newSalesFunnels ) {

            /* Checks if the Sales Funnel is valid to be shared */
            if ( isRecalculationRequiredToShare( sFunnel ) ) {
                salesFunnelsToRecalculate.add( sFunnel );
            } 
        }

        /* if not Empty, then initiate sharing */
        if( !salesFunnelsToRecalculate.isEmpty() ){
            initiateSalesFunnelSharing( UserUtility.getAllPartnerCommunityUsers(), salesFunnelsToRecalculate );
        }

    }

    /* @Description
        Method Name : initiateSalesFunnelSharing( List<User> , List<Sales_Funnel__c> )

        This method will separate the Ids to call the future or non - future methods based on the caller function
            1. If it is called from Trigger then future method "createSharingForSalesFunnelFuture" is called
            2. If it is called from Batch, then no future is called and direct "createSharingForSalesFunnel" is called.
        
        @PARAMS
            1. NAME ( userList )    => TYPE ( List<User> )              => DESCRIPTION ( All Partner community users )
            2. NAME ( sFunnelList ) => TYPE ( List<Sales_Funnel__c> )   => DESCRIPTION ( All Sales Performance records considered for re-calculation )
    */

    public static void initiateSalesFunnelSharing( List<User> userList, List<Sales_Funnel__c> sFunnelList ){

        Set<Id> usersIds = new Set<Id>();
        for ( User usr : userList ) {
            usersIds.add( usr.Id );
        }

        Set<Id> sFunnelIds = new Set<Id>();
        Set<Id> mastersFunnelIds = new Set<Id>();

        for ( Sales_Funnel__c sFunnel : DAOUtilityWithoutShar.getSalesFunnelsForSharing( (new Map<Id, Sales_Funnel__c>( sFunnelList )).keySet() ) ) {
            sFunnelIds.add( sFunnel.Id );

            /* Added for Related Customer Location Sharing */
            mastersFunnelIds.add( sFunnel.Parent_Sales_Funnel__c );
            mastersFunnelIds.add( sFunnel.Sales_Funnel_Sales_To_End_Customer__r?.Parent_Sales_Funnel__c );
        }

        mastersFunnelIds.remove( null );

        if(System.isBatch()){

            createSharingForSalesFunnel( usersIds, sFunnelIds, mastersFunnelIds );
        }else{

            createSharingForSalesFunnelFuture( usersIds, sFunnelIds, mastersFunnelIds );
        }
    }

    /* @Description
        Method Name : createSharingForSalesFunnelFuture( Set<Id> , Set<Id> , Set<Id> )

        1. future method to call non-future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )            => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( sFunnelIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All Sales Performance records Ids )
            3. NAME ( mastersFunnelIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All Sales Performance Bucket records Ids )
    */

    @future
    public static void createSharingForSalesFunnelFuture( Set<Id> usersIds, Set<Id> sFunnelIds, Set<Id> mastersFunnelIds ) {
        createSharingForSalesFunnel( usersIds, sFunnelIds, mastersFunnelIds );
    }

    /* @Description
        Method Name : createSharingForSalesFunnel( Set<Id> , Set<Id> , Set<Id> )

        1. non - future method called from future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )            => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( sFunnelIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All Sales Performance records Ids )
            3. NAME ( mastersFunnelIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All Sales Performance Bucket records Ids )
    */

    public static void createSharingForSalesFunnel( Set<Id> usersIds, Set<Id> sFunnelIds, Set<Id> mastersFunnelIds ) {

        //Query all Users from the userIds
        List<User> users = [SELECT Id, UserName, Contact.Name, Contact.Account.Name, Contact.Additional_Country_Responsibility__c, Contact.Business_Segment__c, Contact.Sub_Segment__c, Contact.Exclude_Customer_Location_Country__c, Community_Account_Role__c, Contact.Parent_Account__c, Contact.Account.BillingCountry, Contact.AccountId, Community_User_Role__c, IsPortalEnabled FROM User WHERE Id IN :usersIds];

        //Query all SalesFunnels from the sFunnelIds
        List<Sales_Funnel__c> sFunnelList = DAOUtilityWithoutShar.getSalesFunnelsForSharing( sFunnelIds );

        //Query all Other Related Customer Location records to share Sales Performance with them
        List<Other_Related_Customer_Location__c> relatedCustList = DAOUtilityWithoutShar.getRelatedCustomerLocationForSalesFunnel( mastersFunnelIds );

        //Map of <Sales Performance Bucket,List<Related Customer Loc>>
        Map<Id,List<Id>> salesPerformDistributorLocsMap = getSalesPerformanceDistributorLocsMap( relatedCustList );
        
        //Map of UserIds with Additional Customer Locations added at contact Level - ENH-4815
        Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(users);

        List<Sales_Funnel__Share> sFunnelShares = new List<Sales_Funnel__Share>();
        for ( Sales_Funnel__c sFunnel : sFunnelList ) {

            for ( User currUser : users ) {        

                    //Skip sharing if user already owns the Sales Funnel.
                    if ( sFunnel.OwnerId.equals( currUser.Id ) ) {
                        continue;
                    }

                    Sales_Funnel__Share sFunnelShare;

                    /* Checks if current user is standard user and initiates sharing for it or else initiate sharing for Manager user */
                    if ( UserUtility.isUserStandardCommunityUser( currUser ) ) {
                        sFunnelShare = createSharingForStandardUser( currUser, sFunnel, salesPerformDistributorLocsMap, usersWithAddCustLocsMap );
                    } else {
                        sFunnelShare = createSharingForManagerUser( currUser, sFunnel );
                    }

                    if ( sFunnelShare == null ) {
                        continue;
                    }

                    if( !sFunnelShares.contains( sFunnelShare ) ){
                        sFunnelShares.add( sFunnelShare );
                    }   
            }
        }

        DAOUtilityWithoutShar.insertWithoutAccess( sFunnelShares );
    }

    /* @Description
        Method Name : createSharingForStandardUser( User , Sales_Funnel__c , Map<Id,List<Id>> )

        1. non - future method called from future to start sharing
        2. This is for standard community user
        
        @PARAMS
            1. NAME ( currUser )                        => TYPE ( User )                => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( sFunnel )                         => TYPE ( Sales_Funnel__c )     => DESCRIPTION ( Current Sales performance record from loop )
            3. NAME ( salesPerformDistributorLocsMap )  => TYPE ( Map<Id,List<Id>> )    => DESCRIPTION ( Each Sales performance record can be shared with multiple distributors, this is the map to store that )
    */

    private static Sales_Funnel__Share createSharingForStandardUser(
        User currUser,
        Sales_Funnel__c sFunnel,
        Map<Id,List<Id>> salesPerformDistributorLocsMap,
        Map<Id, Set<Id>> usersWithAddCustLocsMap
    ){

            /* This part does the check for Sales Funnel Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only ( Record Type - KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID )
                2. If created by distributor then it is Read/Write ( Record Type - KPIConstants.DISTI_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID )
            */

            if( isEligibleForStandardUserSalesFunnelSharing( currUser, sFunnel, salesPerformDistributorLocsMap, usersWithAddCustLocsMap ) ){

                return createSalesFunnelShareRecord(
                    currUser.Id, 
                    sFunnel.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE,
                    sFunnel.RecordTypeId.equals( KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID ) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }
    
    /* @Description
        Method Name : createSharingForManagerUser( User , Sales_Funnel__c )

        1. non - future method called from future to start sharing
        2. This is for Manager user
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )            => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( sFunnel )     => TYPE ( Sales_Funnel__c ) => DESCRIPTION ( Current Sales performance record from loop )
    */

    private static Sales_Funnel__Share createSharingForManagerUser(
        User currUser,
        Sales_Funnel__c sFunnel){

            /* This part does the check for Sales Funnel Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only ( Record Type - KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID )
                2. If created by distributor then it is Read/Write ( Record Type - KPIConstants.DISTI_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID )
            */

            if(isEligibleForManagerUserSalesFunnelSharing( currUser, sFunnel ) ){

                return createSalesFunnelShareRecord(
                    currUser.Id, 
                    sFunnel.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE,
                    sFunnel.RecordTypeId.equals( KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID ) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    /* @Description
        Method Name : isEligibleForStandardUserSalesFunnelSharing( User , Sales_Funnel__c , Map<Id,List<Id>> )

        This checks whether a Sales performance record is eligible to be shared with standard user & does the following things:
            1. Checks if a Sales performance KPI record's distributor location = Contact's H5
            2. Checks if a Sales performance KPI record's distributor location's country = one of the contact's additional Countries
            3. Checks if a Sales performance KPI record's Related Customer location's distributor location = Contact's H5
        
        @PARAMS
            1. NAME ( currUser )                        => TYPE ( User )            => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( sFunnel )                         => TYPE ( Sales_Funnel__c ) => DESCRIPTION ( Current Sales performance record from loop )
            3. NAME ( salesPerformDistributorLocsMap )  => TYPE ( Map<Id,List<Id>> )=> DESCRIPTION ( Each Sales performance record can be shared with multiple distributors, this is the map to store that )
    */
    
    private static Boolean isEligibleForStandardUserSalesFunnelSharing( User stdUser, Sales_Funnel__c sFunnel, Map<Id,List<Id>> salesPerformDistributorLocsMap, Map<Id, Set<Id>> usersWithAddCustLocsMap ){

        return stdUser.Contact.AccountId != null &&
        stdUser.Contact.Parent_Account__c != null &&
        (  
            /* Account Match Sharing for Master */  
            (
                !String.isBlank( sFunnel.Distributor_Account__c ) &&
                ( 
                    /* Account Match Sharing for Master Bucket */
                    sFunnel.Distributor_Account__c.equals( stdUser.Contact.AccountId ) 
                    ||
                    /* Account Match Sharing for Master Bucket for related distributor locations */
                    ( 
                        salesPerformDistributorLocsMap.containsKey( sFunnel.Id ) && 
                        salesPerformDistributorLocsMap.get( sFunnel.Id ).contains( stdUser.Contact.AccountId )
                    )
                    ||
                        /* Account Match Sharing for Master Bucket for additional customer locations */
                        (
                        	usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null &&
                            usersWithAddCustLocsMap.get(stdUser.Id).contains(sFunnel.Distributor_Account__c)
                        )
                )
            )
            ||
            /* Account Match Sharing for all buckets except Master */
            (
                sFunnel.Distributor_Account_Name__c != null &&
                sFunnel.Distributor_Parent_Account__c != null &&
                String.isBlank( sFunnel.Distributor_Account__c ) &&
                stdUser.Contact.Parent_Account__c.equals( sFunnel.Distributor_Parent_Account__c ) &&
                (
                    stdUser.Contact.AccountId.equals( sFunnel.Distributor_Account_Name__c ) || 

                    /* Additional Country Responsibility Sharing */
                    (
                        stdUser.Contact.Additional_Country_Responsibility__c != null &&
                        sFunnel.Distributor_Account_Name__r.BillingCountry != null &&
                        stdUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase( sFunnel.Distributor_Account_Name__r.BillingCountry )
                    ) ||

                    /* Related Customer Location Sharing */
                    (   
                        //if current Sales Performance Record is Bucket Record
                        (
                            salesPerformDistributorLocsMap.containsKey( sFunnel.Parent_Sales_Funnel__c ) && 
                            salesPerformDistributorLocsMap.get( sFunnel.Parent_Sales_Funnel__c ).contains( stdUser.Contact.AccountId ) 
                        ) ||

                        //if current Sales Performance Record is Sales To End Customer Record
                        (   
                            !String.isBlank( sFunnel.Sales_Funnel_Sales_To_End_Customer__c ) &&
                            salesPerformDistributorLocsMap.containsKey( sFunnel.Sales_Funnel_Sales_To_End_Customer__r.Parent_Sales_Funnel__c ) && 
                            salesPerformDistributorLocsMap.get( sFunnel.Sales_Funnel_Sales_To_End_Customer__r.Parent_Sales_Funnel__c ).contains( stdUser.Contact.AccountId )
                        )
                    ) ||
                    /* Additional Customer Location Sharing */
                        (   
                            (usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null) &&
                            //if current Sales Performance Record is Bucket Record
                            ((
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(sFunnel.Distributor_Account_Name__c)
                            ) ||

                            //if current Sales Performance Record is Sales To End Customer Record
                            (
                                !String.isBlank( sFunnel.Sales_Funnel_Sales_To_End_Customer__c ) &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(sFunnel.Sales_Funnel_Sales_To_End_Customer__r.Distributor_Account_Name__c)
                            ))
                        )
                )
            )
        );
    }

    /* @Description
        Method Name : isEligibleForManagerUserSalesFunnelSharing( User , Sales_Funnel__c )

        This checks whether a Sales performance record is eligible to be shared with Manager user & does the following things:
            1. Checks if a Sales performance KPI record's distributor location = Contact's H5
            2. Checks if a Sales performance KPI record's distributor location's H1 = Contact's H1
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )                    => DESCRIPTION ( Current Manager community user from loop )
            2. NAME ( comActivity ) => TYPE ( Sales_Funnel__c )  => DESCRIPTION ( Current Sales performance record from loop )
    */

    private static Boolean isEligibleForManagerUserSalesFunnelSharing( User mngUser, Sales_Funnel__c sFunnel ){

        return mngUser.Contact.AccountId != null &&
            mngUser.Contact.Parent_Account__c != null &&
            (
                (
                    /* Account Match Sharing for Master bucket */
                    !String.isBlank( sFunnel.Distributor_Account__c ) &&
                    (
                        sFunnel.Distributor_Account__c.equals( mngUser.Contact.AccountId ) ||
                        sFunnel.Distributor_Account__r.ParentId.equals( mngUser.Contact.Parent_Account__c )
                    )
                )
                ||
                /* Account Match Sharing for all buckets except Master */
                (
                    sFunnel.Distributor_Parent_Account__c != null &&
                    sFunnel.Distributor_Account_Name__c != null &&
                    String.isBlank( sFunnel.Distributor_Account__c ) &&
                    (
                        mngUser.Contact.AccountId.equals( sFunnel.Distributor_Account_Name__c ) ||
                        mngUser.Contact.Parent_Account__c.equals( sFunnel.Distributor_Parent_Account__c ) 
                    )
                )
            );
    }

    /* @Description
        Method Name : createSalesFunnelShareRecord( Id , Id , String , String )

        1. Creates & returns an Sales_Funnel__Share instance
        
        @PARAMS
            1. NAME ( sFunnelId )   => TYPE ( Id )      => DESCRIPTION ( Sales performance's Id )
            2. NAME ( userId )      => TYPE ( Id )      => DESCRIPTION ( Current user's Id )
            3. NAME ( accessLevel ) => TYPE ( String )  => DESCRIPTION ( Access Level )
            4. NAME ( rowCause )    => TYPE ( String )  => DESCRIPTION ( RowCause )
    */

    private static Sales_Funnel__Share createSalesFunnelShareRecord( Id userId, Id sFunnelId, String rowCause, String accessLevel ){
        return new Sales_Funnel__Share(
            ParentId = sFunnelId,
            AccessLevel = accessLevel,
            RowCause = rowCause,
            UserOrGroupId = userId
        );
    }

    /* @Description
        Method Name : isRecalculationRequiredToShare( Sales_Funnel__c )

        Only shares a Sales performance if:
            1. It is a bucket record
            2. It is record created by distributor
        This method is used on Sales performance Insert  
        
        @PARAMS
            1. NAME ( comActivity ) => TYPE ( Sales_Funnel__c ) => DESCRIPTION ( New Sales performance from Trigger.New )
    */

    private static Boolean isRecalculationRequiredToShare( Sales_Funnel__c sFunnel ){

        return sFunnel.RecordTypeId.equals( KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID ) ||
        sFunnel.RecordTypeId.equals( KPIConstants.DISTI_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID ) ||
        sFunnel.RecordTypeId.equals( KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID );
    }

    /* @Description
        Method Name : getSalesPerformanceDistributorLocsMap( List<Other_Related_Customer_Location__c> )

        1. A Sales performance can be shared with multiple distributors
        2. Once such sharing comes from Related Customer Location object as well.
        3. If a Sales performance KPI record has multiple Related customer location's record then a Map<Sales performance Id, List<Distributor Location Id>> is prepared 
        
        @PARAMS
            1. NAME ( relatedCustList ) => TYPE ( List<Other_Related_Customer_Location__c> )    => DESCRIPTION ( Each Sales performance record can be shared with multiple distributors, this is the map to store that )
    */

    private static Map<Id,List<Id>> getSalesPerformanceDistributorLocsMap( List<Other_Related_Customer_Location__c> relatedCustList ){

        Map<Id,List<Id>> tempMap = new Map<Id,List<Id>>();

        for( Other_Related_Customer_Location__c othRelCust : relatedCustList ){

            if( !tempMap.containsKey( othRelCust.Related_Sales_Performance__c ) ){
                
                tempMap.put( othRelCust.Related_Sales_Performance__c, new List<Id>() );
            }
            tempMap.get( othRelCust.Related_Sales_Performance__c ).add( othRelCust.Distributor_Location__c );
        }

        return tempMap;
    }

    /* @Description
        Method Name : deleteSalesPerformanceSharing( Set<Id> , Set<Id> )

        1. Deletes sharing of Sales performance records for given users and Sales performances
        
        @PARAMS
            1. NAME ( userIds )             => TYPE ( Set<Id> ) => DESCRIPTION ( All users considered for Sales performance sharing deletion )
            1. NAME ( salesPeformanceIds )  => TYPE ( Set<Id> ) => DESCRIPTION ( All Sales performances considered for sharing deletion )
    */

    public static void deleteSalesPerformanceSharing( Set<Id> userIds, Set<Id> salesPeformanceIds ){

        delete [SELECT Id FROM Sales_Funnel__Share
                WHERE UserOrGroupId IN: userIds
                AND ParentId IN: salesPeformanceIds
                AND RowCause =: KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE];

    }
    
    public static List<Sales_Funnel__c> allSalesFunnelsRelatedToAccounts(Set<Id> AccountIds){
        return [
            SELECT Id,Distributor_Account__c,Distributor_Account_Name__c,Distributor_Parent_Account__c,RecordTypeId,
            OwnerId, CreatedById
            FROM Sales_Funnel__c
            WHERE (RecordTypeId = :KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND Distributor_Account__c != null
                   AND Distributor_Account__c IN: AccountIds)
            OR ((RecordTypeId =: KPIConstants.SALES_FUNNEL_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.DISTI_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID) AND
                Distributor_Account_Name__c != null AND Distributor_Parent_Account__c != null
                AND Distributor_Account__c = null AND
                (Distributor_Account_Name__c IN: AccountIds OR Distributor_Parent_Account__c IN: AccountIds))
        ];
    }
}