/*       
@Name           - CommercialActivitySharingUtility
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 12-04-2020

@Description    - This class will share all KPIs related to Forecast Accuracy Object

UserId              | Author-Email                  | Date                  | Comment
====================|===============================|=======================|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 05-02-2021    | Updated class to according to new Account restructure & moving logic from shared Class to its own class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 22-09-2021    | Updated class to accomodate new KPI structure and new arrangement for related distributor locations
*/
public without sharing class ForecastAccuracySharingUtility {

    /* This method will share Forecast Accuracies and All related KPIs for Forecast Accuracy
        Related KPIs are:
        1. Local Stock
    */

    public static void shareAllForecastsAndKPIsWithCommunityUsers( List<Forecast_Accuracy__c> newforcasts ){

        List<Forecast_Accuracy__c> forecastsToRecalculate = new List<Forecast_Accuracy__c>();
        for ( Forecast_Accuracy__c fcast : newforcasts ) {

            /* Checks if the Forecast Accuracy is valid to be shared */
            if ( isRecalculationRequiredToShare( fcast ) ) {
                forecastsToRecalculate.add( fcast );
            } 
        }

        /* if not Empty, then initiate sharing */
        if( !forecastsToRecalculate.isEmpty() ){
            initiateForecastAccuracySharing( UserUtility.getAllPartnerCommunityUsers(), forecastsToRecalculate );
        }

    }

    /* @Description
        Method Name : initiateForecastAccuracySharing( List<User> , List<Forecast_Accuracy__c> )

        This method will separate the Ids to call the future or non - future methods based on the caller function
            1. If it is called from Trigger then future method "createSharingForForecastAccuracyFuture" is called
            2. If it is called from Batch, then no future is called and direct "createSharingForForecastAccuracy" is called.
        
        @PARAMS
            1. NAME ( userList )        => TYPE ( List<User> )                    => DESCRIPTION ( All Partner community users )
            2. NAME ( forecastAccList ) => TYPE ( List<Forecast_Accuracy__c> )    => DESCRIPTION ( All Forecast Accuracy records considered for re-calculation )
    */

    public static void initiateForecastAccuracySharing( List<User> userList, List<Forecast_Accuracy__c> forecastAccList ){

        Set<Id> usersIds = new Set<Id>();
        for ( User usr : userList ) {
            usersIds.add( usr.Id );
        }

        Set<Id> forecastAccIds = new Set<Id>();
        Set<Id> masterforecastAccIds = new Set<Id>();

        for ( Forecast_Accuracy__c fcast : DAOUtilityWithoutShar.getForecastAccuracyForSharing( (new Map<Id, Forecast_Accuracy__c>( forecastAccList )).keySet() ) ) {
            forecastAccIds.add( fcast.Id );

            /* Added for Related Customer Location Sharing */
            masterforecastAccIds.add( fcast.Parent_Forecast__c );
            masterforecastAccIds.add( fcast.Forecast_Accuracy_Local_Stock__r?.Parent_Forecast__c );
        }

        masterforecastAccIds.remove( null );

        if(System.isBatch()){

            createSharingForForecastAccuracy( usersIds, forecastAccIds, masterforecastAccIds );
        }else{

            createSharingForForecastAccuracyFuture( usersIds, forecastAccIds, masterforecastAccIds );
        }
    }

    /* @Description
        Method Name : createSharingForForecastAccuracyFuture( Set<Id> , Set<Id> , Set<Id> )

        1. future method to call non-future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )                => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( forecastAccIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All Forecast Accuracy records Ids )
            3. NAME ( masterforecastAccIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All Forecast Accuracy master Bucket records Ids )
    */

    @future
    public static void createSharingForForecastAccuracyFuture( Set<Id> usersIds, Set<Id> forecastAccIds, Set<Id> masterforecastAccIds ) {
        createSharingForForecastAccuracy( usersIds, forecastAccIds, masterforecastAccIds );
    }

    /* @Description
        Method Name : createSharingForForecastAccuracy( Set<Id> , Set<Id> , Set<Id> )

        1. non - future method called from future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )                => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( forecastAccIds )          => TYPE ( Set<Id> ) => DESCRIPTION ( All Forecast Accuracy records Ids )
            3. NAME ( masterforecastAccIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All Forecast Accuracy master Bucket records Ids )
    */

    public static void createSharingForForecastAccuracy( Set<Id> usersIds, Set<Id> forecastAccIds, Set<Id> masterforecastAccIds ) {

        //Query all Users from the userIds
        List<User> users = [SELECT Id, UserName, Contact.Name, Contact.Account.Name, Contact.Additional_Country_Responsibility__c, Contact.Business_Segment__c, Contact.Sub_Segment__c, Contact.Exclude_Customer_Location_Country__c, Community_Account_Role__c, Contact.Parent_Account__c, Contact.Account.BillingCountry, Contact.AccountId, Community_User_Role__c, IsPortalEnabled FROM User WHERE Id IN :usersIds];

        //Query all forecast Accuracy from the forecastAccIds
        List<Forecast_Accuracy__c> forecastAccList = DAOUtilityWithoutShar.getForecastAccuracyForSharing( forecastAccIds );

        //Query all Other Related Customer Location records to share Sales Performance with them
        List<Other_Related_Customer_Location__c> relatedCustList = DAOUtilityWithoutShar.getRelatedCustomerLocationForForecastAccuracy( masterforecastAccIds );

        //Map of <Sales Performance Bucket,List<Related Customer Loc>>
        Map<Id,List<Id>> forecastAccuracyDistributorLocsMap = getForecastAccuracyDistributorLocsMap( relatedCustList );
        
        //Map of UserIds with Additional Customer Locations added at contact Level - ENH-4815
        Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(users);

        List<Forecast_Accuracy__Share> forecastAccShares = new List<Forecast_Accuracy__Share>();
        for ( Forecast_Accuracy__c fcast : forecastAccList ) {

            for ( User currUser : users ) {        

                    //Skip sharing if user already owns the Forecast Accuracy.
                    if ( fcast.OwnerId.equals( currUser.Id ) ) {
                        continue;
                    }

                    Forecast_Accuracy__Share forecastAccShare;

                    /* Checks if current user is standard user and initiates sharing for it or else initiate sharing for Manager user */
                    if ( UserUtility.isUserStandardCommunityUser( currUser ) ) {
                        forecastAccShare = createSharingForStandardUser( currUser, fcast, forecastAccuracyDistributorLocsMap, usersWithAddCustLocsMap );
                    } else {
                        forecastAccShare = createSharingForManagerUser( currUser, fcast );
                    }

                    if ( forecastAccShare == null ) {
                        continue;
                    }

                    if( !forecastAccShares.contains( forecastAccShare ) ){
                        forecastAccShares.add( forecastAccShare );
                    }   
            }
        }

        DAOUtilityWithoutShar.insertWithoutAccess( forecastAccShares );
    }

    /* @Description
        Method Name : createSharingForStandardUser( User , Forecast_Accuracy__c , Map<Id,List<Id>> )

        1. non - future method called from future to start sharing
        2. This is for standard community user
        
        @PARAMS
            1. NAME ( currUser )                            => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( fcast )                               => TYPE ( Forecast_Accuracy__c )    => DESCRIPTION ( Current Forecast Accuracy record from loop )
            3. NAME ( forecastAccuracyDistributorLocsMap )  => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each Forecast Accuracy record can be shared with multiple distributors, this is the map to store that )
    */
    private static Forecast_Accuracy__Share createSharingForStandardUser(
        User currUser,
        Forecast_Accuracy__c fcast,
        Map<Id,List<Id>> forecastAccuracyDistributorLocsMap,
        Map<Id, Set<Id>> usersWithAddCustLocsMap
        ){

            /* This part does the check for Forecast Accuracy Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only ( Record Type - KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID )
                2. If created by distributor then it is Read/Write ( Record Type - KPIConstants.LOCAL_STOCK_RECORD_TYPE_ID )
            */

            if( isEligibleForStandardUserForecastAccuracySharing( currUser, fcast, forecastAccuracyDistributorLocsMap, usersWithAddCustLocsMap ) ){

                return createForecastAccuracyShareRecord(
                    currUser.Id, 
                    fcast.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE,
                    fcast.RecordTypeId.equals( KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID ) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    /* @Description
        Method Name : createSharingForManagerUser( User , Forecast_Accuracy__c )

        1. non - future method called from future to start sharing
        2. This is for Manager user
        
        @PARAMS
            1. NAME ( currUser )=> TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( fcast )   => TYPE ( Forecast_Accuracy__c )    => DESCRIPTION ( Current Forecast Accuracy record from loop )
    */
    private static Forecast_Accuracy__Share createSharingForManagerUser(
        User currUser,
        Forecast_Accuracy__c fcast){

            /* This part does the check for Forecast Accuracy Sharing and gives Read or Read/Write depending upon
                1. If a bucket is shared, then it is read Only ( Record Type - KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID )
                2. If created by distributor then it is Read/Write ( Record Type - KPIConstants.LOCAL_STOCK_RECORD_TYPE_ID )
            */

            if( isEligibleForManagerUserForecastAccuracySharing( currUser, fcast ) ){

                return createForecastAccuracyShareRecord(
                    currUser.Id, 
                    fcast.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE,
                    fcast.RecordTypeId.equals( KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID ) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    /* @Description
        Method Name : isEligibleForStandardUserForecastAccuracySharing( User , Forecast_Accuracy__c , Map<Id,List<Id>> )

        This checks whether a Forecast Accuracy record is eligible to be shared with standard user & does the following things:
            1. Checks if a Forecast Accuracy KPI record's distributor location = Contact's H5
            2. Checks if a Forecast Accuracy KPI record's distributor location's country = one of the contact's additional Countries
            3. Checks if a Forecast Accuracy KPI record's Related Customer location's distributor location = Contact's H5
        
        @PARAMS
            1. NAME ( currUser )                            => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( fcast )                               => TYPE ( Forecast_Accuracy__c )    => DESCRIPTION ( Current Forecast Accuracy record from loop )
            3. NAME ( forecastAccuracyDistributorLocsMap )  => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each Forecast Accuracy record can be shared with multiple distributors, this is the map to store that )
    */

    private static Boolean isEligibleForStandardUserForecastAccuracySharing( User stdUser, Forecast_Accuracy__c fcast, Map<Id,List<Id>> forecastAccuracyDistributorLocsMap, Map<Id, Set<Id>> usersWithAddCustLocsMap ){

        return stdUser.Contact.AccountId != null &&
        stdUser.Contact.Parent_Account__c != null &&
        (  
            /* Account Match Sharing for Master */
            (
                !String.isBlank( fcast.Distributor_Account__c ) &&
                ( 
                    /* Account Match Sharing for Master Bucket */
                    fcast.Distributor_Account__c.equals( stdUser.Contact.AccountId ) 
                    ||
                    /* Account Match Sharing for Master Bucket for related distributor locations */
                    ( 
                        forecastAccuracyDistributorLocsMap.containsKey( fcast.Id ) && 
                        forecastAccuracyDistributorLocsMap.get( fcast.Id ).contains( stdUser.Contact.AccountId )
                    )
                    ||
                        /* Account Match Sharing for Master Bucket for additional customer locations */
                        (
                        	usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null &&
                            usersWithAddCustLocsMap.get(stdUser.Id).contains(fcast.Distributor_Account__c)
                        )
                )
            )
            ||
            /* Account Match Sharing for all buckets except Master */
            (
                fcast.Distributor_Account_Name__c != null &&
                fcast.Distributor_Parent_Account__c != null &&
                String.isBlank( fcast.Distributor_Account__c ) &&
                stdUser.Contact.Parent_Account__c.equals( fcast.Distributor_Parent_Account__c ) &&
                (
                    stdUser.Contact.AccountId.equals( fcast.Distributor_Account_Name__c ) || 

                    /* Additional Country Responsibility Sharing */
                    (
                        stdUser.Contact.Additional_Country_Responsibility__c != null &&
                        fcast.Distributor_Account_Name__r.BillingCountry != null &&
                        stdUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase( fcast.Distributor_Account_Name__r.BillingCountry )
                    ) ||

                    /* Related Customer Location Sharing */
                    (   
                        //if current Forecast Accuracy Record is Bucket Record
                        (
                            forecastAccuracyDistributorLocsMap.containsKey( fcast.Parent_Forecast__c ) && 
                            forecastAccuracyDistributorLocsMap.get( fcast.Parent_Forecast__c ).contains( stdUser.Contact.AccountId ) 
                        ) ||

                        //if current Forecast Accuracy Record is Local Stock Record
                        (
                            !String.isBlank( fcast.Forecast_Accuracy_Local_Stock__c ) &&
                            forecastAccuracyDistributorLocsMap.containsKey( fcast.Forecast_Accuracy_Local_Stock__r.Parent_Forecast__c ) && 
                            forecastAccuracyDistributorLocsMap.get( fcast.Forecast_Accuracy_Local_Stock__r.Parent_Forecast__c ).contains( stdUser.Contact.AccountId )
                        )
                    ) ||
                    /* Additional Customer Location Sharing */
                        (   
                            (usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null) &&
                            //if current Forecast Accuracy Record is Bucket Record
                            ((
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(fcast.Distributor_Account_Name__c)
                            ) ||

                            //if current Forecast Accuracy Record is Local Stock Record
                            (
                                !String.isBlank( fcast.Forecast_Accuracy_Local_Stock__c ) &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(fcast.Forecast_Accuracy_Local_Stock__r.Distributor_Account_Name__c)
                            ))
                        )
                )
            )
        );
    }

    /* @Description
        Method Name : isEligibleForManagerUserForecastAccuracySharing( User , Forecast_Accuracy__c )

        This checks whether a Forecast Accuracy record is eligible to be shared with Manager user & does the following things:
            1. Checks if a Forecast Accuracy KPI record's distributor location = Contact's H5
            2. Checks if a Forecast Accuracy KPI record's distributor location's H1 = Contact's H1
        
        @PARAMS
            1. NAME ( currUser )=> TYPE ( User )                    => DESCRIPTION ( Current Manager community user from loop )
            2. NAME ( fcast )   => TYPE ( Forecast_Accuracy__c )    => DESCRIPTION ( Current Forecast Accuracy record from loop )
    */

    private static Boolean isEligibleForManagerUserForecastAccuracySharing( User mngUser, Forecast_Accuracy__c fcast ){

        return mngUser.Contact.AccountId != null &&
            mngUser.Contact.Parent_Account__c != null &&
            (
                /* Account Match Sharing for Master bucket */
                (
                    !String.isBlank( fcast.Distributor_Account__c ) &&
                    (
                        fcast.Distributor_Account__c.equals( mngUser.Contact.AccountId ) ||
                        fcast.Distributor_Account__r.ParentId.equals( mngUser.Contact.Parent_Account__c )
                    )
                )
                ||
                /* Account Match Sharing for all buckets except Master */
                (
                    fcast.Distributor_Parent_Account__c != null &&
                    fcast.Distributor_Account_Name__c != null &&
                    String.isBlank( fcast.Distributor_Account__c ) &&
                    (
                        mngUser.Contact.AccountId.equals( fcast.Distributor_Account_Name__c ) ||
                        mngUser.Contact.Parent_Account__c.equals( fcast.Distributor_Parent_Account__c ) 
                    )
                )
            );
    }

    /* @Description
        Method Name : createForecastAccuracyShareRecord( Id , Id , String , String )

        1. Creates & returns an Forecast_Accuracy__Share instance
        
        @PARAMS
            1. NAME ( userId )      => TYPE ( Id )      => DESCRIPTION ( Current user's Id )
            2. NAME ( fcastId )     => TYPE ( Id )      => DESCRIPTION ( Forecast Accuracy's Id )
            3. NAME ( rowCause )    => TYPE ( String )  => DESCRIPTION ( RowCause )
            4. NAME ( accessLevel ) => TYPE ( String )  => DESCRIPTION ( Access Level )
    */

    private static Forecast_Accuracy__Share createForecastAccuracyShareRecord( Id userId, Id fcastId, String rowCause, String accessLevel ){
        return new Forecast_Accuracy__Share(
            ParentId = fcastId,
            AccessLevel = accessLevel,
            RowCause = rowCause,
            UserOrGroupId = userId
        );
    }

    /* @Description
        Method Name : isRecalculationRequiredToShare( Forecast_Accuracy__c )

        Only shares a Forecast Accuracy if:
            1. It is a bucket record
            2. It is record created by distributor
        This method is used on Forecast Accuracy Insert  
        
        @PARAMS
            1. NAME ( fcast )  => TYPE ( Forecast_Accuracy__c ) => DESCRIPTION ( New Forecast Accuracy from Trigger.New )
    */

    private static Boolean isRecalculationRequiredToShare( Forecast_Accuracy__c fcast ){

        return fcast.RecordTypeId.equals( KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID ) ||
        fcast.RecordTypeId.equals( KPIConstants.LOCAL_STOCK_RECORD_TYPE_ID ) ||
        fcast.RecordTypeId.equals( KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID );
    }

    /* @Description
        Method Name : getForecastAccuracyDistributorLocsMap( List<Other_Related_Customer_Location__c> )

        1. A Forecast Accuracy can be shared with multiple distributors
        2. Once such sharing comes from Related Customer Location object as well.
        3. If a Forecast Accuracy KPI record has multiple Related customer location's record then a Map<Forecast Accuracy Id, List<Distributor Location Id>> is prepared 
        
        @PARAMS
            1. NAME ( relatedCustList ) => TYPE ( List<Other_Related_Customer_Location__c> )    => DESCRIPTION ( Each Forecast Accuracy record can be shared with multiple distributors, this is the map to store that )
    */

    private static Map<Id,List<Id>> getForecastAccuracyDistributorLocsMap( List<Other_Related_Customer_Location__c> relatedCustList ){

        Map<Id,List<Id>> tempMap = new Map<Id,List<Id>>();

        for( Other_Related_Customer_Location__c othRelCust : relatedCustList ){

            if( !tempMap.containsKey( othRelCust.Related_Forecast_Accuracy__c ) ){
                
                tempMap.put( othRelCust.Related_Forecast_Accuracy__c, new List<Id>() );
            }
            tempMap.get( othRelCust.Related_Forecast_Accuracy__c ).add( othRelCust.Distributor_Location__c );
        }

        return tempMap;
    }

    /* @Description
        Method Name : deleteForecastAccuracySharing( Set<Id> , Set<Id> )

        1. Deletes sharing of Forecast Accuracy records for given users and forecast accuracies
        
        @PARAMS
            1. NAME ( userIds )             => TYPE ( Set<Id> ) => DESCRIPTION ( All users considered for Forecast Accuracy sharing deletion )
            1. NAME ( forecastAccuracyIds ) => TYPE ( Set<Id> ) => DESCRIPTION ( All Forecast Accuracies considered for sharing deletion )
    */

    public static void deleteForecastAccuracySharing( Set<Id> userIds, Set<Id> forecastAccuracyIds ){

        delete [SELECT Id FROM Forecast_Accuracy__Share
                WHERE UserOrGroupId IN: userIds
                AND ParentId IN: forecastAccuracyIds
                AND RowCause =: KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE];

    }
    
    public static List<Forecast_Accuracy__c> allForecastAccuraciesRelatedToAccounts(Set<Id> AccountIds){
        return [
            SELECT Id,Distributor_Account__c,Distributor_Account_Name__c,Distributor_Parent_Account__c,RecordTypeId,
            OwnerId, CreatedById
            FROM Forecast_Accuracy__c
            WHERE (RecordTypeId = :KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND Distributor_Account__c != null
                   AND Distributor_Account__c IN: AccountIds)
            OR ((RecordTypeId =: KPIConstants.FORECAST_LOCAL_STOCK_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.LOCAL_STOCK_RECORD_TYPE_ID) AND
                Distributor_Account_Name__c != null AND Distributor_Parent_Account__c != null
                AND Distributor_Account__c = null AND
                (Distributor_Account_Name__c IN: AccountIds OR Distributor_Parent_Account__c IN: AccountIds))
        ];
    }

}