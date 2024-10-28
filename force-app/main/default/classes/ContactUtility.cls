/*       
@Name           - ContactUtility
@Author         - Krzysztof Magdowski | Email - krzysztof.magdowski@waeg.com
@ModifiedBy     - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 2.0
@CreatedDate    - 29-08-2019
@UsedBy         - 1. ContactTriggerHandler

@Description    - Permission Set Assignment for the Standard Community users associated to the contacts with Additional Country Responsibility

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000005dHBKQA2  | krzysztof.magdowski@waeg.com          | 29-08-2019    | Created Class
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 22-03-2022    | Earlier it was an empty class, added the permission set assignment and removal logic
*/
public with Sharing class ContactUtility {
    
    /* @Description
        Method Name : assignKPIsFieldAccessPermissionSet(List<Contact> newContactsList, Map<Id, Contact> contactOldMap)

        1. Only runs on After Update
        2. Creates PermissionSetAssignment for the related user of the contact if at least one country is selected in the
		Additional Country Responsibility field and if it is updated from blank value
		3. Deletes PermissionSetAssignment for the related user of the contact if the Additional Country is updated to blank
        
        @PARAMS
            1. NAME ( newContactsList ) => TYPE ( List<Contact> ) => DESCRIPTION ( All updated contacts coming from Trigger.New when contacts are updated )
			2. NAME ( contactOldMap ) => TYPE ( Map<Id, Contact> ) => DESCRIPTION ( Old Version of the updated contacts coming from Trigger.newMap when contacts are updated )
    */
    public static void assignKPIsFieldAccessPermissionSet(List<Contact> newContactsList, Map<Id, Contact> contactOldMap){
        
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> contactIdsToRevokePSetAccess = new Set<Id>();
        Id kpiDLFieldPermissionSetId = PermissionSetAssignmentUtility.getSelectedPermissionSetId('Additional_Access_to_Distributor_Community_Manager_Users');
        
        for(Contact contactRecord : newContactsList){
            if(contactRecord.Additional_Country_Responsibility__c != contactOldMap.get(contactRecord.Id).Additional_Country_Responsibility__c){
                if(
                    String.isBlank(contactRecord.Additional_Country_Responsibility__c) ||
                    String.isBlank(contactOldMap.get(contactRecord.Id).Additional_Country_Responsibility__c)
                ) contactIdSet.add(contactRecord.Id);
                
                if(String.isBlank(contactRecord.Additional_Country_Responsibility__c)) contactIdsToRevokePSetAccess.add(contactRecord.Id);
            }
        }
        
        if(!contactIdSet.isEmpty()) assignPermissionSetFuture(contactIdSet, contactIdsToRevokePSetAccess, kpiDLFieldPermissionSetId);
    }
    
    /* @Description
        Method Name : assignPermissionSetFuture(Set<Id> contactIdSet, Set<Id> contactIdsToRevokePSetAccess, Id kpiDLFieldPermissionSetId)

        1. Future method to separate the transaction as we are performing dml operation on setup object (PermissionSetAssignment)
		   after the contact is updated
        2. Creates or deletes the PermissionSetAssignment records based on the inputs provided
        
        @PARAMS
            1. NAME ( contactIdSet ) => TYPE ( Set<Id> ) => DESCRIPTION ( All the updated contact ids to get the related users to assign/remove the permission set )
			2. NAME ( contactIdsToRevokePSetAccess ) => TYPE ( Set<Id> ) => DESCRIPTION ( Contact Ids for which the permission set needs to be removed )
			3. NAME ( kpiDLFieldPermissionSetId ) => TYPE ( Id ) => DESCRIPTION ( Id of the PermissionSet that needs to be asigned automatically when the contact's additional country responsibility is updated )
    */
    @future
    static void assignPermissionSetFuture(Set<Id> contactIdSet, Set<Id> contactIdsToRevokePSetAccess, Id kpiDLFieldPermissionSetId){
        
        List<PermissionSetAssignment> deletePermissionSet = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> assignPermissionSet = new List<PermissionSetAssignment>();
        
        List<User> usersList = UserUtility.getAllPartnerCommunityUsersByContacts(contactIdSet);
        Map<Id, PermissionSetAssignment> userPermissionSetAssignmentMap = new Map<Id, PermissionSetAssignment>(
            PermissionSetAssignmentUtility.getPermSetAssignmentForSelectedUsers(usersList, kpiDLFieldPermissionSetId)
        );
                
        for(User usr : usersList){
            if(UserUtility.isUserStandardCommunityUser(usr) && usr.Profile.Name == 'FCI Distributor Community User'){
                if(userPermissionSetAssignmentMap.containsKey(usr.Id)){
                    if(!contactIdsToRevokePSetAccess.isEmpty() && contactIdsToRevokePSetAccess.contains(usr.ContactId))
                        deletePermissionSet.add(userPermissionSetAssignmentMap.get(usr.Id));
                }else{
                    assignPermissionSet.add(PermissionSetAssignmentUtility.addPermissionSetAssignment(usr.Id, kpiDLFieldPermissionSetId));
                }
            }
        }
        
        if(!assignPermissionSet.isEmpty()) DAOUtilityWithoutShar.insertWithoutAccess(assignPermissionSet);
        if(!deletePermissionSet.isEmpty()) DAOUtilityWithoutShar.deleteWithoutAccess(deletePermissionSet);
    }
    
    public static void validateAccountChangeWithAdditionalCustLocs(List<Contact> newContacts){
        Map<Id, Id> contAccIdsToRecalculateAddCustLocSharing = new Map<Id, Id>();
        for(Contact con : newContacts){
            if(((Contact)trigger.OldMap.get(con.Id)).AccountId != con.AccountId){
                    contAccIdsToRecalculateAddCustLocSharing.put(con.Id, con.AccountId);
                }
        }
        
        if(!contAccIdsToRecalculateAddCustLocSharing.isEmpty()){
            Map<Id, User> communityUsersMap = new Map<Id, User>(UserUtility.getAllPartnerCommunityUsersByContacts(contAccIdsToRecalculateAddCustLocSharing.keyset()));
            Map<Id, Set<Id>> usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(communityUsersMap.values());
            Set<String> addCustLocConAccIdSet = new Set<String>();
            Set<Id> conIdsToThrowError = new Set<Id>();
            for(Id userId : usersWithAddCustLocsMap.keySet()){
                if(communityUsersMap.containsKey(userId) && communityUsersMap.get(userId).ContactId != null &&
                   usersWithAddCustLocsMap.get(userId) != null &&
                   contAccIdsToRecalculateAddCustLocSharing.containsKey(communityUsersMap.get(userId).ContactId) &&
                   usersWithAddCustLocsMap.get(userId).contains(contAccIdsToRecalculateAddCustLocSharing.get(communityUsersMap.get(userId).ContactId))
                  ){
                      //addCustLocConAccIdSet.add(String.valueOf(communityUsersMap.get(userId).ContactId)+String.valueOf(communityUsersMap.get(userId).Contact.AccountId));
                      conIdsToThrowError.add(communityUsersMap.get(userId).ContactId);
                  }
            }
            
            /*if(!addCustLocConAccIdSet.isEmpty()){
                delete [SELECT Id FROM Other_Related_Customer_Location__c WHERE Related_Contact__c != null AND
                        Additional_Customer_Location__c != null AND
                        Related_Contact_Additonal_Cust_Loc__c IN: addCustLocConAccIdSet];
            }*/
            if(!conIdsToThrowError.isEmpty()){
                for(Contact con : newContacts){
                    if(conIdsToThrowError.contains(con.Id))
                        con.AccountId.addError('You cannot add the Account same as in the Additional Customer location. Please delete the Additional Customer location and try again.');
                }
            }
        }
    }
}