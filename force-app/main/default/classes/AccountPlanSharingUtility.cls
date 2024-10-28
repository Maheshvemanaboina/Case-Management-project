/*
    Author : Sibananda Bhuyan 16-04-2020
    Description : This class will share all KPIs for Account Plan Object
    08-02-2021  : Updated class to according to new Account restructure & moving logic from shared Class to its own class
*/
public without sharing class AccountPlanSharingUtility {
    
    /* 
        This method will share Account Plans of Record Types:
            1. Distributor Account Plan
        Shared Account Plans are not shared as it will is shared using a standard Sharing rule with all Community Users.
        As these are present under a bucket. So once a bucket is shared, Distributors will have the visibility of shared account plan.
    */

    public static void  shareAccountPlanWithCommunityUsers( List<Field_of_Play__c> newAccountPlans ){
        
        List<Field_of_Play__c> accountPlansToRecalculate = new List<Field_of_Play__c>();
        
        for ( Field_of_Play__c accountPlan : newAccountPlans ) {
            
            /* Checks if the Account Plan is valid to be shared */
            if ( isRecalculationRequiredToShare( accountPlan ) ) {
                accountPlansToRecalculate.add( accountPlan );
            } 
        }
        
        /* if not Empty, then initiate sharing */
        if( !accountPlansToRecalculate.isEmpty() ){
            initiateAccountPlanSharing( UserUtility.getAllPartnerCommunityUsers(), accountPlansToRecalculate );
        }
        
    }

    /* @Description
        Method Name : initiateAccountPlanSharing( List<User> , List<Field_of_Play__c> )

        This method will separate the Ids to call the future or non - future methods based on the caller function
            1. If it is called from Trigger then future method "createSharingForAccountPlanFuture" is called
            2. If it is called from Batch, then no future is called and direct "createSharingForAccountPlan" is called.
        
        @PARAMS
            1. NAME ( userList )        => TYPE ( List<User> )              => DESCRIPTION ( All Partner community users )
            2. NAME ( accountPlanList ) => TYPE ( List<Field_of_Play__c> )  => DESCRIPTION ( All Account Plan records considered for re-calculation )
    */

    public static void initiateAccountPlanSharing( List<User> userList, List<Field_of_Play__c> accountPlanList ){
        
        Set<Id> usersIds = new Set<Id>();
        for ( User usr : userList ) {
            usersIds.add( usr.Id );
        }
        
        Set<Id> accountPlanIds = new Set<Id>();

        for ( Field_of_Play__c accountPlan : accountPlanList ) {
            accountPlanIds.add( accountPlan.Id );
        }
        
        if( System.isBatch() ){
 
            createSharingForAccountPlan( usersIds, accountPlanIds );
        }else{

            createSharingForAccountPlanFuture( usersIds, accountPlanIds );
        }
    }

    /* @Description
        Method Name : createSharingForAccountPlanFuture( Set<Id> , Set<Id> )

        1. future method to call non-future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )        => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( accountPlanIds )  => TYPE ( Set<Id> ) => DESCRIPTION ( All Account Plan records Ids )
    */

    @future
    public static void createSharingForAccountPlanFuture( Set<Id> usersIds, Set<Id> accountPlanIds ) {
        createSharingForAccountPlan( usersIds, accountPlanIds );
    }

    /* @Description
        Method Name : createSharingForAccountPlan( Set<Id> , Set<Id> )

        1. non - future method called from future to start sharing
        
        @PARAMS
            1. NAME ( usersIds )        => TYPE ( Set<Id> ) => DESCRIPTION ( All Partner community user Ids )
            2. NAME ( accountPlanIds )  => TYPE ( Set<Id> ) => DESCRIPTION ( All Account Plan records Ids )
    */

    public static void createSharingForAccountPlan( Set<Id> usersIds, Set<Id> accountPlanIds ) {
        
        //Query all Users from the userIds
        List<User> users = [SELECT Id, UserName, Contact.Name, Contact.Account.Name, Contact.Additional_Country_Responsibility__c, Contact.Business_Segment__c, Contact.Sub_Segment__c, Contact.Exclude_Customer_Location_Country__c, Community_Account_Role__c, Contact.Parent_Account__c, Contact.Account.BillingCountry, Contact.AccountId, Community_User_Role__c, IsPortalEnabled FROM User WHERE Id IN :usersIds];
        
        //Query all Account Plans from the accountPlanIds
        List<Field_of_Play__c> accountPlanList = DAOUtilityWithoutShar.getAccountPlansForSharing( accountPlanIds );

        //Query all Other Related Customer Location records to share Account Plans with them
        List<Other_Related_Customer_Location__c> relatedCustList = DAOUtilityWithoutShar.getRelatedCustomerLocationForAccountPlans( accountPlanIds );

        //Map of <Account Plan,List<Related Customer Loc>>
        Map<Id,List<Id>> accountPlanDistributorLocsMap = getAccountPlanDistributorLocsMap( relatedCustList );
        
        //Map of UserIds with Additional Customer Locations added at contact Level - ENH-4815
        Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(users);
        
        List<Field_of_Play__Share> accountPlanShares = new List<Field_of_Play__Share>();
        for ( Field_of_Play__c accountPlan : accountPlanList ) {
            
            for ( User currUser : users ) {        
                
                //Skip sharing if user already owns the BusinessStrategy.
                if ( accountPlan.OwnerId.equals( currUser.Id ) ) {
                    continue;
                }
                
                Field_of_Play__Share accountPlanShare;
                
                /* Checks if current user is standard user and initiates sharing for it or else initiate sharing for Manager user */
                if ( UserUtility.isUserStandardCommunityUser( currUser ) ) {
                    accountPlanShare = createSharingForStandardUser( currUser, accountPlan, accountPlanDistributorLocsMap, usersWithAddCustLocsMap );
                } else {
                    accountPlanShare = createSharingForManagerUser( currUser, accountPlan );
                }
                
                if ( accountPlanShare == null ) {
                    continue;
                }
                
                if( !accountPlanShares.contains( accountPlanShare ) ){
                    accountPlanShares.add( accountPlanShare );
                }   
            }
        }
        DAOUtilityWithoutShar.insertWithoutAccess( accountPlanShares );
    }

    /* Code to create Sharing for Standard users */
    private static Field_of_Play__Share createSharingForStandardUser(
        User currUser,
        Field_of_Play__c accountPlan,
        Map<Id,List<Id>> accountPlanDistributorLocsMap,
        Map<Id, Set<Id>> usersWithAddCustLocsMap
    ){
        
        /* This part does the check for Account Plan Sharing and gives Read/Write only as this is a standalone object 
                and buckets are referenced in Business Strategy Object. Record Types to be checked:
                1. If a bucket is shared, then it is read Only , included record types: 
                    a. KPIConstants.DISTRIBUTOR_ACCOUNT_PLAN
        */
        
        if( isEligibleForStandardUserAccountPlanSharing( currUser, accountPlan, accountPlanDistributorLocsMap, usersWithAddCustLocsMap ) ){
            
            return createAccountPlanShareRecord(

                currUser.Id, 
                accountPlan.Id,
                KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE,
                accountPlan.RecordTypeId.equals( KPIConstants.DISTRIBUTOR_SHARED_ACCOUNT_PLAN ) ? 'READ' : 'EDIT'
            );
        }
        
        return null;
    }

    /* Code to create Sharing for Manager users */
    private static Field_of_Play__Share createSharingForManagerUser(
        User currUser,
        Field_of_Play__c accountPlan){

            /* This part does the check for Account Plan Sharing and gives Read/Write only as this is a standalone object 
                and buckets are referenced in Business Strategy Object. Record Types to be checked:
                1. If a bucket is shared, then it is read Only , included record types: 
                    a. KPIConstants.DISTRIBUTOR_ACCOUNT_PLAN
            */

            if(isEligibleForManagerUserAccountPlanSharing(currUser, accountPlan)){

                return createAccountPlanShareRecord(

                    currUser.Id, 
                    accountPlan.Id,
                    KPIConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE,
                    accountPlan.RecordTypeId.equals(KPIConstants.DISTRIBUTOR_SHARED_ACCOUNT_PLAN) ? 'READ' : 'EDIT'
                );
            }

            return null;
    }

    private static Boolean isEligibleForStandardUserAccountPlanSharing( User stdUser, Field_of_Play__c accountPlan, Map<Id,List<Id>> accountPlanDistributorLocsMap, Map<Id, Set<Id>> usersWithAddCustLocsMap ){
        
        return stdUser.Contact.AccountId != null &&
            stdUser.Contact.Parent_Account__c != null &&
            accountPlan.Distributor_Business_Strategy__c != null &&
            accountPlan.Distributor_Business_Strategy__r.Distributor_Account_Name__c != null &&
            accountPlan.Distributor_Business_Strategy__r.Distributor_Parent_Account__c != null &&
            stdUser.Contact.Parent_Account__c.equals( accountPlan.Distributor_Business_Strategy__r.Distributor_Parent_Account__c ) &&

            (
                /* Account Match Sharing */
                stdUser.Contact.AccountId.equals( accountPlan.Distributor_Business_Strategy__r.Distributor_Account_Name__c ) || 

                /* Additional Country Responsibility Sharing */
                (
                    stdUser.Contact.Additional_Country_Responsibility__c != null &&
                    accountPlan.Distributor_Business_Strategy__r.Distributor_Account_Name__r.BillingCountry != null &&
                    stdUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase( accountPlan.Distributor_Business_Strategy__r.Distributor_Account_Name__r.BillingCountry )
                ) ||

                /* Related Customer Location Sharing */
                (   
                    //if current Account Plan Record is Account Plan Record
                    accountPlanDistributorLocsMap.containsKey( accountPlan.Id ) && 
                    accountPlanDistributorLocsMap.get( accountPlan.Id ).contains( stdUser.Contact.AccountId )
                ) ||
                
                /* Additional Customer Location Sharing */
                (   
                    //if current Account Plan Record is Account Plan Record
                    usersWithAddCustLocsMap.containsKey(stdUser.Id) &&
                    usersWithAddCustLocsMap.get(stdUser.Id) != null &&
                    usersWithAddCustLocsMap.get(stdUser.Id).contains(accountPlan.Distributor_Business_Strategy__r.Distributor_Account_Name__c)
                )
            );
    }

    private static Boolean isEligibleForManagerUserAccountPlanSharing( User mngUser, Field_of_Play__c accountPlan ){

        return mngUser.Contact.AccountId != null &&
            mngUser.Contact.Parent_Account__c != null &&
            accountPlan.Distributor_Business_Strategy__c != null &&
            accountPlan.Distributor_Business_Strategy__r.Distributor_Account_Name__c != null &&
            accountPlan.Distributor_Business_Strategy__r.Distributor_Parent_Account__c != null &&
            /* Account Match Sharing */
            (
                mngUser.Contact.AccountId.equals( accountPlan.Distributor_Business_Strategy__r.Distributor_Account_Name__c ) ||
                mngUser.Contact.Parent_Account__c.equals( accountPlan.Distributor_Business_Strategy__r.Distributor_Parent_Account__c )
            );
    }

    private static Field_of_Play__Share createAccountPlanShareRecord(Id userId, Id accountPlanId, String rowCause, String accessLevel){
        return new Field_of_Play__Share(
            ParentId = accountPlanId,
            AccessLevel = accessLevel,
            RowCause = rowCause,
            UserOrGroupId = userId
        );
    }

    /* @Description
        Method Name : isRecalculationRequiredToShare( Field_of_Play__c )

        Only shares a Account Plan if it is created by Distributor
        This method is used on Account Plan Insert  
        
        @PARAMS
            1. NAME ( accountPlan )  => TYPE ( Field_of_Play__c ) => DESCRIPTION ( New Account Plan from Trigger.New )
    */

    private static Boolean isRecalculationRequiredToShare( Field_of_Play__c accountPlan ){
        
        return accountPlan.RecordTypeId.equals( KPIConstants.DISTRIBUTOR_ACCOUNT_PLAN );
    }

    private static Map<Id,List<Id>> getAccountPlanDistributorLocsMap( List<Other_Related_Customer_Location__c> relatedCustList ){

        Map<Id,List<Id>> tempMap = new Map<Id,List<Id>>();

        for( Other_Related_Customer_Location__c othRelCust : relatedCustList ){

            if( !tempMap.containsKey( othRelCust.Account_Plan__c ) ){
                
                tempMap.put( othRelCust.Account_Plan__c, new List<Id>() );
            }
            tempMap.get( othRelCust.Account_Plan__c ).add( othRelCust.Distributor_Location__c );
        }

        return tempMap;
    }

    /* Creates Shared Account Plan records on buckets of other distributors Business Strategies */
    public static void createSharedAccountPlanRecordsfromRelatedCustLocs( Map<Id,List<String>> custLocAccountPlans, Map<Id,List<String>> custLocFiscalYears ){

        //Builds a Map of Business Strategy bucket records, List<Account Plan Id>
        Map<Id,List<String>> businessStAccPlanListMap = new Map<Id,List<String>>();
        for(Business_Strategy__c eachBusinessSt : [SELECT Id, Fiscal_Year_FY__c, Parent_Business_Strategy__r.Distributor_Account__c 
                                                    FROM Business_Strategy__c
                                                    WHERE Parent_Business_Strategy__c != null
                                                    AND Parent_Business_Strategy__r.Distributor_Account__c IN: custLocAccountPlans.keySet()]){
            
            if( custLocFiscalYears.get( eachBusinessSt.Parent_Business_Strategy__r.Distributor_Account__c ).contains( eachBusinessSt.Fiscal_Year_FY__c ) ){

                businessStAccPlanListMap.put( eachBusinessSt.Id, custLocAccountPlans.get( eachBusinessSt.Parent_Business_Strategy__r.Distributor_Account__c ) );
            }
        }

        //Prepares the actual Shared Account plans to be inserted
        List<Field_of_Play__c> accSharePlanRecordsToInsert = new List<Field_of_Play__c>();
        if( !businessStAccPlanListMap.isEmpty() ){

            for( Id businessStId : businessStAccPlanListMap.keySet() ){

                for( String accPlanId : businessStAccPlanListMap.get( businessStId ) ){

                    Field_of_Play__c accplanShare = new Field_of_Play__c( 
                        RecordTypeId = KPIConstants.DISTRIBUTOR_SHARED_ACCOUNT_PLAN,
                        Shared_Business_Strategy__c = businessStId,
                        Shared_Account_Plan__c = accPlanId
                    );

                    accSharePlanRecordsToInsert.add( accplanShare );
                }
            }
        }

        if( !accSharePlanRecordsToInsert.isEmpty() ){
            insert accSharePlanRecordsToInsert;
        }
    }

    public static void deleteAccountPlanSharing(Set<Id> userIds, Set<Id> accountPlanIds){

        delete [SELECT Id FROM Field_of_Play__Share
                WHERE UserOrGroupId IN: userIds
                AND ParentId IN: accountPlanIds
                AND RowCause =: KPIConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE];

    }

    public static void deleteSharedAccountPlans(Set<Id> accountPlanIds){

        delete [SELECT Id FROM Field_of_Play__c
                WHERE Id IN: accountPlanIds
                AND RecordTypeId =: KPIConstants.DISTRIBUTOR_SHARED_ACCOUNT_PLAN];
    }

    /* Delete Account Plan sharing records on delete of Related Customer Locations */
    /*format "UserId - AccountPlanId" */
    /*public static void deleteAccountPlanSharingOnRelatedCustomerLocDelete(List<String> userAccountPlanIdList,Set<Id> communityUserIds,Set<Id> accountPlanIds){

        List<Field_of_Play__Share> accountPlanShareDeleteList = new List<Field_of_Play__Share>();
        //Query all the existing Account Plan Share Record for given CommunityUserIds and AccountPlanIds
        for(Field_of_Play__share eachAccountPlanShare : [SELECT Id,UserOrGroupId,ParentId FROM Field_of_Play__share 
                                                        WHERE UserOrGroupId IN: communityUserIds
                                                        AND ParentId IN: accountPlanIds
                                                        AND RowCause =: CommunityKPISharingConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE
                                                        AND Parent.RecordTypeId =: KPIConstants.DISTRIBUTOR_ACCOUNT_PLAN]){
            
            if(userAccountPlanIdList.contains(eachAccountPlanShare.UserOrGroupId + '-' + eachAccountPlanShare.ParentId)){
                accountPlanShareDeleteList.add(eachAccountPlanShare);
            }
        }

        if(!accountPlanShareDeleteList.isEmpty()){
            delete accountPlanShareDeleteList;
        }
    }*/

    /* Shares the Account Plan Records with the Distributor Locations present in Other Related Customer Location records
    public static void shareAccountPlanWithRelatedCustomerLocations(Set<Id> accountPlanIds){

        Map<Id ,List<SObject>> accountAccountPlanListMap = new Map<Id,List<SObject>>();
        String SObjectAPIName;
        for(Other_Related_Customer_Location__c eachRelCustLoc : [SELECT Id,Distributor_Location__c,OwnerId,Account_Plan__c,Account_Plan__r.OwnerId FROM Other_Related_Customer_Location__c WHERE Account_Plan__c IN: accountPlanIds]){

            accountAccountPlanListMap = buildaccountAccountPlanListMap(accountAccountPlanListMap, eachRelCustLoc.Distributor_Location__c, new Field_of_Play__c(Id = eachRelCustLoc.Account_Plan__c, OwnerId = eachRelCustLoc.Account_Plan__r.OwnerId));
            if(SObjectAPIName == null){
                SObjectAPIName = eachRelCustLoc.Account_Plan__c.getSObjectType().getDescribe().getName();
            }
        }

        if(!accountAccountPlanListMap.isEmpty()){

            CommunityKPISharingUtility.initiateCommunityKPISharing(accountAccountPlanListMap, sObjectAPIName);
        }
    }*/

    /* Creates Shared Account Plan records when Related Customer Location records are created
    public static void createSharedAccountPlanRecordsfromRelatedCustLocs(Map<Id,List<String>> custLocAccountPlanListMap, Map<Id,List<String>> custLocFiscalYearListMap){

        Map<Id,List<String>> businessStAccPlanListMap = new Map<Id,List<String>>();
        for(Business_Strategy__c eachBusinessSt : [SELECT Id, Fiscal_Year_FY__c, Parent_Business_Strategy__r.Distributor_Account__c FROM Business_Strategy__c
                                                    WHERE Parent_Business_Strategy__r.Distributor_Account__c IN: custLocAccountPlanListMap.keySet()]){
            
            if(custLocFiscalYearListMap.get(eachBusinessSt.Parent_Business_Strategy__r.Distributor_Account__c).contains(eachBusinessSt.Fiscal_Year_FY__c)){

                businessStAccPlanListMap.put(eachBusinessSt.Id, custLocAccountPlanListMap.get(eachBusinessSt.Parent_Business_Strategy__r.Distributor_Account__c));
            }
        }

        List<Field_of_Play__c> accSharePlanRecordsToInsert = new List<Field_of_Play__c>();
        if(!businessStAccPlanListMap.isEmpty()){

            for(Id businessStId : businessStAccPlanListMap.keySet()){

                Field_of_Play__c accplanShare = new Field_of_Play__c(RecordTypeId = CommunityKPISharingConstants.DISTRIBUTOR_SHARED_ACCOUNT_PLAN);
                for(String accPlanId : businessStAccPlanListMap.get(businessStId)){

                    accplanShare.Shared_Business_Strategy__c = businessStId;
                    accplanShare.Shared_Account_Plan__c = accPlanId;
                    accSharePlanRecordsToInsert.add(accplanShare);
                }
            }
        }

        if(!accSharePlanRecordsToInsert.isEmpty()){
            insert accSharePlanRecordsToInsert;
        }
    }*/

    /* Delete All Sharing Record for Account Plan Records
    public static void deleteAccountPlanSharing(List<Field_of_Play__c> accountPlansToDelete, List<User> partnerUserList){

        if(!accountPlansToDelete.isEmpty() && !partnerUserList.isEmpty()){

            delete [SELECT Id FROM Field_of_Play__Share WHERE ParentId IN: accountPlansToDelete AND UserOrGroupId IN: partnerUserList
                    AND RowCause IN (:CommunityKPISharingConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE, :CommunityKPISharingConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE, :'Manual')];
        }
        else if(accountPlansToDelete.isEmpty() && !partnerUserList.isEmpty()){

            delete [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId IN: partnerUserList
                    AND RowCause IN (:CommunityKPISharingConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE, :CommunityKPISharingConstants.COMMUNITY_KPI_SHARE_MANAGER_USER_ROW_CAUSE, :'Manual')];
        }
    }*/

    /* Filter Account plans Based on the contact update 
    public static List<Field_of_Play__c> getAccountPlanRecordsToShareOnContactUpdate(Set<Id> accountIds, List<String> additionalCountries){
        
        return  [SELECT Id FROM Field_of_Play__c 
                WHERE (Distributor_Business_Strategy__c != null 
                AND Distributor_Business_Strategy__r.Parent_Business_Strategy__c != null
                AND (Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__c IN: accountIds
                    OR (Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__r.BillingCountry != null AND 
                        Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__r.BillingCountry IN: additionalCountries)))
                // Below is for shared Account Plan
                OR ( Shared_Business_Strategy__c != null
                AND Shared_Business_Strategy__r.Parent_Business_Strategy__c != null
                AND (Shared_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__c IN: accountIds
                OR (Shared_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__r.BillingCountry != null AND 
                    Shared_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__r.BillingCountry IN: additionalCountries)))];
    }*/
    
    /* Delete Account Plan sharing records on delete of Related Customer Locations
    /*format "UserId - AccountPlanId"
    public static void deleteAccountPlanSharingOnRelatedCustomerLocDelete(List<String> userAccountPlanIdList,Set<Id> communityUserIds,Set<Id> accountPlanIds){

        List<Field_of_Play__Share> accountPlanShareDeleteList = new List<Field_of_Play__Share>();
        for(Field_of_Play__share eachAccountPlanShare : [SELECT Id,UserOrGroupId,ParentId FROM Field_of_Play__share 
                                                        WHERE UserOrGroupId IN: communityUserIds
                                                        AND ParentId IN: accountPlanIds
                                                        AND RowCause =: CommunityKPISharingConstants.COMMUNITY_KPI_SHARE_STANDARD_USER_ROW_CAUSE]){
            
            if(userAccountPlanIdList.contains(eachAccountPlanShare.UserOrGroupId + '-' + eachAccountPlanShare.ParentId)){
                accountPlanShareDeleteList.add(eachAccountPlanShare);
            }
        }

        if(!accountPlanShareDeleteList.isEmpty()){
            delete accountPlanShareDeleteList;
        }
    }*/
    
    public static List<Field_of_Play__c> allAccountPlansRelatedToAccounts(Set<Id> AccountIds){
        return [
            SELECT Id,Distributor_Business_Strategy__c,RecordTypeId, OwnerId, CreatedById
            FROM Field_of_Play__c
            WHERE RecordTypeId = :KPIConstants.DISTRIBUTOR_ACCOUNT_PLAN AND Distributor_Business_Strategy__c != null
            AND Distributor_Business_Strategy__r.Distributor_Account_Name__c != null
            AND Distributor_Business_Strategy__r.Distributor_Parent_Account__c != null
            AND (Distributor_Business_Strategy__r.Distributor_Account_Name__c IN: AccountIds OR
                 Distributor_Business_Strategy__r.Distributor_Parent_Account__c IN: AccountIds)
            
        ];
    }

}