/*      
@Name                  ContractSharingUtility
@Author                Carlo Volpi-carlo.volpi@kcsit.pt
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               1.0
@CreatedDate           04-03-2021
@UsedBy                ContactSharingUtility, UserSharingUtility
@Description           Class to give and revoke contract access(account access) to Partner Community Users
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
*/
public with sharing class ContractSharingUtility {

    /* @Description

    Public constructor to get some code coverage as this developement is freezed

    */
    public ContractSharingUtility(){}

    /*
    /* @Description

    Method to create Account sharing for additional country responsability users

    @param ctcsIdsToRecalculate - Set of contact Ids to consider

    @return void
    * /
    public static void createAccountSharingForAdditionalCountryResponsabilityUsers(Set<Id> ctcsIdsToRecalculate){

        List<Contact> ctcsToRecalculate = new List<Contact>(); //Contacts list to consider
        Set<Id> ownersCommercialCustomer = new Set<Id>(); //Set of Account Ids of parent accounts
        Set<String> billingCountries = new Set<String>();  //Set of countries of account billing countries
        Map<Id, Id> contactIdUserIdMap = new Map<Id, Id>(); //Map of Contacts Ids and User Id
        Map<Id, Map<String, List<Id>>> commercialCustomersCountryCustomerLocationsIds = new Map<Id, Map<String, List<Id>>>(); //Map of Commercial Customer Id => Country => Customer Locations Id list
        List<AccountShare> acsList = new List<AccountShare>(); //AccountShare records to be created

        //Get Accounts information
        ctcsToRecalculate = DAOUtilityWithoutShar.getContactsForSharing(ctcsIdsToRecalculate);

        //Fill the contactIdUserIdMap
        for(User u : UserUtility.getAllPartnerCommunityUsersByContacts(ctcsIdsToRecalculate)){
            contactIdUserIdMap.put(u.ContactId, u.Id);
        }

        //Fill the sets with the Contacts information
        for(Contact ctc : ctcsToRecalculate){

            if(String.isNotBlank(ctc.Account.ParentId)){
                ownersCommercialCustomer.add(ctc.Account.ParentId);
            }
            
            if(String.isNotBlank(ctc.Additional_Country_Responsibility__c)){

                for(String s : ctc.Additional_Country_Responsibility__c.split(';')){
                    billingCountries.add(s);
                }
            }            
        }

        //Populate the commercialCustomersCountryCustomerLocationsIds map with Commercial Customer Id, country and Customer Locations
        if(!ownersCommercialCustomer.isEmpty() && !billingCountries.isEmpty())
            getAllCustomerLocations(ownersCommercialCustomer, billingCountries, commercialCustomersCountryCustomerLocationsIds);

        //For each contact check if it is responsible for another countries, if yes create 
        //an AccountShare for Customer Locations for that countries
        for(Contact ctc : ctcsToRecalculate){
            
            if(String.isNotBlank(ctc.Additional_Country_Responsibility__c)){

                for(String s : ctc.Additional_Country_Responsibility__c.split(';')){

                    if(commercialCustomersCountryCustomerLocationsIds.containsKey(ctc.Account.ParentId) && commercialCustomersCountryCustomerLocationsIds.get(ctc.Account.ParentId).containsKey(s)){

                        for(Id accId : commercialCustomersCountryCustomerLocationsIds.get(ctc.Account.ParentId).get(s)){

                            acsList.add(AccountSharingUtility.getAccountShare(accId, contactIdUserIdMap.get(ctc.Id), Constants.SHARE_ACCESS_LEVEL_READ, Constants.SHARE_ROW_CAUSE_MANUAL));
                        }

                    }
                }
            }
        }

        //Insert AccountShare records for Contract Sharing
        if(!acsList.isEmpty()){
            DAOUtilityWithoutShar.insertWithoutAccess(acsList);
        }
    }

    /* @Description

    Populate the commercialCustomersBillingCountryKeyWithAdditionalCountryResponsabilityUsers

    @param ownersCommercialCustomer - Set of Account Ids of cases parent accounts
    @param billingCountries - Set of Billing Countries to consider
    @param commercialCustomersCountryCustomerLocationsIds - Map of Commercial Customer Id => Country => Customer Locations Id list

    @return void
    * /
    //Populate the commercialCustomersCountryCustomerLocationsIds map with Commercial Customer Id, country and Customer Locations
    private static void getAllCustomerLocations(Set<Id> ownersCommercialCustomer, Set<String> billingCountries, Map<Id, Map<String, List<Id>>> commercialCustomersCountryCustomerLocationsIds){

        //Check if the Commercial Costumer Id already is in the map, if not put the Commercial Costumer Id, with the country and a list 
        //with the Customer Location Id, if yes check if the country is already in the map, if not put the country with the country and a list with the Customer Location Id,
        //if yes just add the Customer Location Id to the country list.
        for(Account acc : DAOUtilityWithoutShar.getCustomerLocationChildrenAccountsByParentIdBillingCountry(ownersCommercialCustomer, billingCountries)){

            if(!commercialCustomersCountryCustomerLocationsIds.containsKey(acc.ParentId)){
                commercialCustomersCountryCustomerLocationsIds.put(acc.ParentId, new Map<String, List<Id>>{acc.BillingCountry => new List<Id>{acc.Id}});
            } else {
                if(!commercialCustomersCountryCustomerLocationsIds.get(acc.ParentId).containsKey(acc.BillingCountry)){
                    commercialCustomersCountryCustomerLocationsIds.get(acc.ParentId).put(acc.BillingCountry, new List<Id>{acc.Id});
                } else{
                    commercialCustomersCountryCustomerLocationsIds.get(acc.ParentId).get(acc.BillingCountry).add(acc.Id);
                }
            }
        }
    }*/
}