/**
* Author   :   Sibananda Bhuyan
* Date     :   9 Novemer 2020
* Desc     :   Controller for sObject Lookup Lightning Component

History
19-07-2022		Mahendra Kumar		Modified class to add where filter logic if the lookup is used in ContentManagement.cmp and Content Owner filter is applied
* */
public without sharing class SObjectLookUpController {
    
    public static final String PRODUCT2_API_NAME = 'Product2';
    public static final String Account_API_NAME = 'Account';
    public static final String COMMUNITY_USER_ROLE_STANDARD_USER = 'Standard User';
    public static final String COMMUNITY_USER_ROLE_MANAGER_USER = 'Manager User';
    public static final String USER_API_NAME = 'User';//ENH-4370

    @AuraEnabled
    public static List<sObject> getRecords(String objectAPIName, /* The sObject name from where the records will be queried */
                                            String fieldAPIName, /* The field that will be used in the search results */
                                            String whereFieldAPIName, /* The field that will be used in the where clause with Search Text */
                                            List<String> metaFieldsAPI, /* Field API for the fields to be shown under the record Name. Must be comma separated. Example: Email,Phone */
                                            List<String> recordTypeDevNames, /* RecordTypeDeveloperNames to filter based on record Type for the SObjectAPIName */
                                            String searchText, /* Search Text entered by User */
                                            Integer recordLimit, /* No of Records to return at once */
                                          String contactId /* ContactId from which the Additional Customer location is being searched */,
                                          Boolean contentOwnerFilter /* ENH-4370 To apply the filter to get only the users with knowledge user permission and library access*/)
    {
         
        Set<Id> recordTypeIds = new Set<Id>();
        List<sObject> objectList =  new List<sObject>();
         
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
         
        String soqlQuery = 'SELECT Id,Name ';
        soqlQuery = !fieldAPIName.equalsIgnoreCase('Name') ? soqlQuery + ',' + fieldAPIName : soqlQuery;
        
        if(metaFieldsAPI.indexOf(fieldAPIName) != -1){
            metaFieldsAPI.remove(metaFieldsAPI.indexOf(fieldAPIName));
        }

        if(!metaFieldsAPI.isEmpty() && !metaFieldsAPI.contains(fieldAPIName)){
            soqlQuery = soqlQuery + ',' + String.join(metaFieldsAPI, ',') ;
        }

        soqlQuery = soqlQuery + ' FROM ' + objectAPIName + ' WHERE ' + whereFieldAPIName +' LIKE '+ searchText;

        if(!recordTypeDevNames.isEmpty()){

            recordTypeIds.addAll(fetchRecordTypeIdsFromDeveloperName(recordTypeDevNames, objectAPIName));
            soqlQuery = soqlQuery + ' AND RecordTypeId IN: recordTypeIds'; 
        }

        if(objectAPIName.equals(PRODUCT2_API_NAME)) {
            
            Set<Id> product2Ids = getFilteredProduct2ForCommunityUsers();
            if(!product2Ids.isEmpty()){

                soqlQuery = soqlQuery + ' AND Id IN: product2Ids';
            }
        }
        if(objectAPIName.equals(Account_API_NAME) && recordLimit != 10) {
             //Set<Id> accountIds = getLocationSpecificAccounts();
             Set<Id> accountIds = String.isNotBlank(contactId) ? getLocationSpecificAccounts(contactId) : getLocationSpecificAccounts();
             soqlQuery = soqlQuery + ' AND Id IN: accountIds';
             recordLimit = 10;
        }
        
        //ENH-4370 To search for knowledge users with library access - Added by Mahendra
        if(objectAPIName.equals(USER_API_NAME) && contentOwnerFilter){
            soqlQuery = soqlQuery + ' AND UserPermissionsKnowledgeUser = true AND IsActive = true AND ';
            soqlQuery = soqlQuery + ' Id IN (SELECT MemberId FROM ContentWorkSpaceMember)';
        }
                    
        soqlQuery = soqlQuery + ' LIMIT '+ recordLimit;
        objectList = Database.query(soqlQuery);
        return objectList;
    }

    /* If the ObjectAPIName is Product2, then community users will only be able to select products available for them only from Listings */
    private static Set<Id> getFilteredProduct2ForCommunityUsers(){

        Set<Id> product2Ids = new Set<Id>();
        User currentUser = UserUtility.getCurrentUser();
        if(!String.isBlank(currentUser.ContactId)){

            //Fetches AccountIds based on Standard or Manager user
            Set<Id> accountIdsToConsider = getAccountIdBasedOnUserRole(currentUser.Community_User_Role__c ,currentUser.Contact.AccountId, currentUser.Contact.Parent_Account__c);

            if(!accountIdsToConsider.isEmpty()){

                for(Listing__c eachfilteredListing : [SELECT Id, Product__c FROM Listing__c WHERE Customer__c != null AND Customer__c IN: accountIdsToConsider AND Active__c = true]){

                    if(!String.isBlank(eachfilteredListing.Product__c)) product2Ids.add(eachfilteredListing.Product__c);
                }
            }
        }

        return product2Ids;
    }

    /* Fetches accountId based on Standard or Manager 
        1. If standard, only returns AccountId for the contact
        2. If Manager, returns all the H5s from the parent Account    
    */
    private static Set<Id> getAccountIdBasedOnUserRole(String communityUserRole, Id accountH5Id, Id accountH1Id){

        if((communityUserRole.equals(COMMUNITY_USER_ROLE_STANDARD_USER) || String.isBlank(communityUserRole)) && !String.isBlank(accountH5Id)){

            return new Set<Id>{ accountH5Id };
        }

        if(!String.isBlank(accountH1Id)){

            Account commercialCustomer = [SELECT Id, (SELECT Id FROM ChildAccounts) FROM Account WHERE Id =: accountH1Id];
            Map<Id, Account> childAccountsMap = new Map<Id, Account>( commercialCustomer.ChildAccounts );
            
            return childAccountsMap.keySet();
        }

        return new Set<Id>();
    }

    /* Cannot use Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe(); because it is very slow,
    hence not using Schema and using SOQL for it
    */

    private static Set<Id> fetchRecordTypeIdsFromDeveloperName(List<String> recordTypeDevNames, String objectAPIName){

        Set<Id> recordTypeIds = new Set<Id>();

        for(RecordType eachRecType : [SELECT Id FROM RecordType WHERE DeveloperName IN: recordTypeDevNames AND sObjectType =: objectAPIName]){

            recordTypeIds.add(eachRecType.Id);
        }
        return recordTypeIds;
    }
    
     private static Set<Id> getLocationSpecificAccounts(){
        Set<Id> accountIds = new Set<Id>();
        User currentUser = UserUtility.getCurrentUser();
        if(!String.isBlank(currentUser.ContactId)){         
			
            Account commercialCustomer = [SELECT Id, (SELECT Id FROM ChildAccounts) FROM Account WHERE Id =: currentUser.Contact.Parent_Account__c];
            Map<Id, Account> childAccountsMap = new Map<Id, Account>( commercialCustomer.ChildAccounts );            
            accountIds = childAccountsMap.keySet();
            
        }
        return accountIds;
    }
    
    private static Set<Id> getLocationSpecificAccounts(String contactId){
        Set<Id> accountIds = new Set<Id>();
        if(!String.isBlank(contactId)){         
			
            Account commercialCustomer = [SELECT Id, (SELECT Id FROM ChildAccounts) FROM Account WHERE Id IN (SELECT Parent_Account__c FROM Contact WHERE Id =: contactId)];
            Map<Id, Account> childAccountsMap = new Map<Id, Account>( commercialCustomer.ChildAccounts );            
            accountIds = childAccountsMap.keySet();
            
        }
        return accountIds;
    }
}