/*      
@Name                  OpportunitySharingUtility
@Author                Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           04-08-2019
@UsedBy                OpportunityTriggerHandler, ContactSharingUtility, UserSharingUtility
@Description           Class to give and revoke opportunity access to Partner Community Users
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com | 05.04.2020 | Removed all the reference of Constants.OPPORTUNITY_RECORD_TYPE_FCI_NEW_BUSINESS_ID and changed to Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID for the Community Users
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 15.01.2021 | Updated to meet the new sharing requirements of the account redesign
*/
public with sharing class OpportunitySharingUtility {
    
    /* @Description

    Method to recalculate opportunity sharing on update trigger

    @param newOpportunities - Opportunity list of updated new opportunities (Trigger.new)
    @param usersToConsider - A Map of User Id and User SObject of Partner Community Users to consider to revoke opportunity access

    @return void
    */
    public static void recalculateOpportunitySharingOnUpdate(List<Opportunity> newOpportunities, Map<Id,User> usersToConsider){
        
        Set<Id> oppsIdsToRecalculate = new Set<Id>(); //Set of Opportunity Ids to recalculate the sharing
        Set<Id> oppsIdsToRevoke = new Set<Id>(); //Set of Opportunity Ids to revoke the sharing

        //Check which opportunities are elegible to recalculate or revoke
        for (Opportunity opp : newOpportunities) {
            if (isRecalculationRequiredToShare((Opportunity)trigger.OldMap.get(opp.Id), opp)) {
                oppsIdsToRecalculate.add(opp.Id);
            } 
            if(isRecalculationRequiredToRevoke((Opportunity)trigger.OldMap.get(opp.Id), opp)){
                oppsIdsToRevoke.add(opp.Id);
            }
        }

        //Delete the OpportunityShare records for those opportunities and recalculate the sharing
        if(!oppsIdsToRecalculate.isEmpty()){
            deleteAllOpportunityRelatedSharing(usersToConsider.keySet(), oppsIdsToRecalculate);
            createOpportunitySharing(oppsIdsToRecalculate);
        }

        //Delete the OpportunityShare records for those opportunities
        if(!oppsIdsToRevoke.isEmpty()){
            deleteAllOpportunityRelatedSharing(usersToConsider.keySet(), oppsIdsToRevoke);
        }
    }    
    
    /* @Description

    Method to recalculate opportunity sharing on insert trigger

    @param newOpportunities - Opportunity list of created new opportunities (Trigger.new)

    @return void
    */
    public static void recalculateOpportunitySharingOnCreate(List<Opportunity> newOpportunities){

        Set<Id> oppsIdsToRecalculate = new Set<Id>(); //Set of Opportunity Ids to recalculate the sharing

        //Check which opportunities are elegible to recalculate
        for (Opportunity opp : newOpportunities) {
            if (isRecalculationRequiredToShare(opp)) {
                oppsIdsToRecalculate.add(opp.Id);
            } 
        }

        //Recalculate the sharing
        if(!oppsIdsToRecalculate.isEmpty()){
            createOpportunitySharing(oppsIdsToRecalculate);
        }        
    }

    /* @Description

    Future method to call createOpportunitySharing method

    @param oppsIdsToRecalculate - A Set of opportunities Ids to recalculate the sharing

    @return void
    */
    @future
    public static void createOpportunitySharingFuture(Set<Id> oppsIdsToRecalculate){
        createOpportunitySharing(oppsIdsToRecalculate);
    }
    
    /* @Description

    Method to create opportunity sharing

    @param oppsIdsToRecalculate - A Set of opportunities Ids to recalculate the sharing

    @return void
    */
    public static void createOpportunitySharing(Set<Id> oppsIdsToRecalculate){

        List<Opportunity> oppsToRecalculate = new List<Opportunity>(); //Set of Opportunities to recalculate the sharing
        Set<Id> ownersCustomerLocation = new Set<Id>(); //Set of Account Ids of opportunities accounts
        Set<Id> ownersCommercialCustomer = new Set<Id>(); //Set of Account Ids of opportunities parent accounts
        Set<String> billingCountries = new Set<String>(); //Set of countries of opportunities account billing countries
        Map<Id, Set<Id>> oppsIdsToShareWithUsersIdMap = new Map<Id, Set<Id>>();  //Map of Opportunities Ids and list of users to share with      
        Map<Id, Set<Id>> customerLocationIdWithUserIdSetMap = new Map<Id, Set<Id>>(); //Map of Account (Customer Locations) Ids and set of users Ids that belong them
        Map<Id, Set<Id>> commercialCustomersIdWithManagersIdSetMap = new Map<Id, Set<Id>>(); //Map of Account (Commercial Customers) Ids and set of manager users Ids that belong them   
        Map<String, Set<Id>> commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers = new Map<String, Set<Id>>(); //Map of a key (Account (CommercialCustomer) Id + Account (Customer Location) Billing Country) and users Ids with Additional Country Responsability of that country
		Map<Id, Set<Id>> addCustLocsWithUserIdSetMap = new Map<Id, Set<Id>>();
        
        //Get opportunities information
        oppsToRecalculate = DAOUtilityWithoutShar.getOpportunitiesForSharing(oppsIdsToRecalculate);

        //Fill the sets with the opportunities information
        for(Opportunity o : oppsToRecalculate){

            if(String.isNotBlank(o.AccountId)){
                ownersCustomerLocation.add(o.AccountId);
            }

            if(String.isNotBlank(o.Parent_Account__c)){
                ownersCommercialCustomer.add(o.Parent_Account__c);
            }
            
            if(String.isNotBlank(o.Account.BillingCountry)){
                billingCountries.add(o.Account.BillingCountry);
            }            
        }

        //Fill the customerLocationIdWithUserIdSetMap map, the keys are the customer locations Ids
        //and the values are lists of users from that customer locations
        if(!ownersCustomerLocation.isEmpty()){
            getAllCustomerLocationsUsers(ownersCustomerLocation, customerLocationIdWithUserIdSetMap);
            addCustLocsWithUserIdSetMap = RelatedCustomerLocationSharingUtility.getUsersByAddCustLocs(ownersCustomerLocation);
        }
            

        //Fill the commercialCustomersIdWithManagersIdSetMap map, the keys are the commercial customers Ids
        //and the values are lists of manager users from that commercial customers
        if(!ownersCommercialCustomer.isEmpty())
            getAllCommercialCustomerManagersUsers(ownersCommercialCustomer, commercialCustomersIdWithManagersIdSetMap);

        //Fill the commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers map, the keys are commercial customers Ids + country name
        //and the values are lists users with that country additional responsabilities from that commercial customers
        if(!ownersCommercialCustomer.isEmpty() && !billingCountries.isEmpty())
            getAllAdditionalCountryResponsibilityCommercialCustomerUsers(ownersCommercialCustomer, billingCountries, commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers);

        //For each opportunity put all customer location users, commercial customer managers and commercial customers with additional country 
        //responsability users in the oppsIdsToShareWithUsersIdMap
        for(Opportunity o : oppsToRecalculate){

            putAllCustomerLocationUsersToShareOpportunities(o, customerLocationIdWithUserIdSetMap, oppsIdsToShareWithUsersIdMap);
            
            putAllCommercialCustomerManagersToShareOpportunities(o, commercialCustomersIdWithManagersIdSetMap, oppsIdsToShareWithUsersIdMap);
            
            putAllCommercialCustomerAdditionalCountryResponsabilityUsersToShareOpportunities(o, commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers, oppsIdsToShareWithUsersIdMap);

            putAllCustomerLocationUsersToShareOpportunities(o, addCustLocsWithUserIdSetMap, oppsIdsToShareWithUsersIdMap);
            
            //Remove opportunity owners from set to avoid insufficient access rights error
            if(oppsIdsToShareWithUsersIdMap.containsKey(o.Id) && !oppsIdsToShareWithUsersIdMap.get(o.Id).isEmpty()){
                removeOpportunityOwnerFromSet(o, oppsIdsToShareWithUsersIdMap);
            }
        }

        //Insert OpportunityShare records
        if(!oppsIdsToShareWithUsersIdMap.isEmpty()){
            insertOpportunitySharing(oppsIdsToShareWithUsersIdMap);
        }
    }

    /* @Description

    Method to insert OpportunityShare records

    @param oppsIdsToShareWithUsersIdMap - Map of Opportunities Ids and list of users to share with

    @return void
    */
    public static void insertOpportunitySharing(Map<Id, Set<Id>> oppsIdsToShareWithUsersIdMap){

        List<OpportunityShare> oppShareList = new List<OpportunityShare>(); //List of opportunity shares to insert

        //For each opportunity, for each user that have to get access for that opportunity: create one OpportunityShare record
        for(Id oppId : oppsIdsToShareWithUsersIdMap.keySet()){
            for(Id uId : oppsIdsToShareWithUsersIdMap.get(oppId)){
                oppShareList.add(createShareOpportunityRecord(new User(Id = uId), new Opportunity(Id = oppId)));
            }
        }

        //Insert the OpportunityShare records without sharing to avoid insufficient access rights error
        DAOUtilityWithoutShar.insertWithoutAccess(oppShareList);
    }

    /* @Description

    Method to get all opportunities related to accounts

    @param AccountIds - Set of Account Ids to get opportunities related

    @return List<Opportunity> Opportunities list related of that accounts
    */
    public static List<Opportunity> allOpportunitiesRelatedToAccounts(Set<Id> AccountIds){
        return [
                SELECT Id,Parent_Account__c,AccountId,RecordTypeId, OwnerId, CreatedById
                FROM Opportunity
                WHERE RecordTypeId = :Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID
                AND AccountId != null
                AND Parent_Account__c != null
                AND (Parent_Account__c IN :AccountIds OR AccountId IN :AccountIds)
        ];
    }

    /* @Description

    Method to delete all OpportunityShare records

    @param usersIds - Set of user Ids to revoke opportunities manual sharing
    @param oppsIdsToRevokeAccess - Set of opportunities Ids to consider to revoke manual sharing

    @return void
    */
    public static void deleteAllOpportunityRelatedSharing(Set<Id> usersIds, Set<Id> oppsIdsToRevokeAccess) {

        //Delete the OpportunityShare records without sharing to avoid insufficient access rights error
        DAOUtilityWithoutShar.deleteWithoutAccess([
            SELECT Id
            FROM OpportunityShare
            WHERE UserOrGroupId IN :usersIds AND
            OpportunityId IN :oppsIdsToRevokeAccess AND
            RowCause = :Constants.SHARE_ROW_CAUSE_MANUAL
        ]);
    }
    
    /* @Description

    Method to create an instance of OpportunityShare

    @param us - User SObject to create the OpportunityShare
    @param oppObj - Opportunity SObject to create the OpportunityShare

    @return OpportunityShare - OpportunityShare record with fields populated(RowCause = Manual and AccessLevel = Edit)
    */
    public static OpportunityShare createShareOpportunityRecord(User us, Opportunity oppObj){
        return new OpportunityShare(
            OpportunityId = oppObj.Id,
            OpportunityAccessLevel = Constants.SHARE_ACCESS_LEVEL_EDIT,
            RowCause = Constants.SHARE_ROW_CAUSE_MANUAL,
            UserOrGroupId = us.Id
        );
    }
    
    /* @Description

    Check if the opportunity needs to recalculate its sharing after update

    @param oldOpp - Old Opportunity SObject to compare
    @param newOpp - New Opportunity SObject to compare

    @return Boolean - True of false if the Opportunity is required to share
    */
    private static Boolean isRecalculationRequiredToShare(Opportunity oldOpp,Opportunity newOpp){
        return (
                newOpp.RecordTypeId.equals(Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID) &&
                (
                    oldOpp.AccountId != newOpp.AccountId ||
                    (
                        oldOpp.RecordTypeId != newOpp.RecordTypeId && 
                        !oldOpp.RecordTypeId.equals(Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID)
                    ) ||
                    oldOpp.OwnerId != newOpp.OwnerId
                )
            );
    }
    
    /* @Description

    Check if the opportunity needs to recalculate its sharing after insert

    @param newOpp - New Opportunity SObject to check

    @return Boolean - True of false if the Opportunity is required to share
    */
    private static Boolean isRecalculationRequiredToShare(Opportunity newOpp){
        return newOpp.RecordTypeId.equals(Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID);
    }
    
    /* @Description

    Check if the opportunity needs to revoke its sharing

    @param oldOpp - Old Opportunity SObject to compare
    @param newOpp - New Opportunity SObject to compare

    @return Boolean - True of false if the Opportunity is required to revoke the sharing
    */
    private static Boolean isRecalculationRequiredToRevoke(Opportunity oldOpp, Opportunity newOpp){
        return oldOpp.RecordTypeId != newOpp.RecordTypeId &&
               oldOpp.RecordTypeId.equals(Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID) &&
               !newOpp.RecordTypeId.equals(Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID);
    }

    /* @Description

    Populate the customerLocationIdWithUserIdSetMap

    @param ownersCustomerLocation - Set of Account Ids of opportunities accounts
    @param customerLocationIdWithUserIdSetMap - Map of Account (Customer Locations) Ids and set of users Ids that belong them

    @return void
    */
    private static void getAllCustomerLocationsUsers(Set<Id> ownersCustomerLocation, Map<Id, Set<Id>> customerLocationIdWithUserIdSetMap){

        for(User u : (UserUtility.getCommunityUsersByAccountIds(ownersCustomerLocation)).values()){

            //If the key in the map doesn't exist put it with the user Id in a new set in the map
            //otherwise just add the user id in the set
            if(!customerLocationIdWithUserIdSetMap.containsKey(u.AccountId)){
                customerLocationIdWithUserIdSetMap.put(u.AccountId, new Set<Id>{u.Id});
            } else{
                (customerLocationIdWithUserIdSetMap.get(u.AccountId)).add(u.Id);
            }
        }
    }

    /* @Description

    Populate the commercialCustomersIdWithManagersIdSetMap

    @param ownersCommercialCustomer - Set of Account Ids of opportunities parent accounts
    @param commercialCustomersIdWithManagersIdSetMap - Map of Account (Commercial Customers) Ids and set of manager users Ids that belong them 

    @return void
    */
    private static void getAllCommercialCustomerManagersUsers(Set<Id> ownersCommercialCustomer, Map<Id, Set<Id>> commercialCustomersIdWithManagersIdSetMap){

        for(User u : DAOUtilityWithoutShar.getAllPartnerManagersFromCommercialCustomers(ownersCommercialCustomer)){

            //If the key in the map doesn't exist put it with the user Id in a new set in the map
            //otherwise just add the user id in the set
            if(!commercialCustomersIdWithManagersIdSetMap.containsKey(u.Account.ParentId)){
                commercialCustomersIdWithManagersIdSetMap.put(u.Account.ParentId, new Set<Id>{u.Id});
            } else{
                (commercialCustomersIdWithManagersIdSetMap.get(u.Account.ParentId)).add(u.Id);
            }
        }
    }

    /* @Description

    Populate the commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers

    @param ownersCommercialCustomer - Set of Account Ids of opportunities parent accounts
    @param billingCountries - Set of Billing Countries to consider
    @param commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers - Map of a key (Account (CommercialCustomer) Id + Account (Customer Location) Billing Country) and users Ids with Additional Country Responsability of that country

    @return void
    */
    private static void getAllAdditionalCountryResponsibilityCommercialCustomerUsers(Set<Id> ownersCommercialCustomer, Set<String> billingCountries, Map<String, Set<Id>> commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers){

        for(User u : DAOUtilityWithoutShar.getAllAdditionalCountryResponsibilityPartnerUsersFromCommercialCustomers(ownersCommercialCustomer, billingCountries)){

            //For each country: If the key in the map doesn't exist put it with the user Id in a new set in the map
            //otherwise just add the user id in the set
            for(String country : u.Contact.Additional_Country_Responsibility__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR)){
                if(!commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.containsKey(u.Account.ParentId + country)){
                    commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.put(u.Account.ParentId + country, new Set<Id>{u.Id});
                } else {
                    commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(u.Account.ParentId + country).add(u.Id);
                }
            }
        }
    }

    /* @Description

    Put in oppsIdsToShareWithUsersIdMap all users from its customer location for that opportunity Id

    @param o - Opportunity SObject to populate its list of user Ids to share
    @param customerLocationIdWithUserIdSetMap - Map of Account (Customer Locations) Ids and set of users Ids that belong them
    @param oppsIdsToShareWithUsersIdMap - Map of Opportunities Ids and list of users to share with 

    @return void
    */
    private static void putAllCustomerLocationUsersToShareOpportunities(Opportunity o, Map<Id, Set<Id>> customerLocationIdWithUserIdSetMap, Map<Id, Set<Id>> oppsIdsToShareWithUsersIdMap){

        //If the key in the map doesn't exist put it with the users set in the map
        //otherwise just add all set to the existing set
        if(!oppsIdsToShareWithUsersIdMap.containsKey(o.Id) && customerLocationIdWithUserIdSetMap.get(o.AccountId) != null){
            oppsIdsToShareWithUsersIdMap.put(o.Id, customerLocationIdWithUserIdSetMap.get(o.AccountId).clone());
        } else if(customerLocationIdWithUserIdSetMap.get(o.AccountId) != null){
            (oppsIdsToShareWithUsersIdMap.get(o.Id)).addAll(customerLocationIdWithUserIdSetMap.get(o.AccountId).clone());
        }
    }

    /* @Description

    Put in oppsIdsToShareWithUsersIdMap all manager users from its commercial customer for that opportunity Id

    @param o - Opportunity SObject to populate its list of user Ids to share with
    @param commercialCustomersIdWithManagersIdSetMap - Map of Account (Commercial Customers) Ids and set of manager users Ids that belong them
    @param oppsIdsToShareWithUsersIdMap - Map of Opportunities Ids and list of users to share with 

    @return void
    */
    private static void putAllCommercialCustomerManagersToShareOpportunities(Opportunity o, Map<Id, Set<Id>> commercialCustomersIdWithManagersIdSetMap, Map<Id, Set<Id>> oppsIdsToShareWithUsersIdMap){

        //If the key in the map doesn't exist put it with the users set in the map
        //otherwise just add all set to the existing set
        if(!oppsIdsToShareWithUsersIdMap.containsKey(o.Id) && commercialCustomersIdWithManagersIdSetMap.get(o.Parent_Account__c) != null){
            oppsIdsToShareWithUsersIdMap.put(o.Id, commercialCustomersIdWithManagersIdSetMap.get(o.Parent_Account__c).clone());
        } else if(commercialCustomersIdWithManagersIdSetMap.get(o.Parent_Account__c) != null){
            (oppsIdsToShareWithUsersIdMap.get(o.Id)).addAll(commercialCustomersIdWithManagersIdSetMap.get(o.Parent_Account__c).clone());
        }
    }

    /* @Description

    Put in oppsIdsToShareWithUsersIdMap all additional country responsability users from its commercial customer for that opportunity customer location country for that opportunity Id

    @param o - Opportunity SObject to populate its list of user Ids to share with
    @param commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers - Map of a key (Account (CommercialCustomer) Id + Account (Customer Location) Billing Country) and users Ids with Additional Country Responsability of that country
    @param oppsIdsToShareWithUsersIdMap - Map of Opportunities Ids and list of users to share with 

    @return void
    */
    private static void putAllCommercialCustomerAdditionalCountryResponsabilityUsersToShareOpportunities(Opportunity o, Map<String, Set<Id>> commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers, Map<Id, Set<Id>> oppsIdsToShareWithUsersIdMap){
        
        //If the key in the map doesn't exist put it with the users set in the map
        //otherwise just add all set to the existing set
        if(!oppsIdsToShareWithUsersIdMap.containsKey(o.Id) && commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(o.Parent_Account__c + o.Account.BillingCountry) != null){
            oppsIdsToShareWithUsersIdMap.put(o.Id, commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(o.Parent_Account__c + o.Account.BillingCountry).clone());
        } else if(commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(o.Parent_Account__c + o.Account.BillingCountry) != null){
            (oppsIdsToShareWithUsersIdMap.get(o.Id)).addAll(commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(o.Parent_Account__c + o.Account.BillingCountry).clone());
        }
    }

    /* @Description

    Method to remove the opportunity owner from the set to avoid insufficient access rights error

    @param o - Opportunity SObject to get its list of user Ids to share with
    @param oppsIdsToShareWithUsersIdMap - Map of Opportunities Ids and list of users to share with 

    @return void
    */
    private static void removeOpportunityOwnerFromSet(Opportunity o, Map<Id, Set<Id>> oppsIdsToShareWithUsersIdMap){

        oppsIdsToShareWithUsersIdMap.get(o.Id).remove(o.OwnerId);
    }

    /* @Description

    Check if the account needs to recalculate their open opportunities sharing after update

    @param newAcc - New account to compare
    @param oldAcc - Old account to compare

    @return Boolean - True of false if the related open opportunities of that account is required to recalculate the sharing
    */
    private static Boolean isOpenOppsRecalculationRequiredToShareForAccount(Account newAcc, Account oldAcc){
        return newAcc.OwnerId != oldAcc.OwnerId;
    }
    
    private static void getAdditionalCustomerLocationsUsers(){
        
    }
}