/*
    Author : Sibananda Bhuyan 16-04-2020
    Description : This class will share all Other Related Customer Location Object
    Update 18-05-2020: Chaning Share of Competitor Info from Commercial Activity to Business Strategy
    Update 07-12-2020: Added logic to share KPIs if related location is added to particular KPIs
*/
public without sharing class RelatedCustomerLocationSharingUtility {
    

    public static void shareKPIsOnRelatedCustLocCreate( List<Other_Related_Customer_Location__c> newRelatedCustomerLocations ){
		system.debug('RelCustLocSharingUtility line 11');
        /* Declare KPIs and segregate based on the categories to share */

        Set<Id> otherRelLocForAccountPlan       = new Set<Id>();
        Set<Id> otherRelLocForCommercialAct     = new Set<Id>();
        Set<Id> otherRelLocForSalesPerformance  = new Set<Id>();
        Set<Id> otherRelLocForBusinessStrategy  = new Set<Id>();
        Set<Id> otherRelLocForForecastAccuracy  = new Set<Id>();
        Set<Id> otherRelLocForFCICustomSupport  = new Set<Id>();
        Set<Id> distributorLocIds               = new Set<Id>();

        for( Other_Related_Customer_Location__c otherRelLoc : newRelatedCustomerLocations ){

            /* Checks if the Other Related Customer location is valid to be recalculated */
            if ( isRecalculationRequiredToShare( otherRelLoc ) ) {
                
                distributorLocIds.add( otherRelLoc.Distributor_Location__c );

                if( !String.isBlank( otherRelLoc.Account_Plan__c ) )                    otherRelLocForAccountPlan.add( otherRelLoc.Account_Plan__c );
                if( !String.isBlank( otherRelLoc.Related_Commercial_Activity__c ) )     otherRelLocForCommercialAct.add( otherRelLoc.Related_Commercial_Activity__c );
                if( !String.isBlank( otherRelLoc.Related_Sales_Performance__c ) )       otherRelLocForSalesPerformance.add( otherRelLoc.Related_Sales_Performance__c );
                if( !String.isBlank( otherRelLoc.Related_Business_Strategy__c ) )       otherRelLocForBusinessStrategy.add( otherRelLoc.Related_Business_Strategy__c );
                if( !String.isBlank( otherRelLoc.Related_Forecast_Accuracy__c ) )       otherRelLocForForecastAccuracy.add( otherRelLoc.Related_Forecast_Accuracy__c );
                if( !String.isBlank( otherRelLoc.Related_FCI_Customer_Support__c ) )    otherRelLocForFCICustomSupport.add( otherRelLoc.Related_FCI_Customer_Support__c );
            }
        }
		
        //Query all Users from the userIds
        List<User> users = ( UserUtility.getCommunityUsersByAccountIds( distributorLocIds ) ).values();

        // This is only for Commercial Activity Sharing
        if( !otherRelLocForCommercialAct.isEmpty() ) CommercialActivitySharingUtility.initiateComActivitySharing( users, DAOUtilityWithoutShar.getComActivityForSharing( otherRelLocForCommercialAct ) );

        // This is only for Sales Performance Sharing
        if( !otherRelLocForSalesPerformance.isEmpty() ) SalesFunnelSharingUtility.initiateSalesFunnelSharing( users, DAOUtilityWithoutShar.getSalesFunnelsForSharing( otherRelLocForSalesPerformance ) );

        // This is only for Business Strategy Sharing
        if( !otherRelLocForBusinessStrategy.isEmpty() ) BusinessStrategySharingUtility.initiateBusinessStrategySharing( users, DAOUtilityWithoutShar.getBusinessStrategyForSharing( otherRelLocForBusinessStrategy ) );

        // This is only for Forecast Accuracy Sharing
        if( !otherRelLocForForecastAccuracy.isEmpty() ) ForecastAccuracySharingUtility.initiateForecastAccuracySharing( users, DAOUtilityWithoutShar.getForecastAccuracyForSharing( otherRelLocForForecastAccuracy ) );

        // This is only for FCI Customer Support Sharing
        if( !otherRelLocForFCICustomSupport.isEmpty() ) FCICustomerSupportSharingUtility.initiateFCICustomerSupportSharing( users, DAOUtilityWithoutShar.getFCICustomerSupportsForSharing( otherRelLocForFCICustomSupport ) );

        // This is only for Account Plan
        if( !otherRelLocForAccountPlan.isEmpty() ){

            //Query Account Plans to Share with Related Customer Locations
            List<Field_of_Play__c> accountPlans = DAOUtilityWithoutShar.getAccountPlansForSharing( otherRelLocForAccountPlan );

            //Query additional fields from Related Customer Location to create shared Account Plan records
            List<Other_Related_Customer_Location__c> relatedCustomerLocations = DAOUtilityWithoutShar.getRelatedCustomerLocationForAccountPlans( otherRelLocForAccountPlan );

            //Shares Account plan records
            AccountPlanSharingUtility.initiateAccountPlanSharing( users, accountPlans );

            //Creates Shared Account Plan Records
            AccountPlanSharingUtility.createSharedAccountPlanRecordsfromRelatedCustLocs( getCustomerLocAccountPlansMap( relatedCustomerLocations ), getCustomerLocFiscalYearsMap( relatedCustomerLocations ) );
        }
    }

    public static void deleteKPISharingOnRelCustLocDelete( List<Other_Related_Customer_Location__c> oldRelatedCustomerLocations ){

        //Declare KPIs and segregate based on the categories to Delete

        Set<Id> otherRelLocForAccountPlan       = new Set<Id>();
        Set<Id> otherRelLocForCommercialAct     = new Set<Id>();
        Set<Id> otherRelLocForSalesPerformance  = new Set<Id>();
        Set<Id> otherRelLocForBusinessStrategy  = new Set<Id>();
        Set<Id> otherRelLocForForecastAccuracy  = new Set<Id>();
        Set<Id> otherRelLocForFCICustomSupport  = new Set<Id>();
        Set<Id> distributorLocIds               = new Set<Id>();

        /* Checks if the Other Related Customer location is valid to be recalculated */
        for( Other_Related_Customer_Location__c otherRelLoc : oldRelatedCustomerLocations ){

            if( isRecalculationRequiredToShare( otherRelLoc ) ){

                distributorLocIds.add( otherRelLoc.Distributor_Location__c );

                if( !String.isBlank( otherRelLoc.Account_Plan__c ) )                    otherRelLocForAccountPlan.add( otherRelLoc.Account_Plan__c );
                if( !String.isBlank( otherRelLoc.Related_Commercial_Activity__c ) )     otherRelLocForCommercialAct.add( otherRelLoc.Related_Commercial_Activity__c );
                if( !String.isBlank( otherRelLoc.Related_Sales_Performance__c ) )       otherRelLocForSalesPerformance.add( otherRelLoc.Related_Sales_Performance__c );
                if( !String.isBlank( otherRelLoc.Related_Business_Strategy__c ) )       otherRelLocForBusinessStrategy.add( otherRelLoc.Related_Business_Strategy__c );
                if( !String.isBlank( otherRelLoc.Related_Forecast_Accuracy__c ) )       otherRelLocForForecastAccuracy.add( otherRelLoc.Related_Forecast_Accuracy__c );
                if( !String.isBlank( otherRelLoc.Related_FCI_Customer_Support__c ) )    otherRelLocForFCICustomSupport.add( otherRelLoc.Related_FCI_Customer_Support__c );
            }
        }

        //Query all Users from the userIds
        Map<Id, User> usersMap = UserUtility.getCommunityUsersByAccountIds( distributorLocIds );
        
        //Map of UserIds with Additional Customer Locations added at contact Level - ENH-4815
        /*Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(usersMap.values());*/

        // This is only for Commercial Activity Sharing
        if(!otherRelLocForCommercialAct.isEmpty())      CommercialActivitySharingUtility.deleteCommercialActivitySharing( usersMap.keySet(), new Map<Id, Commercial_Activity__c>( DAOUtilityWithoutShar.getComActivityForSharing( otherRelLocForCommercialAct )).keySet() );

        //This is only for Sales Performance Sharing
        if(!otherRelLocForSalesPerformance.isEmpty())   SalesFunnelSharingUtility.deleteSalesPerformanceSharing( usersMap.keySet(), new Map<Id, Sales_Funnel__c>( DAOUtilityWithoutShar.getSalesFunnelsForSharing( otherRelLocForSalesPerformance ) ).keySet() );

        // This is only for Business Strategy Sharing
        if(!otherRelLocForBusinessStrategy.isEmpty())   BusinessStrategySharingUtility.deleteBusinessStrategySharing( usersMap.keySet(), new Map<Id, Business_Strategy__c>( DAOUtilityWithoutShar.getBusinessStrategyForSharing( otherRelLocForBusinessStrategy ) ).keySet() );

        // This is only for Forecast Accuracy Sharing
        if(!otherRelLocForForecastAccuracy.isEmpty())   ForecastAccuracySharingUtility.deleteForecastAccuracySharing( usersMap.keySet(), new Map<Id, Forecast_Accuracy__c>( DAOUtilityWithoutShar.getForecastAccuracyForSharing( otherRelLocForForecastAccuracy ) ).keySet() );

        // This is only for FCI Customer Support Sharing
        if(!otherRelLocForFCICustomSupport.isEmpty())   FCICustomerSupportSharingUtility.deleteFCICustomerSupportSharing( usersMap.keySet(), new Map<Id, FCI_Customer_Support__c>( DAOUtilityWithoutShar.getFCICustomerSupportsForSharing( otherRelLocForFCICustomSupport ) ).keySet() );

        // This is only for Account Plan
        if(!otherRelLocForAccountPlan.isEmpty()) {      
            
            //Deletes Account Plan Sharing
            AccountPlanSharingUtility.deleteAccountPlanSharing( usersMap.keySet(), otherRelLocForAccountPlan );

            //Deletes Shared Account Plan Records
            AccountPlanSharingUtility.deleteSharedAccountPlans( otherRelLocForAccountPlan );

        }
        
        //Recalculate Sharing to share the KPIs through Additional Customer Locations
        BusinessStrategySharingUtility.initiateBusinessStrategySharing(usersMap.values(), DAOUtilityWithoutShar.getBusinessStrategyForSharing( otherRelLocForBusinessStrategy ));
        CommercialActivitySharingUtility.initiateComActivitySharing(usersMap.values(), DAOUtilityWithoutShar.getComActivityForSharing( otherRelLocForCommercialAct ));
        FCICustomerSupportSharingUtility.initiateFCICustomerSupportSharing(usersMap.values(), DAOUtilityWithoutShar.getFCICustomerSupportsForSharing( otherRelLocForFCICustomSupport ));
        ForecastAccuracySharingUtility.initiateForecastAccuracySharing(usersMap.values(), DAOUtilityWithoutShar.getForecastAccuracyForSharing( otherRelLocForForecastAccuracy ));
        SalesFunnelSharingUtility.initiateSalesFunnelSharing(usersMap.values(), DAOUtilityWithoutShar.getSalesFunnelsForSharing( otherRelLocForSalesPerformance ));
        AccountPlanSharingUtility.initiateAccountPlanSharing(usersMap.values(), DAOUtilityWithoutShar.getAccountPlansForSharing( otherRelLocForAccountPlan ));
    }

    //Prepares a Map of <Customer location, List<Account Plans>>
    private static Map<Id,List<String>> getCustomerLocAccountPlansMap( List<Other_Related_Customer_Location__c> relatedCustomerLocations ){

        Map<Id,List<String>> custLocAccountPlans = new Map<Id,List<String>>();

        for( Other_Related_Customer_Location__c othRelCustLoc : relatedCustomerLocations ){

            if( !custLocAccountPlans.containsKey( othRelCustLoc.Distributor_Location__c ) ){

                custLocAccountPlans.put( othRelCustLoc.Distributor_Location__c, new List<String>() );
            }
            custLocAccountPlans.get( othRelCustLoc.Distributor_Location__c ).add( othRelCustLoc.Account_Plan__c );
        }

        return custLocAccountPlans;
    }

    //Prepares a Map of <Customer location, List<Business Strategy buckets Fiscal Year field>>
    private static Map<Id,List<String>> getCustomerLocFiscalYearsMap( List<Other_Related_Customer_Location__c> relatedCustomerLocations ){

        Map<Id,List<String>> custLocFiscalYears = new Map<Id,List<String>>();

        for( Other_Related_Customer_Location__c othRelCustLoc : relatedCustomerLocations ){

            if( !custLocFiscalYears.containsKey( othRelCustLoc.Distributor_Location__c ) ){

                custLocFiscalYears.put( othRelCustLoc.Distributor_Location__c, new List<String>() );
            }
            custLocFiscalYears.get( othRelCustLoc.Distributor_Location__c ).add( othRelCustLoc.Account_Plan__r.Distributor_Business_Strategy__r.Fiscal_Year_FY__c );
        }

        return custLocFiscalYears;
    }

    private static Boolean isRecalculationRequiredToShare( Other_Related_Customer_Location__c otherRelLoc ){

        return otherRelLoc.RecordTypeId.equals( KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID ) &&
            otherRelLoc.Distributor_Location__c != null;
    }

    /* This method will delete all Account plan sharing records when a associated Related CUstomer location is deleted */
    /*public static void deleteAccountPlanSharing(List<Other_Related_Customer_Location__c> oldRelatedCustomerLocations){

        //String of the format "UserId - AccountPlanId"
        List<String> userAccountPlanIdList = new List<String>();

        //CustomerLocationId and List<AccountId> Map
        Map<Id,List<Id>> custLocAccountPlans = getCustomerLocAccountPlansMap(oldRelatedCustomerLocations);

        //Stores all CommunityUserIds who should have their Account plan access removed
        Set<Id> communityUserIds;

        //Stores all the AccountPlanIds 
        Set<Id> accountPlanIds;

        //UserId and User Map
        Map<Id,User> communityUserMap;


        if(!custLocAccountPlans.isEmpty()){

            communityUserIds = new Set<Id>();
            accountPlanIds = new Set<Id>();

            for(User eachUser : (UserUtility.getCommunityUsersByAccountIds(custLocAccountPlans.keySet())).values()){

                //Account Plan access should only be removed for Standard Users because Manager users 
                //will always have access to all the Account plans for all the locations under H1 everytime
                if(custLocAccountPlans.containsKey(eachUser.Contact.AccountId) && UserUtility.isUserStandardCommunityUser(eachUser)){

                    for(Id eachAccountPlanId : custLocAccountPlans.get(eachUser.Contact.AccountId)){

                        userAccountPlanIdList.add(eachUser.Id + '-' + eachAccountPlanId);
                        communityUserIds.add(eachUser.Id);
                        accountPlanIds.add(eachAccountPlanId);
                    }
                }

            }
        }

        if(!userAccountPlanIdList.isEmpty()){
            AccountPlanSharingUtility.deleteAccountPlanSharingOnRelatedCustomerLocDelete(userAccountPlanIdList, communityUserIds, accountPlanIds);
        }
        
    }*/
    
    public static void shareAccountsOnRelatedCustLocCreate(List<Other_Related_Customer_Location__c> newRelatedCustomerLocations){
        Set<Id> addCustLocIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for( Other_Related_Customer_Location__c otherRelLoc : newRelatedCustomerLocations){
            if(otherRelLoc.RecordTypeId.equals( KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID ) &&
               otherRelLoc.Additional_Customer_Location__c != null && otherRelLoc.Related_Contact__c != null)
            {
                addCustLocIds.add(otherRelLoc.Additional_Customer_Location__c);
                contactIds.add(otherRelLoc.Related_Contact__c);
            }
        }
                
        Map<Id, User> usersMap = new Map<Id, User>(UserUtility.getAllPartnerCommunityUsersByContacts(contactIds));
        if(usersMap != null && !usersMap.isEmpty() && !addCustLocIds.isEmpty()){
            addCustLocIds.addAll(getEndCustomersOfSelectedAccounts(addCustLocIds));
            AccountSharingUtility.createSharingForAccount(usersMap.keySet(), addCustLocIds);
            OpportunitySharingUtility.createOpportunitySharing(new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(addCustLocIds)).keySet());
            CaseSharingUtility.createSharingForCase(new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(addCustLocIds)).keySet());
            //LeadSharingUtility.createSharingForLead(usersMap.keySet(), new Map<Id, Lead>(LeadSharingUtility.allLeadsRelatedToAccounts(addCustLocIds)).keySet());
            ChildLeadSharingUtility.createSharingForLead(usersMap.keySet(), new Map<Id, Child_Lead__c>(ChildLeadSharingUtility.allLeadsRelatedToAccounts(addCustLocIds)).keySet());
            BusinessStrategySharingUtility.initiateBusinessStrategySharing(usersMap.values(), BusinessStrategySharingUtility.allBusinessStrategiesRelatedToAccounts(addCustLocIds));
            CommercialActivitySharingUtility.initiateComActivitySharing(usersMap.values(), CommercialActivitySharingUtility.allCommercialActivitiesRelatedToAccounts(addCustLocIds));
            FCICustomerSupportSharingUtility.initiateFCICustomerSupportSharing(usersMap.values(), FCICustomerSupportSharingUtility.allFCICustomerSupportsRelatedToAccounts(addCustLocIds));
            ForecastAccuracySharingUtility.initiateForecastAccuracySharing(usersMap.values(), ForecastAccuracySharingUtility.allForecastAccuraciesRelatedToAccounts(addCustLocIds));
            SalesFunnelSharingUtility.initiateSalesFunnelSharing(usersMap.values(), SalesFunnelSharingUtility.allSalesFunnelsRelatedToAccounts(addCustLocIds));
        	AccountPlanSharingUtility.initiateAccountPlanSharing(usersMap.values(), AccountPlanSharingUtility.allAccountPlansRelatedToAccounts(addCustLocIds));
        }
    }
    
    public static void recalculateAccountSharingOnRelatedCustLocUpdateOrDelete(List<Other_Related_Customer_Location__c> newRelatedCustomerLocations){
        Set<Id> addCustLocIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for( Other_Related_Customer_Location__c otherRelLoc : newRelatedCustomerLocations){
            if(otherRelLoc.RecordTypeId.equals( KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID ) &&
               otherRelLoc.Additional_Customer_Location__c != null && otherRelLoc.Related_Contact__c != null)
            {
                addCustLocIds.add(otherRelLoc.Additional_Customer_Location__c);
                contactIds.add(otherRelLoc.Related_Contact__c);
            }
        }
        
        Map<Id, User> usersMap = new Map<Id, User>(UserUtility.getAllPartnerCommunityUsersByContacts(contactIds));
        AccountSharingUtility.deleteAllAccountRelatedSharing(usersMap.values());
        Map<Id, Account> allAccountsToShare = new Map<Id, Account>(AccountUtility.getAccountAllAccountsToShareWithCommunityUsers(usersMap.values()));
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(allAccountsToShare.keySet());
        accountIdSet.addAll(addCustLocIds);
        
        OpportunitySharingUtility.deleteAllOpportunityRelatedSharing(usersMap.keySet(), (new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(accountIdSet))).keySet());
        CaseSharingUtility.deleteAllCasesRelatedSharing(usersMap.keySet(), (new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(accountIdSet))).keySet());
        //DAOUtilityWithoutShar.deleteAllLeadRelatedSharing(usersMap.values(), LeadSharingUtility.allLeadsRelatedToAccounts(accountIdSet));
        DAOUtilityWithoutShar.deleteAllChildLeadsRelatedSharing(usersMap.values(), ChildLeadSharingUtility.allLeadsRelatedToAccounts(accountIdSet));
        BusinessStrategySharingUtility.deleteBusinessStrategySharing( usersMap.keySet(), new Map<Id, Business_Strategy__c>( BusinessStrategySharingUtility.allBusinessStrategiesRelatedToAccounts(accountIdSet) ).keySet() );
        CommercialActivitySharingUtility.deleteCommercialActivitySharing( usersMap.keySet(), new Map<Id, Commercial_Activity__c>( CommercialActivitySharingUtility.allCommercialActivitiesRelatedToAccounts(accountIdSet)).keySet() );
        FCICustomerSupportSharingUtility.deleteFCICustomerSupportSharing( usersMap.keySet(), new Map<Id, FCI_Customer_Support__c>( FCICustomerSupportSharingUtility.allFCICustomerSupportsRelatedToAccounts(accountIdSet) ).keySet() );
        ForecastAccuracySharingUtility.deleteForecastAccuracySharing( usersMap.keySet(), new Map<Id, Forecast_Accuracy__c>( ForecastAccuracySharingUtility.allForecastAccuraciesRelatedToAccounts(accountIdSet) ).keySet() );
        SalesFunnelSharingUtility.deleteSalesPerformanceSharing( usersMap.keySet(), new Map<Id, Sales_Funnel__c>( SalesFunnelSharingUtility.allSalesFunnelsRelatedToAccounts(accountIdSet) ).keySet() );
        AccountPlanSharingUtility.deleteAccountPlanSharing( usersMap.keySet(), new Map<Id, Field_of_Play__c>(AccountPlanSharingUtility.allAccountPlansRelatedToAccounts(accountIdSet)).keySet() );
        
        if(usersMap != null && !usersMap.isEmpty() && !accountIdSet.isEmpty()){
            accountIdSet.addAll(getEndCustomersOfSelectedAccounts(addCustLocIds));
            AccountSharingUtility.createSharingForAccount(usersMap.keySet(), accountIdSet);
            OpportunitySharingUtility.createOpportunitySharing(new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(accountIdSet)).keySet());
            CaseSharingUtility.createSharingForCase(new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(accountIdSet)).keySet());
            //LeadSharingUtility.createSharingForLead(usersMap.keySet(), new Map<Id, Lead>(LeadSharingUtility.allLeadsRelatedToAccounts(accountIdSet)).keySet());
            ChildLeadSharingUtility.createSharingForLead(usersMap.keySet(), new Map<Id, Child_Lead__c>(ChildLeadSharingUtility.allLeadsRelatedToAccounts(accountIdSet)).keySet());
            BusinessStrategySharingUtility.initiateBusinessStrategySharing(usersMap.values(), BusinessStrategySharingUtility.allBusinessStrategiesRelatedToAccounts(accountIdSet));
            CommercialActivitySharingUtility.initiateComActivitySharing(usersMap.values(), CommercialActivitySharingUtility.allCommercialActivitiesRelatedToAccounts(accountIdSet));
            FCICustomerSupportSharingUtility.initiateFCICustomerSupportSharing(usersMap.values(), FCICustomerSupportSharingUtility.allFCICustomerSupportsRelatedToAccounts(accountIdSet));
            ForecastAccuracySharingUtility.initiateForecastAccuracySharing(usersMap.values(), ForecastAccuracySharingUtility.allForecastAccuraciesRelatedToAccounts(accountIdSet));
            SalesFunnelSharingUtility.initiateSalesFunnelSharing(usersMap.values(), SalesFunnelSharingUtility.allSalesFunnelsRelatedToAccounts(accountIdSet));
            AccountPlanSharingUtility.initiateAccountPlanSharing(usersMap.values(), AccountPlanSharingUtility.allAccountPlansRelatedToAccounts(accountIdSet));
        }        
    }
    
    public static Map<Id, User> getUsersToRecalculate(List<Other_Related_Customer_Location__c> newRelatedCustomerLocations){
        Set<Id> addCustLocIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, User> usersToRecalculateMap;
        for( Other_Related_Customer_Location__c otherRelLoc : newRelatedCustomerLocations){
            if(otherRelLoc.RecordTypeId.equals( KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID ) &&
               otherRelLoc.Additional_Customer_Location__c != null && otherRelLoc.Related_Contact__c != null)
            {
                addCustLocIds.add(otherRelLoc.Additional_Customer_Location__c);
                contactIds.add(otherRelLoc.Related_Contact__c);
            }
        }
        if(!addCustLocIds.isEmpty())
        	usersToRecalculateMap = new Map<Id, User>(UserUtility.getAllPartnerCommunityUsersByContacts(contactIds));
        
        return usersToRecalculateMap;
    }
    
    public static Map<Id, Set<Id>> getUsersByAddCustLocs(Set<Id> accountIds){
        Map<Id, Set<Id>> addCustLocsWithUserIds = new Map<Id, Set<Id>>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, Id> contactUserIdMap = new Map<Id, Id>();
        List<Other_Related_Customer_Location__c> orclList = [SELECT Id, Additional_Customer_Location__c, Related_Contact__c
                                                             FROM Other_Related_Customer_Location__c
                                                             WHERE Additional_Customer_Location__c IN: accountIds
                                                             AND Related_Contact__c != null];
        
        for(Other_Related_Customer_Location__c orcl : orclList){
            contactIdSet.add(orcl.Related_Contact__c);
        }
        
        for(User usr : UserUtility.getAllPartnerCommunityUsersByContacts(contactIdSet)){
            contactUserIdMap.put(usr.ContactId, usr.Id);
        }
        
        for(Other_Related_Customer_Location__c orcl : orclList){
            if(!addCustLocsWithUserIds.containsKey(orcl.Additional_Customer_Location__c) && contactUserIdMap.containsKey(orcl.Related_Contact__c) && contactUserIdMap.get(orcl.Related_Contact__c) != null){
                addCustLocsWithUserIds.put(orcl.Additional_Customer_Location__c, new Set<Id>{contactUserIdMap.get(orcl.Related_Contact__c)});
            }else if(contactUserIdMap.containsKey(orcl.Related_Contact__c) && contactUserIdMap.get(orcl.Related_Contact__c) != null){
                addCustLocsWithUserIds.get(orcl.Additional_Customer_Location__c).add(contactUserIdMap.get(orcl.Related_Contact__c));
            }
        }
        return addCustLocsWithUserIds;
    }
    
    public static void assignOrRemovePermissionSet(List<Other_Related_Customer_Location__c> newRelatedCustomerLocations){
        Set<Id> contactIds = new Set<Id>();
        Id kpiDLFieldPermissionSetId = PermissionSetAssignmentUtility.getSelectedPermissionSetId('Additional_Access_to_Distributor_Community_Manager_Users');
        for( Other_Related_Customer_Location__c otherRelLoc : newRelatedCustomerLocations){
            if(otherRelLoc.RecordTypeId.equals( KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID ) &&
               otherRelLoc.Additional_Customer_Location__c != null && otherRelLoc.Related_Contact__c != null)
            {
                contactIds.add(otherRelLoc.Related_Contact__c);
            }
        }
        
        if(!contactIds.isEmpty()) permissionSetAssignmentFuture(contactIds, kpiDLFieldPermissionSetId);
    }
    
    @future
    public static void permissionSetAssignmentFuture(Set<Id> contactIds, Id kpiDLFieldPermissionSetId){
        List<PermissionSetAssignment> deletePermissionSet = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> assignPermissionSet = new List<PermissionSetAssignment>();
        
        Map<Id, Integer> contactNumOfAddCustLocsMap = new Map<Id, Integer>();
        Set<Id> contactsWithAddCountryRespSet = new Set<Id>();
        Set<Id> conIdsToRevokePermSet = new Set<Id>();
        for(Contact conRec : [SELECT Id, Additional_Country_Responsibility__c,
                              (SELECT Id FROM Other_Related_Customer_Location__r)
                              FROM Contact WHERE Id IN: contactIds])
        {
            if(
                conRec.Other_Related_Customer_Location__r != null &&
                !conRec.Other_Related_Customer_Location__r.isEmpty() &&
                conRec.Other_Related_Customer_Location__r.size() > 0
            ){
                contactNumOfAddCustLocsMap.put(conRec.Id, conRec.Other_Related_Customer_Location__r.size());
            }else if(conRec.Additional_Country_Responsibility__c == null){
                conIdsToRevokePermSet.add(conRec.Id);
            }
            
            if(conRec.Additional_Country_Responsibility__c != null){
                contactsWithAddCountryRespSet.add(conRec.Id);
            }
        }
        
        List<User> usersList = UserUtility.getAllPartnerCommunityUsersByContacts(contactIds);
        Map<Id, PermissionSetAssignment> userPermissionSetAssignmentMap = new Map<Id, PermissionSetAssignment>(
            PermissionSetAssignmentUtility.getPermSetAssignmentForSelectedUsers(usersList, kpiDLFieldPermissionSetId)
        );
        
        for(User usr : usersList){
            if(UserUtility.isUserStandardCommunityUser(usr) && usr.Profile.Name == 'FCI Distributor Community User'){
                if(userPermissionSetAssignmentMap.containsKey(usr.Id)){
                    if(!conIdsToRevokePermSet.isEmpty() && conIdsToRevokePermSet.contains(usr.ContactId))
                        deletePermissionSet.add(userPermissionSetAssignmentMap.get(usr.Id));
                }else{
                    assignPermissionSet.add(PermissionSetAssignmentUtility.addPermissionSetAssignment(usr.Id, kpiDLFieldPermissionSetId));
                }
            }
        }
        
        if(!assignPermissionSet.isEmpty()) DAOUtilityWithoutShar.insertWithoutAccess(assignPermissionSet);
        if(!deletePermissionSet.isEmpty()) DAOUtilityWithoutShar.deleteWithoutAccess(deletePermissionSet);
    }
    
    private static Set<Id> getEndCustomersOfSelectedAccounts(Set<Id> accountIds){
        Set<Id> endCustomersIdsSet = new Set<Id>();
        Map<Id, Account> endCustomersMap = new Map<Id, Account>([SELECT Id, Distributor_Location__c FROM Account
                           WHERE RecordTypeId =: Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID
                           AND Distributor_Location__c IN: accountIds]);
        endCustomersIdsSet.addAll(endCustomersMap.keySet());
        return endCustomersIdsSet;
    }
}