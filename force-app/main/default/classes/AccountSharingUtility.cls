/*       
@Name           - AccountSharingUtility
@Author         - Krzysztof Magdowski | Email - krzysztof.magdowski@waeg.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 02-08-2019
@UsedBy         - 1. AccountTriggerHandler
                  2. AccountSharingRecalculation
                  3. ContactSharingUtility
                  4. UserSharingUtility

@Description    - Sharing Utility Class for Accounts
@Changes        - 1. Updated to share Account Directly with Distributors and not Account Mirror

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000005dHBKQA2  | krzysztof.magdowski@waeg.com          | 02-08-2019    | Created Class
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 20-01-2021    | Updated the class to include Sharing logic according to new Account design, moving all sharing from AccountMirror (Another object, replica of Account) to Account
*/

public with sharing class AccountSharingUtility {
    
    private static Set<Id> recordTypeIdsToShare = AccountUtility.getRecordTypeIdsofAccountToShareWithPortalUsers(); // Query all valid AccountRecordTypes to share with Community Users

    /* @Description
        Method Name : createAccountSharingOnAccountCreate(List<Account>)

        1. Only runs on After Insert
        2. Creates Account Sharing with Distributors only on Account Create
        
        @PARAMS
            1. NAME ( newAccounts ) => TYPE ( List<Account> ) => DESCRIPTION ( All new accounts coming from Trigger.New when accounts are created )
    */

    public static void createAccountSharingOnAccountCreate(List<Account> newAccounts){
        
        List<Account> accToRecalculate = new List<Account>(); // Only valid accounts to consider for recalculation

        for (Account acc : newAccounts) {

            if (isRecalculationRequiredToShare(acc)) { // Checks if the account is valid to be shared
                accToRecalculate.add(acc);
            } 
        }

        if(!accToRecalculate.isEmpty()){ // if not Empty, then initiate sharing

            /* Adding direct Sharing of accounts because partner end customer creation is causing problem if sharing happens through @future */
            createSharingForAccount((new Map<Id,User>(UserUtility.getAllCommunityUsers())).keySet(), (new Map<Id,Account>(accToRecalculate)).keySet());
        }
    }

    /* @Description
        Method Name : recalculateAccountSharingOnAccountUpdate(List<Account>)

        1. Only runs on After Update
        2. Reshares Account with Distributors only on Account Update
        3. Recalculates Opportunity and Case sharing if Account Sharing needs to be recalculated (This is required because as per standard salesforce functionality,
                when you delete Account Sharing from an user, the Opportunity and Case Sharing with row case Manual from that account and user is also deleted,
                so the Opportunity and Case sharing is required again)
        
        @PARAMS
            1. NAME ( newAccounts ) => TYPE ( List<Account> ) => DESCRIPTION ( All new accounts coming from Trigger.New when accounts are updated )
    */

    public static void recalculateAccountSharingOnAccountUpdate(List<Account> newAccounts){

        List<Account> accToRecalculate = new List<Account>();   // Stores the Accounts to recalculate Sharing
        List<Account> accToRevoke = new List<Account>();        // Stores the Accounts to revoke Sharing

        if(!System.isBatch()){

            for (Account acc : newAccounts) {
                if (isRecalculationRequiredToShare((Account)trigger.OldMap.get(acc.Id), acc)) {         // Checks if the account is valid to be shared
                    accToRecalculate.add(acc);
                }
    
                if(isRecalculationRequiredToRevoke((Account)trigger.OldMap.get(acc.Id), acc)){          // Checks if the account is valid to be revoked
                    accToRevoke.add(acc);
                }
            }
            
            if(!accToRevoke.isEmpty()){
                deleteAllAccountRelatedSharing(UserUtility.getAllCommunityUsers(),accToRevoke);         // Deletes Account Sharing
            }
            
            if(!accToRecalculate.isEmpty()){

                deleteAllAccountRelatedSharing(UserUtility.getAllCommunityUsers(), accToRecalculate);   // Deletes Account Sharing
                Set<Id> accountIds = new Map<Id, Account>(accToRecalculate).keySet();
                Set<Id> userIds		= new Map<Id,User>(UserUtility.getAllCommunityUsers()).keySet();  
                
                //createSharingOnAccountUpdate(userIds, accountIds);
                if(!system.isFuture()){
                    createSharingOnAccountUpdate(userIds, accountIds);
                }else if(system.isFuture()){
                    createSharingForAccount(userIds, accountIds);// Initiates Account Sharing for Community
                    OpportunitySharingUtility.createOpportunitySharing(new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(accountIds)).keySet()); //Recreates Opportunity Sharing due to Account Sharing Deletion
                    CaseSharingUtility.createSharingForCase(new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(accountIds)).keySet()); //Recreates Case Sharing due to Account Sharing Deletion
                }
            }
        }
    }
    
    /* @Description
        Method Name : createSharingOnAccountUpdate( Set<Id> , Set<Id> )

        1. This will call the non-future sharing methods to start sharing Accounts, Cases, Opportunities.
		2. Due to Account Sharing deletion, Opportunities & Case sharing are also deleted for the partner users. So Opportunity & Case sharing re-triggered again.
        
        @PARAMS
            1. NAME ( usersIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All UserIds to be considered for Sharing )
            1. NAME ( accountsIds ) => TYPE ( Set<Id> ) => DESCRIPTION ( All accountIds to be considered for Sharing )
    */

    @future
    public static void createSharingOnAccountUpdate(Set<Id> userIds, Set<Id> accountIds) {

        createSharingForAccount(userIds, accountIds);// Initiates Account Sharing for Community
        OpportunitySharingUtility.createOpportunitySharing(new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(accountIds)).keySet()); //Recreates Opportunity Sharing due to Account Sharing Deletion
        CaseSharingUtility.createSharingForCase(new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(accountIds)).keySet()); //Recreates Case Sharing due to Account Sharing Deletion
        
    }
    

    /* @Description
        Method Name : initiateAccountSharing( List<User> , List<Account> )

        1. This will initiate the account Sharing for community users and Accounts passed to this method
        
        @PARAMS
            1. NAME ( userList )    => TYPE ( List<User> )      => DESCRIPTION ( All active community users queried from UserUtility class )
            1. NAME ( accountList ) => TYPE ( List<Account> )   => DESCRIPTION ( All valid accounts to be considered for sharing )
    */

    public static void initiateAccountSharing(List<User> userList, List<Account> accountList){

        Set<Id> usersIds = new Set<Id>();       // separates all the User Ids from the userList

        for (User usr : userList) {
            usersIds.add(usr.Id);
        }

        Set<Id> accountsIds = new Set<Id>();    // separates all the Account Ids from the accountList

        for (Account acc : accountList) {
            accountsIds.add(acc.Id);
        }

        createSharingForAccountFuture(usersIds, accountsIds); // Calls future method to initiate sharing
    } 

    /* @Description
        Method Name : createSharingForAccountFuture( Set<Id> , Set<Id> )

        1. This will call the non-future sharing class to start sharing
        
        @PARAMS
            1. NAME ( usersIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All UserIds to be considered for Sharing )
            1. NAME ( accountsIds ) => TYPE ( Set<Id> ) => DESCRIPTION ( All accountIds to be considered for Sharing )
    */

    @future
    public static void createSharingForAccountFuture(Set<Id> usersIds, Set<Id> accountsIds) {
        createSharingForAccount(usersIds, accountsIds);
    }

    /* @Description
        Method Name : createSharingForAccount( Set<Id> , Set<Id> )

        1. This is the non-future sharing class to start sharing
        2. This class is separate because it is also called from AccountSharingRecalculation Batch and future cannot be called from batch and hence it is separated
        
        @PARAMS
            1. NAME ( usersIds )    => TYPE ( Set<Id> ) => DESCRIPTION ( All UserIds to be considered for Sharing )
            1. NAME ( accountsIds ) => TYPE ( Set<Id> ) => DESCRIPTION ( All accountIds to be considered for Sharing )
    */

    public static void createSharingForAccount(Set<Id> usersIds, Set<Id> accountsIds) {

        // Query all community Users from the userIds
        List<User> users = DAOUtilityWithoutShar.getUsersForSharing(usersIds);

        // Map of UserId , All the info about the H5s and Commercial customer for partner contact
        Map<String, UserUtility.CommercialCustomerHierarchyWrapper> mUCommercialCustomerMap = UserUtility.getMUCommercialCustomerHierarchyWrapper(users);

        // Query all Users from the accountsIds
        // This is fetched from the class "DAOUtilityWithoutShar" because it is fetched without sharing
        List<Account> accountList = DAOUtilityWithoutShar.getAccountsForSharing(accountsIds);
        
        //Get Additional Customer Locations of the users' associated contacts
        Map<Id, Set<Id>> userAdditionalCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(users);
        system.debug('userAdditionalCustLocsMap >>> '+userAdditionalCustLocsMap);
        system.debug('accountList >>> '+accountList);
        // All accountShares to insert
        List<AccountShare> accountShares = new List<AccountShare>();
        for (Account acc : accountList) {

            // convert the business segment, sub-segment, application values into List<String>
            List<String> businessSegments = acc.Business_Segment__c == null ? new List<String>() : acc.Business_Segment__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR);
            List<String> subSegments = acc.Sub_Segment__c == null ? new List<String>() : acc.Sub_Segment__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR);
            //List<String> applications = acc.Application__c == null ? new List<String>() : acc.Application__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR);

            for (User currUser : users) {        

                    //Skip sharing if user already owns the account.
                    if (acc.OwnerId.equals(currUser.Id)) {
                        continue;
                    }

                    AccountShare accShare; 

                    // Checks if current user is standard user and initiates sharing for it or else initiate sharing for Manager user
                    if (UserUtility.isUserStandardCommunityUser(currUser)) { // Checks if a user is Standard User
                        accShare = createSharingForStandardUser(currUser, acc, businessSegments, subSegments/*, applications*/, userAdditionalCustLocsMap);
                    } else {
                        accShare = createSharingForManagerUser(currUser, acc, businessSegments, subSegments, /*applications,*/ mUCommercialCustomerMap);
                    }

                    if (accShare == null) { // if no condition satisfies continue the iteration
                        continue;
                    }

                    if(!accountShares.contains(accShare)){ // checks if the accountShare is already present in the accountShares list and is also already shared with the user.
                        accountShares.add(accShare);
                    }   
            }
        }

        // Insert AccountShares and is done in class "DAOUtilityWithoutShar" and is done using without sharing access.
        DAOUtilityWithoutShar.insertWithoutAccess(accountShares);
    }
    
    /* @Description
        Method Name : deleteAllAccountRelatedSharing( List<User> )

        1. This is used to delete AccountShare passing the users
        
        @PARAMS
            1. NAME ( users )   => TYPE ( List<User> ) => DESCRIPTION ( All users to be considered for deletion )
    */

    public static void deleteAllAccountRelatedSharing(List<User> users) {
        
        DAOUtilityWithoutShar.deleteWithoutAccess([
                SELECT Id
                FROM AccountShare
                WHERE UserOrGroupId IN :users AND
                RowCause = :Constants.SHARE_ROW_CAUSE_MANUAL
        ]);
    }
    
    /* @Description
        Method Name : deleteAllAccountRelatedSharing( List<User> , List<Account> )

        1. This is used to delete AccountShare for Users & Accounts
        
        @PARAMS
            1. NAME ( users )               => TYPE ( List<User> )      => DESCRIPTION ( All users to be considered for deletion )
            2. NAME ( accsToRevokeAccess )  => TYPE ( List<Account> )   => DESCRIPTION ( All Accounts to be considered for deletion )
    */

    public static void deleteAllAccountRelatedSharing(List<User> users, List<Account> accsToRevokeAccess) {
        
        DAOUtilityWithoutShar.deleteWithoutAccess([
                SELECT Id
                FROM AccountShare
                WHERE UserOrGroupId IN :users AND
                AccountId IN :accsToRevokeAccess AND
                RowCause = :Constants.SHARE_ROW_CAUSE_MANUAL
        ]);
    }

    /* @Description
        Method Name : createSharingForStandardUser( User , Account , List<String> , List<String> , List<String> )

        1. Code to create Sharing for Standard community users
        
        @PARAMS
            1. NAME ( currUser )        => TYPE ( User )            => DESCRIPTION ( Current Standard User )
            2. NAME ( acc )             => TYPE ( Account )         => DESCRIPTION ( Account to check for sharing with above standard User )
            3. NAME ( businessSegments )=> TYPE ( List<String> )    => DESCRIPTION ( Account's business Segments )
            4. NAME ( subSegments )     => TYPE ( List<Account> )   => DESCRIPTION ( Account's Sub Segments )
    */

    private static AccountShare createSharingForStandardUser(
        User currUser,
        Account acc,
        List<String> businessSegments,
        List<String> subSegments
        /*List<String> applications*/,
    	Map<Id, Set<Id>> userAddLocsMap){
            system.debug('entered sharing for standard user method');

            /* 
                Assigning default values to rowCause and AccessLevel 
                1. RowCause will always be "Manual" as we cannot create rowcause for standard objects
                2. accessLevel is always set to the most restricted one which is "Read" at first and then changed later based on scenarios
            */
            String accessRowCause = null;
            String accessLevel = Constants.SHARE_ACCESS_LEVEL_READ;

            /* This part does the check for Commercial Customer Sharing with Read Only access */

            if(isAccountCommercialCustomerAndEligibleToShare(currUser, acc)){
                accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
            }

            /* This part does the check for Additional Country Sharing for Accounts within same hierarchy */

            if(isCustomerLocationAdditionalCountryRelatedSU(currUser, acc)){
                accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
            }

            /* This part does the check for End Customer Account Sharing */
            /* Checks if an Account is End Customer */
            if(isAccountEndCustomer(acc)){
			system.debug('account is end customer');
                /*if (isRelatedCustomerLocationSU(currUser, accMirror)) {
                    accessRowCause = Constants.ACCOUNT_MIRROR_SHARE_ROW_CAUSE_CUSTOMER_LOCATION;
                    
                } else */

                //Checks if the End Customer's Distributor Location matches with Partner Contact's AccountId (H5)
                if(isEndCustomerRelatedToDistributorLocationSU(currUser, acc)) {

                    accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                    accessLevel = Constants.SHARE_ACCESS_LEVEL_EDIT;
                    
                }
                //Checks if the End Customer's BillingCountry is contained in Partner Contact's Additional Country Responsibility
                else if(isAdditionalCountryRelatedSU(currUser,acc)) {

                    accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;   
                }
                
                system.debug('userAddLocsMap >>> '+userAddLocsMap);
                if(isEndCustomerRelatedToAdditonalCustomerLocationSU(currUser,acc,userAddLocsMap)){
                    system.debug('line 332');
                    accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                    accessLevel = Constants.SHARE_ACCESS_LEVEL_EDIT;
                }
            }

            /* This part does the check for FCI Direct Customer Account Sharing */

            /* Checks if Account is a customer Location & a sold To */
            if(isAccountCustomerLocationAndSoldTo(acc)){
                /* 
                    As H5 is enabled as partner/customer, partner always gets access to that account
                    Hence, no need to share again
                */
                if(!isCustomerLocEqualsContactLocation(currUser, acc)){
                    
                    /* Should exclude the Customer location from sharing */
                    if( shouldExcludeCustomeLocAndCKA(currUser, acc)) {

                        return null;
                    }

                    /* Checks customer location's country with partner contact's country & Additional Country responsibility */
                    if (isCountryRelatedSU(currUser, acc)) {
                        /* Does this check if a user is Business Segment Responsible User */
                        if (isBusinessSegmentRelated(currUser, businessSegments)) {
                            accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                            
                        }

                        /* Does this check if a user is Sub Segment Responsible User */
                        else if (isSubSegmentRelated(currUser, businessSegments, subSegments)) {
                            accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                            
                        }

                        /* Does this check if a user is Application Responsible User */
                        /*else if (isApplicationRelated(currUser, businessSegments, subSegments, applications)) {
                            accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                            
                        }*/    
                    }
                }
            }
            
            /* Check if Account is Additional Customer Location added at user's associated contact*/
            if(!isCustomerLocEqualsContactLocation(currUser, acc) && isUsersAdditionalCustomerLocation(currUser, acc, userAddLocsMap)){
                system.debug('users additional cust loc');
                accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
            }

            if (String.isEmpty(accessRowCause)) {
                return null;
            }
        
            return getAccountShare(acc.Id, currUser.Id, accessLevel, accessRowCause);
    }

    /* @Description
        Method Name : createSharingForManagerUser( User , Account , List<String> , List<String> , List<String> , Map<String, UserUtility.CommercialCustomerHierarchyWrapper> )

        1. Code to create Sharing for Manager community users
        
        @PARAMS
            1. NAME ( currUser )                => TYPE ( User )            => DESCRIPTION ( Current Standard User )
            2. NAME ( acc )                     => TYPE ( Account )         => DESCRIPTION ( Account to check for sharing with above standard User )
            3. NAME ( businessSegments )        => TYPE ( List<String> )    => DESCRIPTION ( Account's business Segments )
            4. NAME ( subSegments )             => TYPE ( List<Account> )   => DESCRIPTION ( Account's Sub Segments )
            5. NAME ( mUCommercialCustomerMap ) => TYPE ( List<Account> )   => DESCRIPTION ( Hierarchy Map for Manager users, Contains the Commercial Customer, Customer locations, Customer Locations countries information for manager users )
    */

    private static AccountShare createSharingForManagerUser(
        User currUser,
        Account acc,
        List<String> businessSegments,
        List<String> subSegments,
        /*List<String> applications,*/
        Map<String, UserUtility.CommercialCustomerHierarchyWrapper> mUCommercialCustomerMap
    ){ 

        /* 
            Assigning default values to rowCause and AccessLevel 
            1. RowCause will always be "Manual" as we cannot create rowcause for standard objects
            2. accessLevel is always set to the most restricted one which is "Read" at first and then changed later based on scenarios
        */
        String accessRowCause = null;
        String accessLevel = Constants.SHARE_ACCESS_LEVEL_READ;
        
        /* This part does the check for Commercial Customer Sharing with Read Only access */

        if(isAccountCommercialCustomerAndEligibleToShare(currUser, acc)){

            accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
        }

        /* This part does the check for End Customer Account Sharing */
        /* Checks if an Account is End Customer */

        if(isAccountEndCustomer(acc)){

            /*if (isRelatedCommercialCustomerMU(currUser, accMirror, mUCommercialCustomerMap)) {
                accessRowCause = Constants.ACCOUNT_MIRROR_SHARE_ROW_CAUSE_COMMERCIAL_CUSTOMER;
                
            } else if (isRelatedCustomerLocationMU(currUser, accMirror, mUCommercialCustomerMap)) {
                accessRowCause = Constants.ACCOUNT_MIRROR_SHARE_ROW_CAUSE_CUSTOMER_LOCATION;
                
            } else */
            
            //Checks if the End Customer's Distributor Location matches with atleast one Partner Contact's AccountIds (H5s) under H1
            if (isEndCustomerRelatedToCustomerLocationsMU(currUser, acc, mUCommercialCustomerMap)) {
                accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                accessLevel = Constants.SHARE_ACCESS_LEVEL_EDIT;
                
            }
        }
        
        /* This part does the check for FCI Direct Customer Account Sharing */

        /* Checks if Account is a customer Location & a sold To */
        if(isAccountCustomerLocationAndSoldTo(acc)){

            /* 
                As H5 is enabled as partner/customer, partner always gets access to that account
                Hence, no need to share again
            */
            if(!isCustomerLocEqualsContactLocation(currUser, acc)){

                /* Checks all customer location countries under Partner Contact's H1 with partner contact's country & Additional Country responsibility */
                if (isCountryRelatedMU(currUser, acc, mUCommercialCustomerMap)) {

                    /* Does this check if a user is Business Segment Responsible User */
                    if (isBusinessSegmentRelated(currUser, businessSegments)) {
                        accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                        
                    } 

                    /* Does this check if a user is Sub Segment Responsible User */
                    else if (isSubSegmentRelated(currUser, businessSegments, subSegments)) {
                        accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                        
                    }

                    /* Does this check if a user is Application Responsible User */
                    /*else if (isApplicationRelated(currUser, businessSegments, subSegments, applications)) {
                        accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
                        
                    }*/
                }
            }

        }

        /* Check for Manager user to share H5s under H1 */
        if(isCustomerLocationUnderH1ForManager(currUser, acc, mUCommercialCustomerMap)){

            accessRowCause = Constants.SHARE_ROW_CAUSE_MANUAL;
        }

        if (String.isEmpty(accessRowCause)) {
            return null;
        }
        
        return getAccountShare(acc.Id, currUser.Id, accessLevel, accessRowCause);
    }

    /* @Description
        Method Name : isAccountEndCustomer( Account )

        1. To check if an Account is an end Customer
        
        @PARAMS
            1. NAME ( acc ) => TYPE ( Account ) => DESCRIPTION ( Current Account from loop - Can be any account )
    */

    private static boolean isAccountEndCustomer(Account acc){
        return acc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID);
    }

    /* @Description
        Method Name : isCustomerLocEqualsContactLocation( User , Account )

        1. Checks if Customer Location = Contact's AccountId, then no need to share.
        2. No need to share the H5 account from there the contact is enabled as partner/customer because this is shared by default.
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )    => DESCRIPTION ( Current User from loop - can be any user Standard/Manager )
            2. NAME ( acc )         => TYPE ( Account ) => DESCRIPTION ( Current Account from loop - Can be any account )
    */

    private static Boolean isCustomerLocEqualsContactLocation(User currUser, Account acc){

        return currUser.Contact.AccountId != null && 
                currUser.Contact.AccountId.equals(acc.Id);
    }

    /* @Description
        Method Name : isAccountCommercialCustomerAndEligibleToShare( User , Account )

        1. Checks if Commercial Customer = Contact's Parent Account, then share it with Read Only access.
        2. Basically shares the commercial customer account associated with the Contact.
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )    => DESCRIPTION ( Current User from loop - can be any user Standard/Manager  )
            2. NAME ( acc )         => TYPE ( Account ) => DESCRIPTION ( Current Account from loop - Can be any account )
    */

    private static Boolean isAccountCommercialCustomerAndEligibleToShare(User currUser, Account acc){

        return acc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_COMMERCIAL_CUSTOMER_ID) && 
            currUser.Contact.Parent_Account__c != null &&
            currUser.Contact.Parent_Account__c.equals(acc.Id);
    }

    /* @Description
        Method Name : isEndCustomerRelatedToDistributorLocationSU( User , Account )

        1. Checks if H5 account matches with End customer's Distributor Location (H5) account for Standard User
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )    => DESCRIPTION ( Current Standard User from loop )
            2. NAME ( acc )         => TYPE ( Account ) => DESCRIPTION ( Current End Customer Account from loop )
    */
    private static Boolean isEndCustomerRelatedToDistributorLocationSU(User currUser, Account acc) {

        return currUser.Contact.AccountId != null &&
            currUser.Contact.AccountId.equals(acc.Distributor_Location__c);
    }

    /* @Description
        Method Name : isAdditionalCountryRelatedSU( User , Account )

        1. First checks if the End Customer's Distributor (H1) matches with Contact's Parent Account (H1) 
        2. Second checks for all the non null conditions
        3. Third checks if the End Customer's BillingCountry is contained in Contact's Additional Country responsibility
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )    => DESCRIPTION ( Current Standard User from loop )
            2. NAME ( acc )         => TYPE ( Account ) => DESCRIPTION ( Current End Customer Account from loop )
    */

    private static Boolean isAdditionalCountryRelatedSU(User currUser, Account acc){
        
        return (!String.isBlank(currUser.Contact.Additional_Country_Responsibility__c) &&
                !String.isBlank(acc.Distributor__c) && !String.isBlank(currUser.Contact.Parent_Account__c) &&
                acc.Distributor__c.equals(currUser.Contact.Parent_Account__c) &&
                !String.isBlank(acc.BillingCountry) &&
                currUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase(acc.BillingCountry)
               );
    }

    /* @Description
        Method Name : isCustomerLocationAdditionalCountryRelatedSU( User , Account )

        1. Checks if the Account is of "Customer Location" recordtype
        2. Checks if the Account BillingCountry, ParentId not null
        3. Checks if the Contact AccountId, Parent Account, Add Country not null
        4. Checks if Account is under same H1 hierarcy of the Contact and then checks for additional country and shares it
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )    => DESCRIPTION ( Current Standard User from loop )
            2. NAME ( acc )         => TYPE ( Account ) => DESCRIPTION ( Current Customer Location (H5) Account from loop )
    */

    private static Boolean isCustomerLocationAdditionalCountryRelatedSU(User currUser, Account acc){

        return (!String.isBlank(currUser.Contact.Additional_Country_Responsibility__c) &&
                acc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID) &&
                !String.isBlank(currUser.Contact.AccountId) &&
                !String.isBlank(currUser.Contact.Parent_Account__c) &&
                !String.isBlank(acc.ParentId) &&
                !String.isBlank(acc.BillingCountry) &&
                acc.ParentId.equals(currUser.Contact.Parent_Account__c) &&
                currUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase(acc.BillingCountry)
               );
    }

    /* @Description
        Method Name : isAccountCustomerLocationAndSoldTo( Account )

        1. Checks if the Account is of "Customer Location" recordtype
        2. Checks if the Account Type is a "Direct Customer"
        3. Checks if the Account Partner Role is a "Sold To"
        
        @PARAMS
            1. NAME ( acc ) => TYPE ( Account ) => DESCRIPTION ( Can be any Account )
    */

    private static boolean isAccountCustomerLocationAndSoldTo(Account acc){

        return acc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID)
        && acc.Type != null
        && acc.Type.equals(Constants.ACCOUNT_CUSTOMER_LOCATION_DIRECT_CUSTOMER_VALUE)
        && acc.Partner_Role__c != null
        && acc.Partner_Role__c.contains(Constants.ACCOUNT_CUSTOMER_LOCATION_SOLD_TO_VALUE);
    }

    /* @Description
        Method Name : shouldExcludeCustomeLocAndCKA( Account )

        1. This excludes the FCI Direct customer sharing for the contact's billingCountry if Exclude Customer location checkbox is checked on a partner's contact
        2. This is because there are few contacts who belong to one country but do not operate on that particular country and hence should not see those accounts
        3. Corporate Key Accounts should not be shared
        
        @PARAMS
            1. NAME ( acc ) => TYPE ( Account ) => DESCRIPTION ( Current Customer Location (H5) Account from loop )
    */

    private static boolean shouldExcludeCustomeLocAndCKA(User currUser, Account acc){	
        return currUser.contact.Exclude_Customer_Location_Country__c  && currUser.Contact.Account.BillingCountry.equals(acc.BillingCountry)
                && !acc.Corporate_Key_Account__c;
    }
  
    /* @Description
        Method Name : isCountryRelatedSU( User , Account )

        1. Checks if Customer Location's BillingCountry = Partner Contact's H5's BillingCountry
        2. Checks if Customer Location's BillingCountry is contained in Partner Contact's Additional Country Responsibility
        
        @PARAMS
            1. NAME ( currUser )    => TYPE ( User )    => DESCRIPTION ( Current Standard User from loop )
            2. NAME ( acc )         => TYPE ( Account ) => DESCRIPTION ( Current Customer Location (H5) Account from loop )
    */

    private static Boolean isCountryRelatedSU(User currUser, Account acc) {

        return  !String.isBlank(acc.BillingCountry) &&
                ( 
                    acc.BillingCountry.equals(currUser.Contact.Account.BillingCountry)  
                || 
                    (
                        !String.isBlank(currUser.Contact.Additional_Country_Responsibility__c) &&
                        currUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase(acc.BillingCountry)
                    )
               );
    }

    /* @Description
        Method Name : isEndCustomerRelatedToCustomerLocationsMU( User , Account , Map<String, UserUtility.CommercialCustomerHierarchyWrapper> )

        1. Checks if End Customer's Distributor Location is matching with one of the H5s under Partner Contact's H1 
        
        @PARAMS
            1. NAME ( currUser )                => TYPE ( User )    => DESCRIPTION ( Current Manager User from loop )
            2. NAME ( acc )                     => TYPE ( Account ) => DESCRIPTION ( Current End Customer Account from loop )
            2. NAME ( mUCommercialCustomerMap ) => TYPE ( Map<String, UserUtility.CommercialCustomerHierarchyWrapper> ) => DESCRIPTION ( Map of UserId , All the info about the H5s and Commercial customer for partner contact )
    */

    private static Boolean isEndCustomerRelatedToCustomerLocationsMU(User currUser, Account acc, Map<String, UserUtility.CommercialCustomerHierarchyWrapper> mUCommercialCustomerMap) {

        return  mUCommercialCustomerMap.containsKey(currUser.Id) &&
            mUCommercialCustomerMap.get(currUser.Id).customerLocationsIds != null &&
            mUCommercialCustomerMap.get(currUser.Id).customerLocationsIds.contains(acc.Distributor_Location__c);
    }

    /* @Description
        Method Name : isCountryRelatedMU( User , Account , Map<String, UserUtility.CommercialCustomerHierarchyWrapper> )

        1. Checks if the account's BillingCountry is matches with atleast one of the BillingCountry of all the Partner Contact's H5 locations under its H1
        
        @PARAMS
            1. NAME ( currUser )                => TYPE ( User )    => DESCRIPTION ( Current Manager User from loop )
            2. NAME ( acc )                     => TYPE ( Account ) => DESCRIPTION ( Current Customer Location Sold-To Account from loop )
            2. NAME ( mUCommercialCustomerMap ) => TYPE ( Map<String, UserUtility.CommercialCustomerHierarchyWrapper> ) => DESCRIPTION ( Map of UserId , All the info about the H5s and Commercial customer for partner contact )
    */
    private static Boolean isCountryRelatedMU(User currUser, Account acc, Map<String, UserUtility.CommercialCustomerHierarchyWrapper> mUCommercialCustomerMap) {
        
        return  mUCommercialCustomerMap.containsKey(currUser.Id) &&
            mUCommercialCustomerMap.get(currUser.Id).customerLocationsCountries != null &&
            mUCommercialCustomerMap.get(currUser.Id).customerLocationsCountries.contains(acc.BillingCountry);
    }

    /* @Description
        Method Name : isCustomerLocationUnderH1ForManager( User , Account , Map<String, UserUtility.CommercialCustomerHierarchyWrapper> )

        1. Checks if the H5 is currently present under the H1 hierarchy of the Partner Contact's H1
            i.  If yes, then share
            ii. Else, dont share
        
        @PARAMS
            1. NAME ( currUser )                => TYPE ( User )    => DESCRIPTION ( Current Manager User from loop )
            2. NAME ( acc )                     => TYPE ( Account ) => DESCRIPTION ( Current Customer Location Account from loop )
            2. NAME ( mUCommercialCustomerMap ) => TYPE ( Map<String, UserUtility.CommercialCustomerHierarchyWrapper> ) => DESCRIPTION ( Map of UserId , All the info about the H5s and Commercial customer for partner contact )
    */
    private static Boolean isCustomerLocationUnderH1ForManager(User currUser, Account acc, Map<String, UserUtility.CommercialCustomerHierarchyWrapper> mUCommercialCustomerMap){
         
        return acc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID) &&
            mUCommercialCustomerMap.containsKey(currUser.Id) &&
            mUCommercialCustomerMap.get(currUser.Id).customerLocationsIds != null &&
            mUCommercialCustomerMap.get(currUser.Id).customerLocationsIds.contains(acc.Id);
    }

    /* @Description
        Method Name : isBusinessSegmentRelated( User , List<String> )

        1. Checks if current user is a Business Segment Responsible User
        2. Checks if the current user's Business Segment contains atleast one business segment value from Customer Location's Business Segment
        
        @PARAMS
            1. NAME ( currUser )            => TYPE ( User )            => DESCRIPTION ( Current User from loop - Can be Standard/Manager )
            2. NAME ( businessSegments )    => TYPE ( List<String> )    => DESCRIPTION ( Business Segments of current customer location Account from loop )
    */

    private static Boolean isBusinessSegmentRelated(User currUser, List<String> businessSegments) {

        return  (
            !String.isBlank(currUser.Community_Account_Role__c) &&
            currUser.Community_Account_Role__c.equals(Constants.USER_COMMUNITY_ACCOUNT_ROLE_BUSINESS_SEGMENT)
        ) &&
            !String.isBlank(currUser.Contact.Business_Segment__c) &&
            Utilities.isPicklistFieldContainsValue(businessSegments, currUser.Contact.Business_Segment__c);
    }

    /* @Description
        Method Name : isSubSegmentRelated( User , List<String> , List<String> )

        1. Checks if current user is a Sub-Segment Responsible User
        2. Does a Business segment check also
        3. Checks if the current user's Sub-Segment contains atleast one Sub-Segment value from Customer Location's Sub-Segment
        
        @PARAMS
            1. NAME ( currUser )            => TYPE ( User )            => DESCRIPTION ( Current User from loop - Can be Standard/Manager )
            2. NAME ( businessSegments )    => TYPE ( List<String> )    => DESCRIPTION ( Business Segments of current customer location Account from loop )
            3. NAME ( subSegments )         => TYPE ( List<String> )    => DESCRIPTION ( Sub Segments of current customer location Account from loop )
    */

    private static Boolean isSubSegmentRelated(User currUser, List<String> businessSegments, List<String> subSegments) {
        return  !String.isBlank(currUser.Community_Account_Role__c) &&
            currUser.Community_Account_Role__c.equals(Constants.USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT) &&
            !String.isBlank(currUser.Contact.Business_Segment__c) &&
            Utilities.isPicklistFieldContainsValue(businessSegments, currUser.Contact.Business_Segment__c) &&
            !String.isBlank(currUser.Contact.Sub_Segment__c) &&
            Utilities.isPicklistFieldContainsValue(subSegments, currUser.Contact.Sub_Segment__c);
    }

    /* @Description
        Method Name : isApplicationRelated( User , List<String> , List<String> , List<String> )

        1. Checks if current user is a Application Responsible User
        2. Does a Business segment check also
        3. Does a Sub-Segment check also
        4. Checks if the current user's Application contains atleast one Application value from Customer Location's Application
        
        @PARAMS
            1. NAME ( currUser )            => TYPE ( User )            => DESCRIPTION ( Current User from loop - Can be Standard/Manager )
            2. NAME ( businessSegments )    => TYPE ( List<String> )    => DESCRIPTION ( Business Segments of current customer location Account from loop )
            3. NAME ( subSegments )         => TYPE ( List<String> )    => DESCRIPTION ( Sub Segments of current customer location Account from loop )
            4. NAME ( applications )        => TYPE ( List<String> )    => DESCRIPTION ( Applications of current customer location Account from loop )
    */

    /*private static Boolean isApplicationRelated(User currUser, List<String> businessSegments, List<String> subSegments,  List<String> applications) {
        return  !String.isBlank(currUser.Community_Account_Role__c) &&
            currUser.Community_Account_Role__c.equals(Constants.USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION) &&
            !String.isBlank(currUser.Contact.Business_Segment__c) &&
            Utilities.isPicklistFieldContainsValue(businessSegments, currUser.Contact.Business_Segment__c) &&
            !String.isBlank(currUser.Contact.Sub_Segment__c) &&
            Utilities.isPicklistFieldContainsValue(subSegments, currUser.Contact.Sub_Segment__c) &&
            !String.isBlank(currUser.Contact.Application__c) &&
            Utilities.isPicklistFieldContainsValue(applications, currUser.Contact.Application__c);
    }*/

    /* @Description
        Method Name : getAccountShare( Id , Id , String , String )

        1. Creates & returns an AccountShare instance
        
        @PARAMS
            1. NAME ( accId )           => TYPE ( Id )      => DESCRIPTION ( Account's Id )
            2. NAME ( userId )          => TYPE ( Id )      => DESCRIPTION ( Current user's Id )
            3. NAME ( accessLevel )     => TYPE ( String )  => DESCRIPTION ( Access Level )
            4. NAME ( accessRowCause )  => TYPE ( String )  => DESCRIPTION ( RowCause )
    */

    public static AccountShare getAccountShare(Id accId, Id userId, String accessLevel, String accessRowCause) {

        return new AccountShare(
            AccountId = accId,
            AccountAccessLevel = accessLevel,
            CaseAccessLevel = Constants.SHARE_ACCESS_LEVEL_NONE,
            OpportunityAccessLevel = Constants.SHARE_ACCESS_LEVEL_NONE,
            ContactAccessLevel = Constants.SHARE_ACCESS_LEVEL_NONE,
            RowCause = accessRowCause,
            UserOrGroupId = userId
        );
    }

    /* This will never happen as Distributors are never contacts of an End Customer Account
    private static Boolean isRelatedCustomerLocationSU(User currUser, Account acc) {
        return currUser.Contact.AccountId != null &&
            currUser.Contact.AccountId.equals(acc.Id);
    } */

    /* private static boolean isEligibleForStandardUserAccountSharing(User stdUser,Account accObj){
        return stdUser.Contact.AccountId != null &&
               ((stdUser.Contact.AccountId.equals(accObj.Id))
                || (accObj.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID) && stdUser.Contact.AccountId.equals(accObj.Distributor__c) ));
    }

    public static Boolean isEligibleForManagerUserAccountSharing(User mngUser, Account accObj){
        return   mngUser.Contact.Work_Location__c != null &&
                ((mngUser.Contact.Work_Location__c.equals(accObj.Id) ||
                 mngUser.Contact.AccountId.equals(accObj.ParentId))
            ||(accObj.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID) && mngUser.Contact.AccountId.equals(accObj.Distributor__c) ));
    } */

    /*  Checks if an account belongs to any of the 3 Record types:
        1. Commercial Customer
        2. Customer Location
        3. End Customer 
        This method is used for Account Insert   
    */

    /* @Description
        Method Name : isRecalculationRequiredToShare( Account )

        Checks if an account belongs to any of the 3 Record types:
            1. Commercial Customer
            2. Customer Location
            3. End Customer 
        This method is used on Account Insert  
        
        @PARAMS
            1. NAME ( newAcc )  => TYPE ( Account ) => DESCRIPTION ( New Account from Trigger.New )
    */

    private static Boolean isRecalculationRequiredToShare(Account newAcc){

        return recordTypeIdsToShare.contains(newAcc.RecordTypeId);
    }

    /* @Description
        Method Name : isRecalculationRequiredToShare( Account , Account )

        1. This method is overloaded and is used for Account Updates
        
        @PARAMS
            1. NAME ( newAcc )  => TYPE ( Account ) => DESCRIPTION ( Account from Trigger.New )
            1. NAME ( oldAcc )  => TYPE ( Account ) => DESCRIPTION ( Account from Trigger.Old )
    */

    private static Boolean isRecalculationRequiredToShare(Account oldAcc,Account newAcc){
        return  
            
            oldAcc.parentId != newAcc.ParentId ||
            (!recordTypeIdsToShare.contains(oldAcc.RecordTypeId) && recordTypeIdsToShare.contains(newAcc.RecordTypeId)) ||
            (recordTypeIdsToShare.contains(newAcc.RecordTypeId) && (oldAcc.ownerId != newAcc.OwnerId)) || 
            /* This is for all FCI Direct Customers (Customer Locations) */
            (
                newAcc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID) &&
                    (newAcc.Business_Segment__c != oldAcc.Business_Segment__c ||
                    newAcc.Sub_Segment__c != oldAcc.Sub_Segment__c ||
                    newAcc.BillingCountry != oldAcc.BillingCountry ||
                    newAcc.Type != oldAcc.Type ||
                    newAcc.Partner_Role__c != oldAcc.Partner_Role__c)
            ) ||
            /* This is for End Customer sharing */
            (
                newAcc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID) &&
                newAcc.Distributor_Location__c != oldAcc.Distributor_Location__c
            );
    }

    /* @Description
        Method Name : isRecalculationRequiredToRevoke( Account , Account )

        1. Access will be revoked from Community Users if there is a recordType change for accounts from 
        End-Customer,CustomerLocation,Commercial Customer to anything other than these 3
        
        @PARAMS
            1. NAME ( newAcc )  => TYPE ( Account ) => DESCRIPTION ( Account from Trigger.New )
            1. NAME ( oldAcc )  => TYPE ( Account ) => DESCRIPTION ( Account from Trigger.Old )
    */

    private static Boolean isRecalculationRequiredToRevoke(Account oldAcc,Account newAcc){
        return (!recordTypeIdsToShare.contains(newAcc.RecordTypeId) &&
                 recordTypeIdsToShare.contains(oldAcc.RecordTypeId));
    }
    
    private static Boolean isUsersAdditionalCustomerLocation(User usr, Account acc, Map<Id, Set<Id>> addLocMap){
        return acc.RecordTypeId.equals(Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID) &&
            addLocMap.containsKey(usr.Id) &&
            addLocMap.get(usr.Id) != null &&
            addLocMap.get(usr.Id).contains(acc.Id);
    }
    
    private static Boolean isEndCustomerRelatedToAdditonalCustomerLocationSU(User currUser, Account acc, Map<Id, Set<Id>> addLocMap){

        return addLocMap.containsKey(currUser.Id) &&
            addLocMap.get(currUser.Id) != null &&
            addLocMap.get(currUser.Id).contains(acc.Distributor_Location__c);
    }
}