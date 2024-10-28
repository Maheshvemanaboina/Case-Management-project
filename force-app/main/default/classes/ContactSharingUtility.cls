/*      
@Name                  ContactSharingUtility
@Author                KJM
@ModifiedBy            Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com
@Version               2.0
@CreatedDate           02-08-2019
@UsedBy                ContactTriggerHandler
@Description           Created by KJM for Account, Opportunity, Case sharing on Contact Update. Class to give and revoke records access to Partner Community Users
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com | 29.01.2021 | Changed method calls for new Account Restructure
XXXXXXXXXXXXXXX | Sibananda Bhuyan-Sibananda.bhuyan@frieslandcampina.com | 07.09.2021 | Updated to remove application (Application__c) references from code 
*/
public with sharing class ContactSharingUtility {
    
    /* @Description

    Calculate Account, Opportunity, Case Sharing on contact Update

    @param newContact - Contact list of updated new contacts (Trigger.new)
    @param usersToConsider - A Map of User Id and User SObject of Partner Community Users to consider to give and revoke record access

    @return void
    */
    public static void recalculateContactSharingOnContactUpdate(List<Contact> newContacts, List<User> usersToConsider){
        Set<Id> conToRecalculate = new Set<Id>(); //Contact Ids list to recalculate records sharing
        Set<Id> conToRevoke = new Set<Id>(); //Contact Ids list to revoke records sharing
        
        /* Contract Sharing */
        //Set<Id> conToRecalculateContractSharing = new Set<Id>();

        Set<Id> conAccsToRecalculate = new Set<Id>(); //Account Ids list to recalculate records sharing
        Set<Id> contactIdsToRecalculateKPISharing = new Set<Id>();
        //Map<Id, Id> contAccIdsToRecalculateAddCustLocSharing = new Map<Id, Id>();

        for (Contact con : newContacts) {
            if (isRecalculationRequiredToShare((Contact)trigger.OldMap.get(con.Id), con)) {
                
                conToRecalculate.add(con.Parent_Account__c);
                conToRecalculate.add(con.AccountId);
                conToRevoke.add(((Contact)trigger.OldMap.get(con.Id)).Parent_Account__c);
                conToRevoke.add(((Contact)trigger.OldMap.get(con.Id)).AccountId);
                //conToRecalculateContractSharing.add(con.Id);
                contactIdsToRecalculateKPISharing.add(con.Id);
                /*if(((Contact)trigger.OldMap.get(con.Id)).AccountId != con.AccountId){
                    contAccIdsToRecalculateAddCustLocSharing.put(con.Id, con.AccountId);
                }*/
            }

            if(isRecalculationRequiredToShareAccount((Contact)trigger.OldMap.get(con.Id), con)){

                conAccsToRecalculate.add(con.Id);
            }
        }
        
        /*if(!contAccIdsToRecalculateAddCustLocSharing.isEmpty()){
            Map<Id, User> communityUsersMap = new Map<Id, User>(UserUtility.getAllPartnerCommunityUsersByContacts(contAccIdsToRecalculateAddCustLocSharing.keyset()));
            Map<Id, Set<Id>> usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(communityUsersMap.values());
            Set<String> addCustLocConAccIdSet = new Set<String>();
            for(Id userId : usersWithAddCustLocsMap.keySet()){
                if(communityUsersMap.containsKey(userId) && communityUsersMap.get(userId).ContactId != null &&
                   communityUsersMap.get(userId).Contact.AccountId != null &&
                   usersWithAddCustLocsMap.get(userId) != null &&
                   usersWithAddCustLocsMap.get(userId).contains(communityUsersMap.get(userId).Contact.AccountId)
                  ){
                      addCustLocConAccIdSet.add(String.valueOf(communityUsersMap.get(userId).ContactId)+String.valueOf(communityUsersMap.get(userId).Contact.AccountId));
                  }
            }
            
            if(!addCustLocConAccIdSet.isEmpty()){
                delete [SELECT Id FROM Other_Related_Customer_Location__c WHERE Related_Contact__c != null AND
                        Additional_Customer_Location__c != null AND
                        Related_Contact_Additonal_Cust_Loc__c IN: addCustLocConAccIdSet];
            }
        }*/
        
        if(!conAccsToRecalculate.isEmpty()){

            List<User> communityUsers = UserUtility.getAllPartnerCommunityUsersByContacts(conAccsToRecalculate);

            /* Account Sharing Delete and Recreate */
            AccountSharingUtility.deleteAllAccountRelatedSharing(communityUsers);
            AccountSharingUtility.initiateAccountSharing(communityUsers,AccountUtility.getAccountAllAccountsToShareWithCommunityUsers(communityUsers));
        }

        /*
        if(!conToRecalculateContractSharing.isEmpty()){
            
            // Account Sharing Recreate for Share Contracts with Additional Country Responsability Users
            ContractSharingUtility.createAccountSharingForAdditionalCountryResponsabilityUsers(conToRecalculateContractSharing);
        }*/

		if(!conToRecalculate.isEmpty()){

            /* Opportunity Sharing Delete and Recreate */
            OpportunitySharingUtility.deleteAllOpportunityRelatedSharing((new Map<Id, User>(usersToConsider)).keySet(), (new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(conToRevoke))).keySet());
            OpportunitySharingUtility.createOpportunitySharingFuture((new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(conToRecalculate))).keySet());

            /* Case Sharing Delete and Recreate */
            CaseSharingUtility.deleteAllCasesRelatedSharing((new Map<Id, User>(usersToConsider)).keySet(), (new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(conToRevoke))).keySet());
            CaseSharingUtility.createSharingForCaseFuture((new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(conToRecalculate))).keySet());
            
            /* Lead Sharing Delete and Recreate */
            //DAOUtilityWithoutShar.deleteAllLeadRelatedSharing(usersToConsider, LeadSharingUtility.allLeadsRelatedToAccounts(conToRevoke));
            //LeadSharingUtility.createSharingForLeadFuture((new Map<Id, User>(usersToConsider)).keySet(),(new Map<Id, Lead>(LeadSharingUtility.allLeadsRelatedToAccounts(conToRecalculate))).keySet());
            
            /* Child Lead Sharing Delete and Recreate */
            DAOUtilityWithoutShar.deleteAllChildLeadsRelatedSharing(usersToConsider, ChildLeadSharingUtility.allLeadsRelatedToAccounts(conToRevoke));
            ChildLeadSharingUtility.createSharingForLeadFuture((new Map<Id, User>(usersToConsider)).keySet(),(new Map<Id, Child_Lead__c>(ChildLeadSharingUtility.allLeadsRelatedToAccounts(conToRecalculate))).keySet());
        }

		if(!contactIdsToRecalculateKPISharing.isEmpty()){
            KPIsSharingRecalculationHelpDeskCase.createHelpDeskCase(UserUtility.getAllPartnerCommunityUsersByContacts(contactIdsToRecalculateKPISharing), true);
        }     
    }
    
    /* @Description

    The recalculation condition for update of a community contact ( for Opportunity & Case & Accounts)

    @param oldCon - Old contact to compare (From Trigger.old)
    @param newCon - New contact to compare (From Trigger.new)

    @return Boolean - True or false if the sharing recalculation is required
    */
    private static Boolean isRecalculationRequiredToShare(Contact oldCon,Contact newCon){
        return (oldCon.AccountId != newCon.AccountId  ||  
                oldCon.Additional_Country_Responsibility__c != newCon.Additional_Country_Responsibility__c || 
                oldCon.OwnerId != newCon.OwnerId) ;
    }

    /* @Description

    Recalculation logic for Account, There are multiple type of accounts shared (End Customers, Direct Customers) which are not applicable to Opportunity & Cases.
        Hence recalculation is done differently

    @param oldCon - Old contact to compare (From Trigger.old)
    @param newCon - New contact to compare (From Trigger.new)

    @return Boolean - True or false if the account sharing recalculation is required
    */
    private static Boolean isRecalculationRequiredToShareAccount(Contact oldCon,Contact newCon){

        return isRecalculationRequiredToShare(oldCon, newCon) ||
                oldCon.Business_Segment__c != newCon.Business_Segment__c ||
                oldCon.Sub_Segment__c != newCon.Sub_Segment__c;
    }
}