/*      
@Name                  CaseSharingUtility
@Author                Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           04-08-2019
@UsedBy                CaseTriggerHandler, ContactSharingUtility, UserSharingUtility
@Description           Class to give and revoke case access to Partner Community Users
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 15.01.2021 | Updated to meet the new sharing requirements of the account redesign
*/
public without sharing class CaseSharingUtility {

    /* @Description

    Method to recalculate case sharing on update trigger

    @param newCases - Case list of updated new cases (Trigger.new)
    @param usersToConsider - A Map of User Id and User SObject of Partner Community Users to consider to revoke case access

    @return void
    */
    public static void recalculateCaseSharingOnCaseUpdate(List<Case> newCases, Map<Id,User> usersToConsider){

        Set<Id> casesIdsToRecalculate = new Set<Id>(); //Set of Case Ids to recalculate the sharing

        //Check which cases case elegible to recalculate
        for (Case cs : newCases) {
            if (isRecalculationRequiredToShare((Case)trigger.OldMap.get(cs.Id), cs)) {
                casesIdsToRecalculate.add(cs.Id);
            }
        }

        //Recalculate the sharing
        if(!casesIdsToRecalculate.isEmpty()){
            deleteAllCasesRelatedSharing(usersToConsider.keySet(), casesIdsToRecalculate);
            createSharingForCase(casesIdsToRecalculate);
        }

    }

    /* @Description

    Method to recalculate case sharing on insert trigger

    @param newCases - Case list of created new cases (Trigger.new)

    @return void
    */
    public static void recalculateCaseSharingOnCaseCreate(List<Case> casesIdsToRecalculate){

        createSharingForCase((new Map<Id, Case>(casesIdsToRecalculate)).keySet());
    }

    /* @Description

    Future method to call createSharingForCase method

    @param casesIdsToRecalculate - A Set of cases Ids to recalculate the sharing

    @return void
    */
    @future
    public static void createSharingForCaseFuture(Set<Id> casesIdsToRecalculate){
        createSharingForCase(casesIdsToRecalculate);
    }

    /* @Description

    Method to create case sharing

    @param caseIdsToRecalculate - A Set of cases Ids to recalculate the sharing

    @return void
    */
    public static void createSharingForCase(Set<Id> casesIdsToRecalculate){

        List<Case> casesToRecalculate = new List<Case>(); //Set of Cases to recalculate the sharing
        Set<Id> ownersCustomerLocation = new Set<Id>(); //Set of Account Ids of cases accounts
        Set<Id> ownersCommercialCostumer = new Set<Id>(); //Set of Account Ids of cases parent accounts
        Set<String> billingCountries = new Set<String>(); //Set of countries of cases account billing countries
        Map<Id, Set<Id>> casesIdsToShareWithUsersIdMap = new Map<Id, Set<Id>>(); //Map of Cases Ids and list of users to share with  
        Map<Id, Set<Id>> customerLocationIdWithUserIdSetMap = new Map<Id, Set<Id>>(); //Map of Account (Customer Locations) Ids and set of users Ids that belong them
        Map<Id, Set<Id>> commercialCustomersIdWithManagersIdSetMap = new Map<Id, Set<Id>>(); //Map of Account (Commercial Customers) Ids and set of manager users Ids that belong them     
        Map<String, Set<Id>> commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers = new Map<String, Set<Id>>(); //Map of a key (Account (CommercialCustomer) Id + Account (Customer Location) Billing Country) and users Ids with Additional Country Responsability of that country
		Map<Id, Set<Id>> addCustLocsWithUserIdSetMap = new Map<Id, Set<Id>>();
        
        //Get cases information
        casesToRecalculate = DAOUtilityWithoutShar.getCasesForSharing(casesIdsToRecalculate);

        //Fill the sets with the cases information
        for(Case cs : casesToRecalculate){

            if(String.isNotBlank(cs.AccountId)){
                ownersCustomerLocation.add(cs.AccountId);
            }

            if(String.isNotBlank(cs.Parent_Account__c)){
                ownersCommercialCostumer.add(cs.Parent_Account__c);
            }
            
            if(String.isNotBlank(cs.Account.BillingCountry)){
                billingCountries.add(cs.Account.BillingCountry);
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
        if(!ownersCommercialCostumer.isEmpty())
            getAllCommercialCostumerManagersUsers(ownersCommercialCostumer, commercialCustomersIdWithManagersIdSetMap);

        //Fill the commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers map, the keys are commercial customers Ids + country name
        //and the values are lists users with that country additional responsabilities from that commercial customers
        if(!ownersCommercialCostumer.isEmpty() && !billingCountries.isEmpty())
            getAllAdditionalCountryResponsibilityCommercialCostumerUsers(ownersCommercialCostumer, billingCountries, commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers);

        //For each case put all customer location users, commercial customer managers and commercial customers with additional country 
        //responsability users in the caseIdsToShareWithUsersIdMap
        for(Case cs : casesToRecalculate){

            putAllCustomerLocationUsersToShareCases(cs, customerLocationIdWithUserIdSetMap, casesIdsToShareWithUsersIdMap);
            
            putAllCommercialCostumerManagersToShareCases(cs, commercialCustomersIdWithManagersIdSetMap, casesIdsToShareWithUsersIdMap);
            
            putAllCommercialCostumerAdditionalCountryResponsabilityUsersToShareCases(cs, commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers, casesIdsToShareWithUsersIdMap);            

            putAllCustomerLocationUsersToShareCases(cs, addCustLocsWithUserIdSetMap, casesIdsToShareWithUsersIdMap);
            
            //Remove case owners from set to avoid insufficient access rights error
            if(casesIdsToShareWithUsersIdMap.containsKey(cs.Id) && !casesIdsToShareWithUsersIdMap.get(cs.Id).isEmpty()){
                removeCaseOwnerFromSet(cs, casesIdsToShareWithUsersIdMap);
            }
        }

        //Insert CaseShare records
        if(!casesIdsToShareWithUsersIdMap.isEmpty()){
            createCaseSharing(casesIdsToShareWithUsersIdMap);
        }
    }

    /* @Description

    Method to insert CaseShare records

    @param casesIdsToShareWithUsersIdMap - Map of Cases Ids and list of users to share with

    @return void
    */
    public static void createCaseSharing(Map<Id, Set<Id>> casesIdsToShareWithUsersIdMap){

        List<CaseShare> caseShareList = new List<CaseShare>();

        //For each case, for each user that have to get access for that case: create one CaseShare record
        for(Id caseId : casesIdsToShareWithUsersIdMap.keySet()){
            for(Id uId : casesIdsToShareWithUsersIdMap.get(caseId)){
                caseShareList.add(createShareCaseRecord(new User(Id = uId), new Case(Id = caseId)));
            }
        }

        //Insert the CaseShare records without sharing to avoid insufficient access rights error
        DAOUtilityWithoutShar.insertWithoutAccess(caseShareList);
    }

    /* @Description

    Method to get all cases related to accounts

    @param AccountIds - Set of Account Ids to get cases related

    @return List<Case> Cases list related of that accounts
    */
    public static List<Case> allCasesRelatedToAccounts(Set<Id> AccountIds){
        
        return [
                SELECT Id, Parent_Account__c, AccountId, OwnerId
                FROM Case
                WHERE Parent_Account__c != null AND
                AccountId != null AND
                 (Parent_Account__c IN :AccountIds 
                OR AccountId IN :AccountIds)
        ];
    }

    /* @Description

    Method to delete all CaseShare records

    @param usersIds - Set of user Ids to revoke cases manual sharing
    @param casesIdsToRevokeAccess - Set of cases Ids to consider to revoke manual sharing

    @return void
    */
    public static void deleteAllCasesRelatedSharing(Set<Id> usersIds, Set<Id> casesIdsToRevokeAccess) {       
        
        //Delete the CaseShare records without sharing to avoid insufficient access rights error
        DAOUtilityWithoutShar.deleteWithoutAccess([
                SELECT Id 
                FROM CaseShare 
                WHERE UserOrGroupId IN :usersIds AND
                      RowCause = :Constants.SHARE_ROW_CAUSE_MANUAL AND
                      CaseId IN :casesIdsToRevokeAccess
        ]);
    }
    
    /* @Description

    Method to create an instance of CaseShare

    @param us - User SObject to create the CaseShare
    @param csObj - Case SObject to create the CaseShare

    @return CaseShare - CaseShare record with fields populated(RowCause = Manual and AccessLevel = Edit)
    */
    public static CaseShare createShareCaseRecord(User us, Case csObj){
        return new CaseShare(
                CaseId = csObj.Id,
                RowCause = Constants.SHARE_ROW_CAUSE_MANUAL,
                CaseAccessLevel = Constants.SHARE_ACCESS_LEVEL_EDIT,
                UserOrGroupId = us.Id
        );
    }
    
    /* @Description

    Check if the case needs to recalculate its sharing after update

    @param oldCase - Old Case SObject to compare
    @param newCase - New Case SObject to compare

    @return Boolean - True of false if the Case is required to share
    */
    private static Boolean isRecalculationRequiredToShare(Case oldCase,Case newCase){
        return 
            oldCase.AccountId != newCase.AccountId ||
            oldCase.OwnerId != newCase.OwnerId;
    }
    
    /* @Description

    Populate the customerLocationIdWithUserIdSetMap

    @param ownersCustomerLocation - Set of Account Ids of case accounts
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

    @param ownersCommercialCustomer - Set of Account Ids of cases parent accounts
    @param commercialCustomersIdWithManagersIdSetMap - Map of Account (Commercial Customers) Ids and set of manager users Ids that belong them 

    @return void
    */
    private static void getAllCommercialCostumerManagersUsers(Set<Id> ownersCommercialCostumer, Map<Id, Set<Id>> commercialCustomersIdWithManagersIdSetMap){

        for(User u : DAOUtilityWithoutShar.getAllPartnerManagersFromCommercialCustomers(ownersCommercialCostumer)){

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

    @param ownersCommercialCustomer - Set of Account Ids of cases parent accounts
    @param billingCountries - Set of Billing Countries to consider
    @param commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers - Map of a key (Account (CommercialCustomer) Id + Account (Customer Location) Billing Country) and users Ids with Additional Country Responsability of that country

    @return void
    */
    private static void getAllAdditionalCountryResponsibilityCommercialCostumerUsers(Set<Id> ownersCommercialCostumer, Set<String> billingCountries, Map<String, Set<Id>> commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers){

        for(User u : DAOUtilityWithoutShar.getAllAdditionalCountryResponsibilityPartnerUsersFromCommercialCustomers(ownersCommercialCostumer, billingCountries)){

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

    Put in casesIdsToShareWithUsersIdMap all users from its customer location for that case id

    @param cs - Case SObject to populate its list of user Ids to share
    @param customerLocationIdWithUserIdSetMap - Map of Account (Customer Locations) Ids and set of users Ids that belong them
    @param caseIdsToShareWithUsersIdMap - Map of Case Ids and list of users to share with 

    @return void
    */
    private static void putAllCustomerLocationUsersToShareCases(Case cs, Map<Id, Set<Id>> customerLocationIdWithUserIdSetMap, Map<Id, Set<Id>> casesIdsToShareWithUsersIdMap){

        //If the key in the map doesn't exist put it with the users set in the map
        //otherwise just add all set to the existing set
        if(!casesIdsToShareWithUsersIdMap.containsKey(cs.Id) && customerLocationIdWithUserIdSetMap.get(cs.AccountId) != null){
            casesIdsToShareWithUsersIdMap.put(cs.Id, customerLocationIdWithUserIdSetMap.get(cs.AccountId).clone());
        } else if(customerLocationIdWithUserIdSetMap.get(cs.AccountId) != null){
            (casesIdsToShareWithUsersIdMap.get(cs.Id)).addAll(customerLocationIdWithUserIdSetMap.get(cs.AccountId).clone());
        }
    }

    /* @Description

    Put in caseIdsToShareWithUsersIdMap all manager users from its commercial customer for that case Id

    @param cs - Case SObject to populate its list of user Ids to share with
    @param commercialCustomersIdWithManagersIdSetMap - Map of Account (Commercial Customers) Ids and set of manager users Ids that belong them
    @param caseIdsToShareWithUsersIdMap - Map of Case Ids and list of users to share with 

    @return void
    */
    private static void putAllCommercialCostumerManagersToShareCases(Case cs, Map<Id, Set<Id>> commercialCustomersIdWithManagersIdSetMap, Map<Id, Set<Id>> casesIdsToShareWithUsersIdMap){

        //If the key in the map doesn't exist put it with the users set in the map
        //otherwise just add all set to the existing set
        if(!casesIdsToShareWithUsersIdMap.containsKey(cs.Id) && commercialCustomersIdWithManagersIdSetMap.get(cs.Parent_Account__c) != null){
            casesIdsToShareWithUsersIdMap.put(cs.Id, commercialCustomersIdWithManagersIdSetMap.get(cs.Parent_Account__c).clone());
        } else if(commercialCustomersIdWithManagersIdSetMap.get(cs.Parent_Account__c) != null){
            (casesIdsToShareWithUsersIdMap.get(cs.Id)).addAll(commercialCustomersIdWithManagersIdSetMap.get(cs.Parent_Account__c).clone());
        }
    }

    /* @Description

    Put in caseIdsToShareWithUsersIdMap all additional country responsaility users from its commercial customer for that case custome location country for that case Id
    
    @param cs - Case SObject to populate its list of user Ids to share with
    @param commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers - Map of a key (Account (CommercialCustomer) Id + Account (Customer Location) Billing Country) and users Ids with Additional Country Responsability of that country
    @param caseIdsToShareWithUsersIdMap - Map of Case Ids and list of users to share with 

    @return void
    */
    private static void putAllCommercialCostumerAdditionalCountryResponsabilityUsersToShareCases(Case cs, Map<String, Set<Id>> commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers, Map<Id, Set<Id>> casesIdsToShareWithUsersIdMap){
        
        //If the key in the map doesn't exist put it with the users set in the map
        //otherwise just add all set to the existing set
        if(!casesIdsToShareWithUsersIdMap.containsKey(cs.Id) && commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(cs.Parent_Account__c + cs.Account.BillingCountry) != null){
            casesIdsToShareWithUsersIdMap.put(cs.Id, commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(cs.Parent_Account__c + cs.Account.BillingCountry).clone());
        } else if(commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(cs.Parent_Account__c + cs.Account.BillingCountry) != null){
            (casesIdsToShareWithUsersIdMap.get(cs.Id)).addAll(commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers.get(cs.Parent_Account__c + cs.Account.BillingCountry).clone());
        }
    }

    /* @Description

    Method to remove the case owner from the set to avoid insufficient access rights error
    
    @param cs - Case SObject to get its list of user Ids to share with
    @param caseIdsToShareWithUsersIdMap - Map of Case Ids and list of users to share with 

    @return void
    */
    private static void removeCaseOwnerFromSet(Case cs, Map<Id, Set<Id>> casesIdsToShareWithUsersIdMap){

        casesIdsToShareWithUsersIdMap.get(cs.Id).remove(cs.OwnerId);
    }    
}