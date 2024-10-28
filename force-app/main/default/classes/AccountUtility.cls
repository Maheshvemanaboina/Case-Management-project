/**
 * Created by KJM on 16/07/2019.
 */

public without sharing class AccountUtility {

    public static Set<Id> getAllChildAccounts(Id parentAccId) {
        Map<Id, Account> accs = new Map<Id, Account>([
            SELECT Id
            FROM Account
            WHERE ParentId = :parentAccId
        ]);

        return accs.keySet();
    }
    
    /*public static List<Account> getAllAccountsToShareWithPortalUsers(List<Account> acctList){
        List<Account> portalUsersAcctList = new List<Account>();
        Set<Id> recordTypeIds = getRecordTypeIdsofAccountToShareWithPortalUsers();
        for(Account acc : acctList){
            if(recordTypeIds.contains(acc.RecordTypeId)){
                portalUsersAcctList.add(acc);
            }
        }

        return portalUsersAcctList;
    }*/

    public static Set<Id> getRecordTypeIdsofAccountToShareWithPortalUsers(){
        Set<Id> accountMirrorRecordTypeIdsSet = new Set<Id>();
        accountMirrorRecordTypeIdsSet.add(Constants.ACCOUNT_RECORD_TYPE_COMMERCIAL_CUSTOMER_ID);
        accountMirrorRecordTypeIdsSet.add(Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID);
        accountMirrorRecordTypeIdsSet.add(Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID);
        return accountMirrorRecordTypeIdsSet;
    }

    /* Gets all the accounts to share (H5 & H1, End Customers, Direct Customers) */
    public static List<Account> getAccountAllAccountsToShareWithCommunityUsers(List<User> users){

        /* Accounts Ids to Query & Valid RecordTypeIds to Query */
        Set<Id> accountids              = new Set<Id>(); 
        Id endCustomerRecordTypeId      = Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID;
        Id cusLocationRecordTypeId      = Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID;

        /* Valid Parter Role (Sold-to) & Account Type (Direct Customer) values */
        String validPartnerRole = '(\'' + Constants.ACCOUNT_CUSTOMER_LOCATION_SOLD_TO_VALUE + '\')';
        String validaccType     = Constants.ACCOUNT_CUSTOMER_LOCATION_DIRECT_CUSTOMER_VALUE;

        /* Segments, Countries collections to check */
        Set<String> businessSegments    = new Set<String>();
        Set<String> subSegments         = new Set<String>();
        Set<String> billingAddCountries = new Set<String>();
        
        /* Get Additional Customer Locations associated to the users contact */
        //Map<Id, Set<Id>> userAddCustLocsMap = getAdditionalCustLocsOfSelectedUsers(users);

        for(User us : users){
            //AS: Add null check for SRM Portal users.
            if(string.isNotblank(us.Contact.AccountId))                 accountids.add(us.Contact.AccountId);
            if(string.isNotblank(us.Contact.Parent_Account__c))         accountids.add(us.Contact.Parent_Account__c);

            // Add Billing Country to query FCI Direct Customers
            if(String.isNotBlank(us.Contact.Account.BillingCountry))    billingAddCountries.add(us.Contact.Account.BillingCountry);

            // Collect all Business Segments for user's Contact
            if(String.isNotBlank(us.Contact.Business_Segment__c))       businessSegments.addAll(us.Contact.Business_Segment__c.split(';'));

            // Collect all Sub Segments for user's Contact
            if(String.isNotBlank(us.Contact.Sub_Segment__c))            subSegments.addAll(us.Contact.Sub_Segment__c.split(';'));

            // Collect all additional Countries for user's Contact
            if(String.isNotBlank(us.Contact.Additional_Country_Responsibility__c)) billingAddCountries.addAll(us.Contact.Additional_Country_Responsibility__c.split(';'));
            
            // Collect all additional customer locations associated to user's contact
            //if(userAddCustLocsMap.containsKey(us.Id)) accountids.addAll(userAddCustLocsMap.get(us.Id));
        }        
        
        String accQuery = 'SELECT Id, Name, ParentId, OwnerId FROM Account ';
        accQuery += ' WHERE ';
        // This is for H5s & H1s related to the community contact
        accQuery += ' ( Id IN :accountids OR ParentId IN :accountids ) ';
        accQuery += ' OR ';
        //Query for End Customers
        accQuery += ' ( RecordTypeId =: endCustomerRecordTypeId AND (Distributor__c IN: accountids OR Distributor_Location__c IN: accountids) ) ';
        accQuery += ' OR ';
        //Query for FCI Direct Customers
        accQuery += ' ( RecordTypeId =: cusLocationRecordTypeId ';
        accQuery += ' AND Type =: validaccType';
        accQuery += ' AND Corporate_Key_Account__c = false';
        accQuery += ' AND ParentId != NULL';
        accQuery += ' AND Partner_Role__c INCLUDES ' + validPartnerRole;
        accQuery += ' AND BillingCountry IN: billingAddCountries ';
        accQuery += ' AND ( Business_Segment__c INCLUDES ' + '(\'' + String.join(new List<String>(businessSegments), '\',\'') + '\')';
        accQuery += ' OR Sub_Segment__c INCLUDES ' + '(\'' + String.join(new List<String>(subSegments), '\',\'') + '\')' + ') ';
        //accQuery += ' OR Application__c INCLUDES ' + '(\'' + String.join(new List<String>(applications), '\',\'') + '\')' + ') ';
        accQuery += ' )';
		
        System.debug(' accQuery size --> '+((List<Account>)Database.query(accQuery)).size());
        return (List<Account>)Database.query(accQuery);
    }
    
    public static Map<Id, Set<Id>> getAdditionalCustLocsOfSelectedUsers(List<User> userList){
        //Set<Id> contactIdSet = new Set<Id>();
        Map<Id, Id> contactUserIdsMap = new Map<Id, Id>();
        //Map<Id, List<Id>> contactAdditionalCustomerLocationsMap = new Map<Id, List<Id>>();
        Map<Id, Set<Id>> userAdditionalCustomerLocationsMap = new Map<Id, Set<Id>>();
        for(User usr : userList){
            if(UserUtility.isCurrentUserPartnerUser(usr) && UserUtility.isUserStandardCommunityUser(usr) && usr.ContactId != null){
                //contactIdSet.add(usr.ContactId);
                contactUserIdsMap.put(usr.ContactId, usr.Id);
            }
        }
        
        for(Other_Related_Customer_Location__c orcl : [SELECT Additional_Customer_Location__c, Related_Contact__c
                                                       FROM Other_Related_Customer_Location__c
                                                       WHERE Related_Contact__c IN: contactUserIdsMap.keySet()
                                                       AND Additional_Customer_Location__c != null])
        {
            /*if(!contactAdditionalCustomerLocationsMap.containsKey(orcl.Related_Contact__c)){
                contactAdditionalCustomerLocationsMap.put(orcl.Related_Contact__c, new List<String>{orcl.Additional_Customer_Location__c});
            }else{
                contactAdditionalCustomerLocationsMap.get(orcl.Related_Contact__c).add(orcl.Additional_Customer_Location__c);
            }*/
            
            if(contactUserIdsMap.containsKey(orcl.Related_Contact__c)){
                if(!userAdditionalCustomerLocationsMap.containsKey(contactUserIdsMap.get(orcl.Related_Contact__c)))
                    userAdditionalCustomerLocationsMap.put(contactUserIdsMap.get(orcl.Related_Contact__c), new Set<Id>{orcl.Additional_Customer_Location__c});
                else
                    userAdditionalCustomerLocationsMap.get(contactUserIdsMap.get(orcl.Related_Contact__c)).add(orcl.Additional_Customer_Location__c);
            }
        }
        return userAdditionalCustomerLocationsMap;
    }
}