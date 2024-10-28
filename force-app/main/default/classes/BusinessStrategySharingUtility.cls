/*       
@Name           - BusinessStrategySharingUtility
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 12-04-2020

@Description    - This class will share all KPIs related to Business Strategy Object

UserId              | Author-Email                  | Date                  | Comment
====================|===============================|=======================|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 18-05-2020    | Add High & Low Lights, Competition. Moved From Commercial Activity
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 05-02-2021    | Updated class to according to new Account restructure & moving logic from shared Class to its own class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 22-09-2021    | Updated class to accomodate new KPI structure and new arrangement for related distributor locations
*/
public without sharing class BusinessStrategySharingUtility {
    
    /* This method will share Business Strategy
        NOTE : This method will only share Business Strategy records because all the related KPIs are different objects ( shared via their own object's trigger )
    */

    public static void  shareBusinessStrategyWithCommunityUsers( List<Business_Strategy__c> newBusinessStrategies ){
        
        List<Business_Strategy__c> businessStratToRecalculate = new List<Business_Strategy__c>();
        
        for ( Business_Strategy__c businessStrat : newBusinessStrategies ) {
            
            /* Checks if the Business Strategy is valid to be shared */
            if ( isRecalculationRequiredToShare( businessStrat ) ) {
                businessStratToRecalculate.add( businessStrat );
            } 
        }
        
        /* if not Empty, then initiate sharing */
        if( !businessStratToRecalculate.isEmpty() ){
            initiateBusinessStrategySharing( UserUtility.getAllPartnerCommunityUsers(), businessStratToRecalculate );
        }
        
    }

    /* @Description
        Method Name : initiateBusinessStrategySharing( List<User> , List<Business_Strategy__c> )

        This method will separate the Ids to call the future or non - future methods based on the caller function
            1. If it is called from Trigger then future method "createSharingForBusinessStrategyFuture" is called
            2. If it is called from Batch, then no future is called and direct "createSharingForBusinessStrategy" is called.
        
        @PARAMS
            1. NAME ( userList )            => TYPE ( List<User> )                  => DESCRIPTION ( All Partner community users )
            2. NAME ( businessStrategyList )=> TYPE ( List<Business_Strategy__c> )  => DESCRIPTION ( All Business Strategy records considered for re-calculation )
    */

    public static void initiateBusinessStrategySharing( List<User> userList, List<Business_Strategy__c> businessStrategyList ){
        
        Set<Id> usersIds = new Set<Id>();
        for ( User usr : userList ) {
            usersIds.add( usr.Id );
        }
        
        Set<Id> businessStrategyIds = new Set<Id>();
        Set<Id> masterbusinessStrategyIds = new Set<Id>();

        for ( Business_Strategy__c businessStrat : DAOUtilityWithoutShar.getBusinessStrategyForSharing( (new Map<Id, Business_Strategy__c>( businessStrategyList )).keySet() ) ) {
            businessStrategyIds.add( businessStrat.Id );

            /* Added for Related Customer Location Sharing */
            masterbusinessStrategyIds.add( businessStrat.Parent_Business_Strategy__c );
            masterbusinessStrategyIds.add( businessStrat.Business_Strategy_High_Low_Lights__r?.Parent_Business_Strategy__c );
            masterbusinessStrategyIds.add( businessStrat.Business_Strategy_Competition__r?.Parent_Business_Strategy__c );
        }

        masterbusinessStrategyIds.remove( null );

        if( System.isBatch() ){

            createSharingForBusinessStrategy( usersIds, businessStrategyIds, masterbusinessStrategyIds );
        }else{

            createSharingForBusinessStrategyFuture( usersIds, businessStrategyIds, masterbusinessStrategyIds );
        }
    }

    /* @Description
        Method Name : createSharingForBusinessStrategyFuture( Set<Id> , Set<Id> , Set<Id> )

        1. future method to call non-future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )                    => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( businessStrategyIds )         => TYPE ( Set<Id> ) => DESCRIPTION ( All Business Strategy records Ids )
            3. NAME ( masterbusinessStrategyIds )   => TYPE ( Set<Id> ) => DESCRIPTION ( All Business Strategy master Bucket records Ids )
    */

    @future
    public static void createSharingForBusinessStrategyFuture( Set<Id> usersIds, Set<Id> businessStrategyIds, Set<Id> masterbusinessStrategyIds ) {
        createSharingForBusinessStrategy( usersIds, businessStrategyIds, masterbusinessStrategyIds );
    }

    /* @Description
        Method Name : createSharingForBusinessStrategy( Set<Id> , Set<Id> , Set<Id> )

        1. non - future method called from future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )                    => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( businessStrategyIds )         => TYPE ( Set<Id> ) => DESCRIPTION ( All Business Strategy records Ids )
            3. NAME ( masterbusinessStrategyIds )   => TYPE ( Set<Id> ) => DESCRIPTION ( All Business Strategy master Bucket records Ids )
    */

    public static void createSharingForBusinessStrategy( Set<Id> usersIds, Set<Id> businessStrategyIds, Set<Id> masterbusinessStrategyIds ) {
        
        //Query all Users from the userIds
        List<User> users = [SELECT Id, UserName, Contact.Name, Contact.Account.Name, Contact.Additional_Country_Responsibility__c, Contact.Business_Segment__c, Contact.Sub_Segment__c, Contact.Exclude_Customer_Location_Country__c, Community_Account_Role__c, Contact.Parent_Account__c, Contact.Account.BillingCountry, Contact.AccountId, Community_User_Role__c, IsPortalEnabled FROM User WHERE Id IN :usersIds];
        
        //Query all Business Strategy from the businessStrategyIds
        List<Business_Strategy__c> businessStrategyList = DAOUtilityWithoutShar.getBusinessStrategyForSharing( businessStrategyIds );

        //Query all Other Related Customer Location records to share Business Strategy with them
        List<Other_Related_Customer_Location__c> relatedCustList = DAOUtilityWithoutShar.getRelatedCustomerLocationForBusinessStrategy( masterbusinessStrategyIds );

        //Map of <Business Strategy Bucket,List<Related Customer Loc>>
        Map<Id,List<Id>> businessStratDistributorLocsMap = getBusinessStrategyDistributorLocsMap( relatedCustList );
        
        //Map of UserIds with Additional Customer Locations added at contact Level - ENH-4815
        Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(users);
        
        List<Business_Strategy__Share> businessStrategyShares = new List<Business_Strategy__Share>();
        for ( Business_Strategy__c businessStrat : businessStrategyList ) {
            
            for ( User currUser : users ) {        
                
                //Skip sharing if user already owns the BusinessStrategy.
                if ( businessStrat.OwnerId.equals( currUser.Id ) ) {
                    continue;
                }
                
                Business_Strategy__Share businessStrategyShare;
                
                /* Checks if current user is standard user and initiates sharing for it or else initiate sharing for Manager user */
                if ( UserUtility.isUserStandardCommunityUser( currUser ) ) {
                    businessStrategyShare = createSharingForStandardUser( currUser, businessStrat, businessStratDistributorLocsMap, usersWithAddCustLocsMap );
                } else {
                    businessStrategyShare = createSharingForManagerUser( currUser, businessStrat );
                }
                
                if ( businessStrategyShare == null ) {
                    continue;
                }
                
                if( !businessStrategyShares.contains( businessStrategyShare ) ){
                    businessStrategyShares.add( businessStrategyShare );
                }   
            }
        }
        DAOUtilityWithoutShar.insertWithoutAccess( businessStrategyShares );
    }

    /* @Description
        Method Name : createSharingForStandardUser( User , Business_Strategy__c , Map<Id,List<Id>> )

        1. non - future method called from future to start sharing
        2. This is for standard community user
        
        @PARAMS
            1. NAME ( currUser )                        => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( businessStrat )                   => TYPE ( Business_Strategy__c )    => DESCRIPTION ( Current Business Strategy record from loop )
            3. NAME ( businessStratDistributorLocsMap ) => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each Business Strategy record can be shared with multiple distributors, this is the map to store that )
    */

    private static Business_Strategy__Share createSharingForStandardUser(
        User currUser,
        Business_Strategy__c businessStrat,
        Map<Id,List<Id>> businessStratDistributorLocsMap,
    	Map<Id, Set<Id>> usersWithAddCustLocsMap){
        
        /* This part does the check for Business Strategy Sharing and gives Read or Read/Write depending upon
            1. If a bucket is shared, then it is read Only , included record types: 
                a. KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID
                b. KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID
                c. KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID

            2. If created by distributor then it is Read/Write, included Record Types:
                a. KPIConstants.HIGH_LOW_LIGHT_RECORD_TYPE_ID
                b. KPIConstants.COMPETITION_RECORD_TYPE_ID
        */
        
        if( isEligibleForStandardUserBusinessStrategySharing( currUser, businessStrat, businessStratDistributorLocsMap, usersWithAddCustLocsMap ) ){
            
            return createBusinessStrategyShareRecord(

                currUser.Id, 
                businessStrat.Id,
                KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE,
                isBusinessStrategyBucket( businessStrat ) ? 'READ' : 'EDIT'
            );
        }
        
        return null;
    }

    /* Code to create Sharing for Manager users */
    private static Business_Strategy__Share createSharingForManagerUser(
        User currUser,
        Business_Strategy__c businessStrat){

            /* This part does the check for Business Strategy Sharing and gives Read or Read/Write depending upon
            1. If a bucket is shared, then it is read Only , included record types: 
                a. KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID
                b. KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID
                c. KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID

            2. If created by distributor then it is Read/Write, included Record Types:
                a. KPIConstants.HIGH_LOW_LIGHT_RECORD_TYPE_ID
                b. KPIConstants.COMPETITION_RECORD_TYPE_ID
        */

            if( isEligibleForManagerUserBusinessStrategySharing( currUser, businessStrat ) ){
				system.debug('line 219');
                return createBusinessStrategyShareRecord(

                    currUser.Id, 
                    businessStrat.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE,
                    isBusinessStrategyBucket( businessStrat ) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    /* Share the bucket records with Read Only access to Community users or else it will be EDIT access */
    private static Boolean isBusinessStrategyBucket( Business_Strategy__c businessStrat ){

        return businessStrat.RecordTypeId.equals( KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID ) || 
            businessStrat.RecordTypeId.equals( KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID ) ||
            businessStrat.RecordTypeId.equals( KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID );
    }

    /* @Description
        Method Name : isEligibleForStandardUserBusinessStrategySharing( User , Business_Strategy__c , Map<Id,List<Id>> )

        This checks whether a Business Strategy record is eligible to be shared with standard user & does the following things:
            1. Checks if a Business Strategy KPI record's distributor location = Contact's H5
            2. Checks if a Business Strategy KPI record's distributor location's country = one of the contact's additional Countries
            3. Checks if a Business Strategy KPI record's Related Customer location's distributor location = Contact's H5
        
        @PARAMS
            1. NAME ( currUser )                        => TYPE ( User )                    => DESCRIPTION ( Current standard community user from loop )
            2. NAME ( businessStrat )                   => TYPE ( Business_Strategy__c )    => DESCRIPTION ( Current Business Strategy record from loop )
            3. NAME ( businessStratDistributorLocsMap ) => TYPE ( Map<Id,List<Id>> )        => DESCRIPTION ( Each Business Strategy record can be shared with multiple distributors, this is the map to store that )
    */

    private static Boolean isEligibleForStandardUserBusinessStrategySharing( User stdUser,  Business_Strategy__c businessStrat, Map<Id,List<Id>> businessStratDistributorLocsMap, Map<Id, Set<Id>> usersWithAddCustLocsMap){
		system.debug('usersWithAddCustLocsMap >>> '+usersWithAddCustLocsMap);
        if(businessStrat.Business_Strategy_High_Low_Lights__c != null && 
           businessStrat.Business_Strategy_High_Low_Lights__r.Distributor_Account_Name__c != null){
               system.debug('busStrHighLowLightsDistiAccName >>> '+businessStrat.Business_Strategy_High_Low_Lights__r.Distributor_Account_Name__c);
           }
        return stdUser.Contact.AccountId != null &&
            stdUser.Contact.Parent_Account__c != null &&
            (  
                /* Account Match Sharing for Master */
                (
                    !String.isBlank( businessStrat.Distributor_Account__c ) &&
                    ( 
                        /* Account Match Sharing for Master Bucket */
                        businessStrat.Distributor_Account__c.equals( stdUser.Contact.AccountId ) 
                        ||
                        /* Account Match Sharing for Master Bucket for related distributor locations */
                        ( 
                            businessStratDistributorLocsMap.containsKey( businessStrat.Id ) && 
                            businessStratDistributorLocsMap.get( businessStrat.Id ).contains( stdUser.Contact.AccountId )
                        )
                        ||
                        /* Account Match Sharing for Master Bucket for additional customer locations */
                        (
                        	usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null &&
                            usersWithAddCustLocsMap.get(stdUser.Id).contains(businessStrat.Distributor_Account__c)
                        )
                    )
                )
                ||
                /* Account Match Sharing for all buckets except Master */
                (
                    businessStrat.Distributor_Account_Name__c != null &&
                    businessStrat.Distributor_Parent_Account__c != null &&
                    stdUser.Contact.Parent_Account__c.equals( businessStrat.Distributor_Parent_Account__c ) &&
                    String.isBlank( businessStrat.Distributor_Account__c ) &&
                    (
                        stdUser.Contact.AccountId.equals( businessStrat.Distributor_Account_Name__c ) || 

                        /* Additional Country Responsibility Sharing */
                        (
                            stdUser.Contact.Additional_Country_Responsibility__c != null && businessStrat.Distributor_Parent_Account__c != null &&
                            businessStrat.Distributor_Account_Name__r.BillingCountry != null &&
                            stdUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase( businessStrat.Distributor_Account_Name__r.BillingCountry )
                        ) ||

                        /* Related Customer Location Sharing */
                        (   
                            //if current Business Strategy Record is Bucket Record
                            (
                                businessStratDistributorLocsMap.containsKey( businessStrat.Parent_Business_Strategy__c ) && 
                                businessStratDistributorLocsMap.get( businessStrat.Parent_Business_Strategy__c ).contains( stdUser.Contact.AccountId ) ) ||

                            //if current Business Strategy Record is Competition Record
                            (
                                !String.isBlank( businessStrat.Business_Strategy_Competition__c ) &&
                                businessStratDistributorLocsMap.containsKey( businessStrat.Business_Strategy_Competition__r.Parent_Business_Strategy__c ) && 
                                businessStratDistributorLocsMap.get( businessStrat.Business_Strategy_Competition__r.Parent_Business_Strategy__c ).contains( stdUser.Contact.AccountId )
                            ) ||

                            //if current Business Strategy Record is High & Low Lights Record
                            (
                                !String.isBlank( businessStrat.Business_Strategy_High_Low_Lights__c ) &&
                                businessStratDistributorLocsMap.containsKey( businessStrat.Business_Strategy_High_Low_Lights__r.Parent_Business_Strategy__c ) && 
                                businessStratDistributorLocsMap.get( businessStrat.Business_Strategy_High_Low_Lights__r.Parent_Business_Strategy__c ).contains( stdUser.Contact.AccountId )
                            )
                        ) ||
                        
                        /* Additional Customer Location Sharing */
                        (   
                            (usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                            usersWithAddCustLocsMap.get(stdUser.Id) != null) &&
                            //if current Business Strategy Record is Bucket Record
                            ((
                                businessStrat.Distributor_Account_Name__c != null &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(businessStrat.Distributor_Account_Name__c)
                            ) ||

                            //if current Business Strategy Record is Competition Record
                            (
                                !String.isBlank( businessStrat.Business_Strategy_Competition__c ) &&
                                businessStrat.Business_Strategy_Competition__r.Distributor_Account_Name__c != null &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(businessStrat.Business_Strategy_Competition__r.Distributor_Account_Name__c)
                            ) ||

                            //if current Business Strategy Record is High & Low Lights Record
                            (
                                !String.isBlank( businessStrat.Business_Strategy_High_Low_Lights__c ) &&
                                businessStrat.Business_Strategy_High_Low_Lights__r.Distributor_Account_Name__c != null &&
                                usersWithAddCustLocsMap.get(stdUser.Id).contains(businessStrat.Business_Strategy_High_Low_Lights__r.Distributor_Account_Name__c)
                            ))
                        )
                    )
                    /*(
                        businessStratDistributorLocsMap.containsKey(businessStrat.Id) || 
                        businessStratDistributorLocsMap.containsKey(businessStrat.Business_Strategy_Competition__c) ||
                        businessStratDistributorLocsMap.containsKey(businessStrat.Business_Strategy_High_Low_Lights__c)
                    ) 
                    &&*/
                )
            );
    }

    /* @Description
        Method Name : isEligibleForManagerUserBusinessStrategySharing( User , Business_Strategy__c )

        This checks whether a Business Strategy record is eligible to be shared with Manager user & does the following things:
            1. Checks if a Business Strategy KPI record's distributor location = Contact's H5
            2. Checks if a Business Strategy KPI record's distributor location's H1 = Contact's H1
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )                 => DESCRIPTION ( Current Manager community user from loop )
            2. NAME ( fciCustSupp ) => TYPE ( Business_Strategy__c ) => DESCRIPTION ( Current Business Strategy record from loop )
    */

    private static Boolean isEligibleForManagerUserBusinessStrategySharing( User mngUser,  Business_Strategy__c businessStrat ){

        return mngUser.Contact.AccountId != null &&
            mngUser.Contact.Parent_Account__c != null &&
            (
                /* Account Match Sharing for Master bucket */
                (
                    !String.isBlank( businessStrat.Distributor_Account__c ) &&
                    !String.isBlank( businessStrat.Distributor_Account__r.ParentId ) &&
                    
                    (
                        businessStrat.Distributor_Account__c.equals( mngUser.Contact.AccountId ) ||
                        businessStrat.Distributor_Account__r.ParentId.equals( mngUser.Contact.Parent_Account__c )
                    )
                )
                ||
                /* Account Match Sharing for all buckets except Master */
                ( 
                    businessStrat.Distributor_Parent_Account__c != null &&
                    businessStrat.Distributor_Account_Name__c != null &&
                    String.isBlank( businessStrat.Distributor_Account__c ) &&
                    (
                        mngUser.Contact.AccountId.equals( businessStrat.Distributor_Account_Name__c ) ||
                        mngUser.Contact.Parent_Account__c.equals( businessStrat.Distributor_Parent_Account__c )
                    )
                )
            );
    }

    /* @Description
        Method Name : createFCICustomerSupportShareRecord( Id , Id , String , String )

        1. Creates & returns an FCI_Customer_Support__Share instance
        
        @PARAMS
            1. NAME ( userId )          => TYPE ( Id )      => DESCRIPTION ( Current user's Id )
            2. NAME ( businessStratId ) => TYPE ( Id )      => DESCRIPTION ( Business Strategy's Id )
            3. NAME ( rowCause )        => TYPE ( String )  => DESCRIPTION ( RowCause )
            4. NAME ( accessLevel )     => TYPE ( String )  => DESCRIPTION ( Access Level )
    */

    private static Business_Strategy__Share createBusinessStrategyShareRecord( Id userId, Id businessStratId, String rowCause, String accessLevel ){
        return new Business_Strategy__Share(
            ParentId = businessStratId,
            AccessLevel = accessLevel,
            RowCause = rowCause,
            UserOrGroupId = userId
        );
    }

    /* @Description
        Method Name : isRecalculationRequiredToShare( Business_Strategy__c )

        Only shares a Business Strategy if:
            1. It is a bucket record
            2. It is record created by distributor
        This method is used on Business Strategy Insert  
        
        @PARAMS
            1. NAME ( businessStrat )  => TYPE ( Business_Strategy__c ) => DESCRIPTION ( New Business Strategy from Trigger.New )
    */
    
    private static Boolean isRecalculationRequiredToShare( Business_Strategy__c businessStrat ){
        
        return businessStrat.RecordTypeId.equals( KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID ) ||
            businessStrat.RecordTypeId.equals( KPIConstants.HIGH_LOW_LIGHT_RECORD_TYPE_ID ) ||
            businessStrat.RecordTypeId.equals( KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID ) ||
            businessStrat.RecordTypeId.equals( KPIConstants.COMPETITION_RECORD_TYPE_ID ) ||
            businessStrat.RecordTypeId.equals( KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID ) ||
            businessStrat.RecordTypeId.equals( KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID );
    }

    /* @Description
        Method Name : getBusinessStrategyDistributorLocsMap( List<Other_Related_Customer_Location__c> )

        1. A Business Strategy can be shared with multiple distributors
        2. Once such sharing comes from Related Customer Location object as well.
        3. If a Business Strategy KPI record has multiple Related customer location's record then a Map<Business Strategy Id, List<Distributor Location Id>> is prepared 
        
        @PARAMS
            1. NAME ( relatedCustList ) => TYPE ( List<Other_Related_Customer_Location__c> )    => DESCRIPTION ( Each Business Strategy record can be shared with multiple distributors, this is the map to store that )
    */

    private static Map<Id,List<Id>> getBusinessStrategyDistributorLocsMap( List<Other_Related_Customer_Location__c> relatedCustList ){

        Map<Id,List<Id>> tempMap = new Map<Id,List<Id>>();

        for( Other_Related_Customer_Location__c othRelCust : relatedCustList ){

            if( !tempMap.containsKey(othRelCust.Related_Business_Strategy__c ) ){
                
                tempMap.put( othRelCust.Related_Business_Strategy__c, new List<Id>() );
            }
            tempMap.get( othRelCust.Related_Business_Strategy__c ).add(othRelCust.Distributor_Location__c );
        }

        return tempMap;
    }

    /* @Description
        Method Name : deleteBusinessStrategySharing( Set<Id> , Set<Id> )

        1. Deletes sharing of Business Strategy records for given users and Business Strategies
        
        @PARAMS
            1. NAME ( userIds )             => TYPE ( Set<Id> ) => DESCRIPTION ( All users considered for Business Strategy sharing deletion )
            1. NAME ( businessStrategyIds ) => TYPE ( Set<Id> ) => DESCRIPTION ( All Business Strategies considered for sharing deletion )
    */

    public static void deleteBusinessStrategySharing( Set<Id> userIds, Set<Id> businessStrategyIds ){

        delete [SELECT Id FROM Business_Strategy__Share
                WHERE UserOrGroupId IN: userIds
                AND ParentId IN: businessStrategyIds
                AND RowCause =: KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE];

    }

    /* This method will share Competitor records if it is created for existing account plans */

    /* This method will be used to share all the Competitor Records associated with Account plan records on Account Plan Create/RelatedCustomerCreate
        This is used here because Business Strategy object is used to store Account plans Competitor Informations ( having a separate record type)*/
    

    /* Delete All Sharing Record for Business Strategy Records */
    
    /* Delete Business Strategy sharing records on delete of Related Customer Locations */
    /*format "UserId - BusinessStrategyId" */
    /*public static void deleteBusinessStrategySharingOnRelatedCustomerLocDelete(List<String> userBusinessStrategyIdList,Set<Id> communityUserIds,Set<Id> businessStrategyIds){

        List<Business_Strategy__Share> businessStrategyShareDeleteList = new List<Business_Strategy__Share>();
        for(Business_Strategy__Share eachBusinessStrategyShare : [SELECT Id,UserOrGroupId,ParentId FROM Business_Strategy__Share 
                                                        WHERE UserOrGroupId IN: communityUserIds
                                                        AND ParentId IN: businessStrategyIds
                                                        AND RowCause =: CommunityKPISharingConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE]){
            
            if(userBusinessStrategyIdList.contains(eachBusinessStrategyShare.UserOrGroupId + '-' + eachBusinessStrategyShare.ParentId)){
                businessStrategyShareDeleteList.add(eachBusinessStrategyShare);
            }
        }

        if(!businessStrategyShareDeleteList.isEmpty()){
            delete businessStrategyShareDeleteList;
        }
    }*/

    /* Filter Business Strategies Based on the contact update */

    /* This is to share all Business Strategy records when an other related location is added to the bucket 
        There are 3 types of record sharing that will happen here
        1.  The other Related Location record should be shared with the new distributor
        2.  The bucket should be shared with the new distributor
        3.  The actual KPI records created by Distributors should be shared with new distributor
		4. 	This is only for High & Low Lights and Competitions as account plans have different sharing
    */

    //@future
    /*public static void deleteBusinessStratShareOnRelCustLocDelete(Set<Id> otherRelCustLocIds){

        Set<Id> accIdsToDelete = new Set<Id>();
        Set<Id> businessStratBucketIds = new Set<Id>();
        List<Business_Strategy__c> businessStratIdsToDelete = new List<Business_Strategy__c>();

        for(Other_Related_Customer_Location__c eachOtherRelLoc : [SELECT Id,
                                                                Related_Business_Strategy__c,
                                                                Distributor_Location__c
                                                                FROM Other_Related_Customer_Location__c 
                                                                WHERE Id IN: otherRelCustLocIds]){

            if(eachOtherRelLoc.Related_Business_Strategy__c != null)  businessStratBucketIds.add(eachOtherRelLoc.Related_Business_Strategy__c);
            if(eachOtherRelLoc.Distributor_Location__c != null)         accIdsToDelete.add(eachOtherRelLoc.Distributor_Location__c); 
        }

        for(Business_Strategy__c eachBusinessStrat : [SELECT Id
                                                FROM Business_Strategy__c 
                                                WHERE (Business_Strategy_High_Low_Lights__c IN: businessStratBucketIds
                                                OR Business_Strategy_Competition__c IN: businessStratBucketIds
                                                OR Id IN: businessStratBucketIds)]){
                
            businessStratIdsToDelete.add(eachBusinessStrat);
        }

        if(!accIdsToDelete.isEmpty() && !businessStratIdsToDelete.isEmpty()){

            deleteBusinessStrategySharing(businessStratIdsToDelete, UserUtility.getCommunityUsersByAccountIds(accIdsToDelete).values());
        }
    }*/
    
    public static List<Business_Strategy__c> allBusinessStrategiesRelatedToAccounts(Set<Id> AccountIds){
        return [
            SELECT Id,Distributor_Account__c,Distributor_Account_Name__c,Distributor_Parent_Account__c,RecordTypeId,
            OwnerId, CreatedById
            FROM Business_Strategy__c
            WHERE (RecordTypeId = :KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND Distributor_Account__c != null
                   AND Distributor_Account__c IN: AccountIds)
            OR ((RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.HIGH_LOW_LIGHT_RECORD_TYPE_ID OR
                 RecordTypeId =: KPIConstants.COMPETITION_RECORD_TYPE_ID) AND
                Distributor_Account_Name__c != null AND Distributor_Parent_Account__c != null
                AND Distributor_Account__c = null AND
                (Distributor_Account_Name__c IN: AccountIds OR Distributor_Parent_Account__c IN: AccountIds))
        ];
    }
}