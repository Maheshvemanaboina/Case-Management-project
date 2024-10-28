/**
* Created by KJM on 20/05/2019.
*/

public without sharing class UserUtility {
    private static User currentUserInstance;
    private static Contact currentContactInstance;
    
    public static List<User> getAllCommunityUsers() {
        return [
                SELECT  Id, Name, Username, Community_User_Role__c, Community_Account_Role__c, Country, Partner_User_Country__c,
                        Contact.Parent_Account__c,  Contact.AccountId, Contact.Business_Segment__c,Contact.Account.OwnerId,
                        Contact.Additional_Country_Responsibility__c, Contact.Sub_Segment__c,Contact.Account.Name,contact.Exclude_Customer_Location_Country__c
                FROM User
                WHERE ContactId != null
                AND IsPortalEnabled = true
                AND isActive = true
        ];
    }

    public static List<User> getAllPartnerCommunityUsers() {
        return [
                SELECT  Id, Name, Username, Community_User_Role__c, Community_Account_Role__c, Country, Partner_User_Country__c,
                        Contact.Parent_Account__c, Contact.Parent_Account__r.Name,  Contact.AccountId, Contact.Business_Segment__c,Contact.Account.OwnerId,
                        Contact.Additional_Country_Responsibility__c, Contact.Sub_Segment__c,Contact.Account.Name, contact.Exclude_Customer_Location_Country__c
                FROM User
                WHERE ContactId != null
                AND IsPortalEnabled = true
                AND isActive = true
                AND Profile.UserLicense.Name='Partner Community'
        ];
    }

    public static List<User> getAllPartnerCommunityUsersByContacts(Set<Id> ContactIds) {
        return [
                SELECT  Id, Name, Username, ContactId, Contact.Parent_Account__c, Community_User_Role__c, Community_Account_Role__c, Country, Partner_User_Country__c,
                        Contact.AccountId, Contact.Business_Segment__c, Contact.Account.BillingCountry,
                        Contact.Additional_Country_Responsibility__c, Contact.Sub_Segment__c, Contact.MailingCountry, Profile.Name, IsPortalEnabled
                FROM User
                WHERE ContactId != null
                AND IsPortalEnabled = true
                AND isActive = true
                AND Profile.UserLicense.Name='Partner Community'
            	AND (Profile.Name = 'FCI Distributor Community User' OR Profile.Name = 'FCI Distributor Community Restricted User')
                AND ContactId IN: ContactIds
        ];
    }

    public static User getCurrentUser() {
        if (currentUserInstance == null) {
            currentUserInstance = [
                SELECT  Id,
                ContactId,
                Partner_User_Country__c,
                Profile.Name,
                Account.Name,
                Contact.AccountId,
                Contact.Parent_Account__c,
                Contact.Account.RecordType.DeveloperName,
                IsPortalEnabled,
                Community_User_Role__c,
                Community_Account_Role__c,
                UserPermissionsKnowledgeUser
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
        }
        
        return currentUserInstance;
    }
    
    public static Contact getCurrentUserContact() {
        User currentUser = getCurrentUser();
        if( Test.isRunningTest() ){
            user usr = [SELECT  Id,ContactId,Partner_User_Country__c,Profile.Name,Account.Name,Contact.AccountId,Contact.Parent_Account__c,Contact.Account.RecordType.DeveloperName,
                IsPortalEnabled,Community_User_Role__c,Community_Account_Role__c,UserPermissionsKnowledgeUser FROM User WHERE Id = :UserInfo.getUserId()];
            currentContactInstance = [SELECT  Id,Name, MailingCity,Business_Segment__c,Sub_Segment__c, Region__c,
                   						Parent_Account__c,Parent_Account__r.OwnerId, AccountId,Account.OwnerId,Additional_Region_Responsibility__c,
                    					Additional_Country_Responsibility__c FROM Contact  WHERE Id = :usr.contactId ];                  
        }
        else{
                if (currentContactInstance == null) {
                	currentContactInstance = [
                    SELECT  Id,
                    Name,
                    MailingCity,
                    Business_Segment__c,
                    Sub_Segment__c,
                    Region__c,
                    Parent_Account__c,
                    Parent_Account__r.OwnerId,
                    AccountId,
                    Account.OwnerId,
                    Additional_Region_Responsibility__c,
                    Additional_Country_Responsibility__c
                    FROM Contact
                    WHERE Id = :currentUser.contactId
                ];
            }
        }       
        
        return currentContactInstance;
    }

    public static Boolean isUserStandardCommunityUser(User usr) {
        return String.isBlank(usr.Community_User_Role__c) ||
               usr.Community_User_Role__c.equals(Constants.COMMUNITY_USER_ROLE_STANDARD_USER);
    }

    public static Boolean isUserManagerCommunityUser(User usr) {
        return String.isNotBlank(usr.Community_User_Role__c) &&
               usr.Community_User_Role__c.equals(Constants.COMMUNITY_USER_ROLE_MANAGER_USER);
    }

    public static Boolean isCurrentUserPartnerUser() {
        return UserUtility.getCurrentUser().IsPortalEnabled;
    }

    public static Boolean isCurrentUserPartnerUser(User usr) {
        return usr.IsPortalEnabled;
    }
    
    public static List<String> getCurrentUserBusinessSegment() {
        return Utilities.splitPicklistValues(getCurrentUserContact().Business_Segment__c);
    }
    
    public static List<String> getCurrentUserSubSegment() {
        return Utilities.splitPicklistValues(getCurrentUserContact().Sub_Segment__c);
    }

    /*public static List<String> getCurrentUserApplication() {
        return Utilities.splitPicklistValues(getCurrentUserContact().Application__c);
    }*/

    public static List<String> getCurrentUserRegion() {
        Set<String> regions = new Set<String>();

        regions.addAll(Utilities.splitPicklistValues(getCurrentUserContact().Region__c));
        regions.addAll(Utilities.splitPicklistValues(getCurrentUserContact().Additional_Region_Responsibility__c));

        if (isUserCommunityManagerRole()) {

            for (Account customerLoc : getMUCommercialCustomerHierarchyWrapper(new List<User>{getCurrentUser()}).get(getCurrentUser().Id).customerLocations) {
                if (String.isBlank(customerLoc.Sales_Region__c)) {
                    continue;
                }

                regions.add(customerLoc.Sales_Region__c);
            }
        }

        List<String> regionsLst = new List<String>();
        regionsLst.addAll(regions);
        return regionsLst;
    }

    public static Boolean isUserCommunityManagerRole() {
        return getCurrentUser().Community_User_Role__c != null &&
               getCurrentUser().Community_User_Role__c.equalsIgnoreCase(Constants.COMMUNITY_USER_ROLE_MANAGER_USER) ? true : false;
    }
    
    // Map<userId, wrapper>
    public static Map<String, CommercialCustomerHierarchyWrapper> getMUCommercialCustomerHierarchyWrapper(List<User> users) {

        /*List<User> userList = [ SELECT  Id,
        ContactId,
        Partner_User_Country__c,
        Profile.Name,
        Account.Name,
        Contact.AccountId,
        Contact.Parent_Account__c,
        IsPortalEnabled,
        Community_User_Role__c,
        Community_Account_Role__c,
        UserPermissionsKnowledgeUser
        FROM User
        WHERE Id = :UserInfo.getUserId()];*/

        Set<String> commercialCustomersIds = new Set<String>();
        for (User usr : users) {

            if (isUserStandardCommunityUser(usr)) {
                continue;
            }

            commercialCustomersIds.add(usr.Contact.Parent_Account__c);
        }

        Map<Id, Account> commercialCustomers = new Map<Id, Account>([SELECT Id, Name, Sales_Region__c, (SELECT Id, Sales_Region__c, Name, BillingCountry FROM ChildAccounts) FROM Account WHERE Id IN :commercialCustomersIds]);

        Map<String, CommercialCustomerHierarchyWrapper> userAccountsToRet = new Map<String, CommercialCustomerHierarchyWrapper>();
        for (User usr : users) {
            if (isUserStandardCommunityUser(usr)) {
                continue;
            }
            
            if (!commercialCustomers.containsKey(usr.Contact.Parent_Account__c)) {
                continue;
            }
            
            userAccountsToRet.put(usr.Id, new CommercialCustomerHierarchyWrapper(commercialCustomers.get(usr.Contact.Parent_Account__c), commercialCustomers.get(usr.Contact.Parent_Account__c).ChildAccounts));
        }
        
        return userAccountsToRet;
    }
    
    public class CommercialCustomerHierarchyWrapper {
        public Account commercialCustomer { get; private set; }
        public List<Account> customerLocations { get; private set; }
        public List<String> customerLocationsCountries { get; private set; }
        public Set<Id> customerLocationsIds { get; private set; }
        
        public CommercialCustomerHierarchyWrapper(Account commercialCustomer, List<Account> customerLocations) {
            this.commercialCustomer = commercialCustomer;
            this.customerLocations = customerLocations;
            this.customerLocationsCountries = getRelatedCountries();
            this.customerLocationsIds = getCustomerLocationsIds();
        }
        
        private List<String> getRelatedCountries() {
            List<String> countries = new List<String>();
            for (Account acc : customerLocations) {
                countries.add(acc.BillingCountry);
            }
            return countries;
        }
        
        private Set<Id> getCustomerLocationsIds() {
            Set<Id> ids = new Set<Id>();
            for (Account acc : customerLocations) {
                ids.add(acc.Id);
            }
            return ids;
        }
    }
    
    public static Map<Id, User> getAllSelectedCommunityUsers(List<User> userList){
        return new Map<Id, User>([
                SELECT Id, Name, Contact.Account.BillingCountry, Contact.AccountId, Contact.Account.Name, Contact.Parent_Account__c, Community_User_Role__c,
                Contact.Business_Segment__c, Contact.Sub_Segment__c, Contact.Additional_Country_Responsibility__c
                FROM User
                WHERE ContactId != null
                AND IsPortalEnabled = true
                AND Id IN: userList]
        );
    }
    
    public static Map<Id, User> getAllFilteredCommunityUsers(List<sObject> sObjList){
        Set<Id> accountids = new Set<Id>();

        Map<Id,User> communityUserMap = new Map<Id,User>();
        if(sObjList.getSObjectType().getDescribe().getName().equals(Constants.OBJECT_NAME_ACCOUNT)){
            for(Account acc : (List<Account>)sObjList){
                accountids.add(acc.Id);
                if(acc.ParentId != null){
                    accountids.add(acc.ParentId);
                }
                
                /*Temporary Solution*/
                if(acc.RecordTypeId == Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID){
                    accountids.add(acc.Distributor__c);
                    accountids.add(acc.Distributor_Location__c);
                }
            }
            
            
        }

        if(sObjList.getSObjectType().getDescribe().getName().equals(Constants.OBJECT_NAME_OPPORTUNITY)){
            Set<Id> commercialCostumerIds = new Set<Id>();
            for(Opportunity opp : (List<Opportunity>)sObjList){
                if(String.isNotBlank(opp.Parent_Account__c)){
                    commercialCostumerIds.add(opp.Parent_Account__c);
                }
            }

            accountids.addAll((new Map<Id, Account>([SELECT Id FROM Account WHERE ParentId IN : commercialCostumerIds AND ParentId != null])).keySet());
        }

        if(sObjList.getSObjectType().getDescribe().getName().equals(Constants.OBJECT_NAME_CASE)){
            Set<Id> commercialCostumerIds = new Set<Id>();
            for(Case cs : (List<Case>)sObjList){
                if(String.isNotBlank(cs.Parent_Account__c)){
                    commercialCostumerIds.add(cs.Parent_Account__c);
                }
            }

            accountids.addAll((new Map<Id, Account>([SELECT Id FROM Account WHERE ParentId IN : commercialCostumerIds AND ParentId != null])).keySet());
        }

        if(sObjList.getSObjectType().getDescribe().getName().equals(Constants.OBJECT_NAME_CONTRACT)){
            Set<Id> commercialCostumerIds = new Set<Id>();
            for(Contract con : (List<Contract>)sObjList){
                if(String.isNotBlank(con.Parent_Account__c)){
                    commercialCostumerIds.add(con.Parent_Account__c);
                }
            }

            accountids.addAll((new Map<Id, Account>([SELECT Id FROM Account WHERE ParentId IN : commercialCostumerIds AND ParentId != null])).keySet());
        }

        if(!accountids.isEmpty()){
            communityUserMap = getCommunityUsersByAccountIds(accountids);
        }
        return communityUserMap;
    }

    public static Map<Id, User> getCommunityUsersByAccountIds(Set<Id> accountIds){

        Map<Id,User> communityUserMap;
        if(!accountIds.isEmpty()){
            communityUserMap = new Map<Id,User>([
                SELECT Id, userName, Contact.Parent_Account__c, AccountId, Contact.AccountId, Contact.Account.ParentId, Community_User_Role__c, IsPortalEnabled, Contact.Additional_Country_Responsibility__c
                FROM User
                WHERE IsPortalEnabled = true
                AND ContactId != null
                AND ( Contact.AccountId IN: accountIds OR Contact.Parent_Account__c IN:accountIds )
                //AND ( Contact.Work_Location__c IN: accountIds OR Contact.AccountId IN:accountIds )
                //AND ( (Contact.Work_Location__c IN: accountIds AND Community_User_Role__c =: Constants.COMMUNITY_USER_ROLE_STANDARD_USER ) OR ( Contact.AccountId IN:accountIds AND Community_User_Role__c =: Constants.COMMUNITY_USER_ROLE_MANAGER_USER) )
                AND isActive = true
            ]);
        }else{
            communityUserMap = new Map<Id,User>();
        }

        return communityUserMap;
    }

    public static Map<Id,User> getFCISMUsersByAccountIds(Set<Id> accountIds){

        Map<Id,User> FCIAccountUserMap = new Map<Id,User>();
        
        if(!accountIds.isEmpty()){
            for(Account custLoc : [SELECT Id, OwnerId, Owner.IsPortalEnabled
                                    FROM Account
                                    WHERE RecordTypeId =: Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID
                                    AND Id IN:accountIds]){
                
                FCIAccountUserMap.put(custLoc.Id, new User(Id = custLoc.OwnerId, IsPortalEnabled = custLoc.Owner.IsPortalEnabled));    

            }
        }

        return FCIAccountUserMap;
    }

    public static Boolean checkUserAccessToApexClass(String apexClassName, Id currentUserProfileId){
        
        Boolean HAS_APEX_CLASS_ACCESS = false;
        Set<Id> setupAccessList = new Set<Id>();
        Id apexclassId = [SELECT Id FROM ApexClass WHERE Name =: apexClassName].Id;
        List<SetupEntityAccess> apexClassAccesses = [SELECT ParentId, SetupEntityId FROM SetupEntityAccess 
                                                    WHERE SetupEntityType = 'ApexClass' AND SetupEntityId =: apexclassId];

        for(SetupEntityAccess eachApexAccess : apexClassAccesses){
            setupAccessList.add(eachApexAccess.ParentId);    
        }
	
        List<Id> profileIds = new List<Id>();
        List<PermissionSet> permissionSets = [SELECT Id,ProfileId FROM PermissionSet WHERE Id IN: setupAccessList];
        for(PermissionSet eachperm : permissionSets){
            
            if(!String.isBlank(eachperm.ProfileId)) profileIds.add(eachperm.ProfileId);
        }

        if(!profileIds.isEmpty() && profileIds.contains(currentUserProfileId)) HAS_APEX_CLASS_ACCESS = true;
        
        return HAS_APEX_CLASS_ACCESS;
    }

    public static Boolean checkIfUserHasAllAccessToKnowledge(Id currentUserId){

        Boolean USER_HAS_ALL_ACCESS = true;
        
        // if user is admin, return true as he will be having all access
        if(getCurrentUser().UserPermissionsKnowledgeUser && getCurrentUser().Profile.Name == 'System Administrator') 
            return USER_HAS_ALL_ACCESS;

        //Check if current user other than administrator has Knowledge User permissions checked
        if(!getCurrentUser().UserPermissionsKnowledgeUser) 
            return !USER_HAS_ALL_ACCESS;

        //Check if "Manage Knowledge Article permission is assigned to user or not"
        List<PermissionSetAssignment> permSetAssignList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name = 'Manage_Knowledge_Articles'];
        if(permSetAssignList.isEmpty()) 
            return !USER_HAS_ALL_ACCESS;

        return USER_HAS_ALL_ACCESS;
    }
    
    public static List<User> getAllCostumerLocationsPartnerUsers(Set<Id> costumerLocationsIdsSet){
        return [SELECT Id, 
        AccountId 
        FROM User WHERE 
        isActive = true AND 
        ContactId != null AND
        IsPortalEnabled = true AND
        AccountId IN: costumerLocationsIdsSet];
    }
}