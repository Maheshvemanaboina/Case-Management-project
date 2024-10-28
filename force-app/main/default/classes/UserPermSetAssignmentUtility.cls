/*       
@Name           - UserPermSetAssignmentUtility
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 16-03-2022
@UsedBy         - 1. UserTriggerHandler

@Description    - Permission Set Assignment for the Standard Community users if the associated contact is having Additional Country Responsibility

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 22-03-2022 | Created class
--------------------|-------------------------------------|------------|--------------
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 22-04-2022 | Added logic to add/remove permission set on updating community user role for FCI Distributor community user
*/
public with sharing class UserPermSetAssignmentUtility {
    
    static final Id kpiFieldAccessPermissionSetId = PermissionSetAssignmentUtility.getSelectedPermissionSetId('Additional_Access_to_Distributor_Community_Manager_Users');
    static final Map<Id, Profile> profileMap = new Map<Id, Profile>(
        [SELECT Id, UserLicense.Name FROM Profile WHERE
         Name =: Constants.TEST_FCI_DISTRIBUTOR_PROFILE AND
         UserLicenseId IN (SELECT Id FROM UserLicense WHERE Name =: Constants.FCI_DISTRIBUTOR_PROFILE_LICENSE)]
    );
    
    /* @Description
        Method Name : assignKPIsFieldAccessPermissionSet(List<User> newUsersList)

        1. Only runs on After Insert
        2. Creates PermissionSetAssignment for the newly created user if the user's associated contact has at least one country in the
		Additional Country Responsibility field
        
        @PARAMS
            1. NAME ( newUsersList ) => TYPE ( List<User> ) => DESCRIPTION ( All new users coming from Trigger.New when users are created )
    */
    public static void assignKPIsFieldAccessPermissionSet(List<User> newUsersList){
        Map<Id, Id> contactUserMap = new Map<Id, Id>();
        Set<Id> managerUserIdsToAssignPermissionSet = new Set<Id>();
        
        for(User usr : newUsersList){
            if(isDistiCommunityActiveUser(usr, profileMap))
            {
                if(UserUtility.isUserStandardCommunityUser(usr)) contactUserMap.put(usr.ContactId, usr.Id);
                else if(UserUtility.isUserManagerCommunityUser(usr)) managerUserIdsToAssignPermissionSet.add(usr.Id);
            }
        }
        
        if(!contactUserMap.isEmpty() || !managerUserIdsToAssignPermissionSet.isEmpty()) assignPermissionSetFuture(contactUserMap, managerUserIdsToAssignPermissionSet);
    }
    
    /* @Description
        Method Name : assignPermissionSetFuture(Map<Id, Id> contactUserMap, Id kpiFieldAccessPermissionSetId)

        1. Future method to execute this in different thread as we are performing dml operation on setup object
		   (PermissionSetAssignment)
        2. Creates the PermissionSetAssignment records based on the inputs provided
        
        @PARAMS
            1. NAME ( contactUserMap ) => TYPE ( Map<Id, Id> ) => DESCRIPTION ( newly created user id and its associated contact id )
			2. NAME ( kpiDLFieldPermissionSetId ) => TYPE ( Id ) => DESCRIPTION ( Id of the PermissionSet that needs to be asigned automatically
			   when the new user (whose associated contact's additional country responsibility is not blank) is created )
    */
    @future
    static void assignPermissionSetFuture(Map<Id, Id> contactUserMap, Set<Id> managerUserIdsToAssignPermissionSet){
        List<PermissionSetAssignment> assignPermissionSet = new List<PermissionSetAssignment>();
        if(contactUserMap != null && !contactUserMap.isEmpty()){
            for(Contact contactRecord : [SELECT Id FROM Contact WHERE Additional_Country_Responsibility__c != null
                                         AND Id IN : contactUserMap.keySet()])
            {
                if(contactUserMap.containsKey(contactRecord.Id))
                    assignPermissionSet.add(PermissionSetAssignmentUtility.addPermissionSetAssignment(contactUserMap.get(contactRecord.Id), kpiFieldAccessPermissionSetId));
            }
        }
        
        if(managerUserIdsToAssignPermissionSet != null && !managerUserIdsToAssignPermissionSet.isEmpty()){
            for(Id managerUserId : managerUserIdsToAssignPermissionSet){
                assignPermissionSet.add(PermissionSetAssignmentUtility.addPermissionSetAssignment(managerUserId, kpiFieldAccessPermissionSetId));
            }
        }
        
        if(!assignPermissionSet.isEmpty()) DAOUtilityWithoutShar.insertWithoutAccess(assignPermissionSet);
    }
    
    /* @Description
        Method Name : assignOrRemoveKPIsFieldAccessPermissionSet(Map<Id, User> userOldMap, List<User> newUsersList)

        1. Only runs on After Update
        2. Creates/deletes PermissionSetAssignment if the Community User role is updated on FCI Distributor community user record
        
        @PARAMS
			1. NAME ( userOldMap ) => TYPE ( Map<Id, User> ) => DESCRIPTION ( old Version of User records when the user is updated )
            1. NAME ( newUsersList ) => TYPE ( List<User> ) => DESCRIPTION ( All new users coming from Trigger.New when user records are updated )
    */
    public static void assignOrRemoveKPIsFieldAccessPermissionSet(Map<Id, User> userOldMap, List<User> newUsersList){
        Set<Id> usersIdsToRevokePermissionSet = new Set<Id>();
        Set<Id> usersIdsToAssignPermissionSet = new Set<Id>();

        Map<Id, PermissionSetAssignment> userPermissionSetAssignmentMap = new Map<Id, PermissionSetAssignment>(
            PermissionSetAssignmentUtility.getPermSetAssignmentForSelectedUsers(newUsersList, kpiFieldAccessPermissionSetId)
        );
        for(User usr : newUsersList){
            if(usr.Community_User_Role__c != userOldMap.get(usr.Id).Community_User_Role__c){
                if(
                    isDistiCommunityActiveUser(usr, profileMap) && UserUtility.isUserManagerCommunityUser(usr)
                    && !userPermissionSetAssignmentMap.containsKey(usr.Id)
                ){
                    usersIdsToAssignPermissionSet.add(usr.Id);
                }
                else if(UserUtility.isUserStandardCommunityUser(usr) && userPermissionSetAssignmentMap.containsKey(usr.Id))
                    usersIdsToRevokePermissionSet.add(usr.Id);
            }
        }
        
        if(!usersIdsToRevokePermissionSet.isEmpty() || !usersIdsToAssignPermissionSet.isEmpty())
        assignOrRemoveKPIsFieldAccessPermissionSetFuture(usersIdsToRevokePermissionSet, usersIdsToAssignPermissionSet);
    }
    
    /* @Description
        Method Name : assignOrRemoveKPIsFieldAccessPermissionSetFuture(Set<Id> usersIdsToRevokePermissionSet, Set<Id> usersIdsToAssignPermissionSet)

        1. Future method to execute this in different thread as we are performing dml operation on setup object
		   (PermissionSetAssignment)
        2. Creates/deletes the PermissionSetAssignment records when the Community User Role is updated from Standard User to
		   Manager User and vice-versa
        
        @PARAMS
            1. NAME ( usersIdsToRevokePermissionSet ) => TYPE ( Set<Id> ) => DESCRIPTION ( UserIds for whom the Permission set needs to be removed )
			2. NAME ( usersIdsToAssignPermissionSet ) => TYPE ( Set<Id> ) => DESCRIPTION ( UserIds for whom the Permission set needs to be assigned )
    */
    @future
    public static void assignOrRemoveKPIsFieldAccessPermissionSetFuture(Set<Id> usersIdsToRevokePermissionSet, Set<Id> usersIdsToAssignPermissionSet){
        List<PermissionSetAssignment> assignPermissionSet = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> revokePermissionSet = new List<PermissionSetAssignment>();
        
        if(usersIdsToRevokePermissionSet != null && !usersIdsToRevokePermissionSet.isEmpty()){
            Map<Id, User> usersWithAdditionalCountryResp = new Map<Id, User>(
                [SELECT Id FROM User WHERE ContactId != null AND Contact.Additional_Country_Responsibility__c != null AND
                 Community_User_Role__c =: Constants.COMMUNITY_USER_ROLE_STANDARD_USER AND Id IN: usersIdsToRevokePermissionSet]
            );
            usersIdsToRevokePermissionSet.removeAll(usersWithAdditionalCountryResp.keySet());
            
            if(usersIdsToRevokePermissionSet != null && !usersIdsToRevokePermissionSet.isEmpty()){
                Map<Id, PermissionSetAssignment> userPermissionSetAssignmentMap = PermissionSetAssignmentUtility.getPermSetAssignmentForSelectedUsers(usersIdsToRevokePermissionSet, kpiFieldAccessPermissionSetId);
                revokePermissionSet.add(userPermissionSetAssignmentMap.values());
            }
        }
        
        if(usersIdsToAssignPermissionSet != null && !usersIdsToAssignPermissionSet.isEmpty()){
            for(Id userId : usersIdsToAssignPermissionSet){
                assignPermissionSet.add(PermissionSetAssignmentUtility.addPermissionSetAssignment(userId, kpiFieldAccessPermissionSetId));
            }
        }
        if(!assignPermissionSet.isEmpty()) DAOUtilityWithoutShar.insertWithoutAccess(assignPermissionSet);
        if(!revokePermissionSet.isEmpty()) DAOUtilityWithoutShar.deleteWithoutAccess(revokePermissionSet);
    }
    
    //Reusable method that returns true if the User is Active and FCI Distributor community user
    static Boolean isDistiCommunityActiveUser(User usr, Map<Id, Profile> profileMap){
        return (usr.ContactId != null && usr.IsPortalEnabled && usr.isActive && profileMap.containsKey(usr.ProfileId) &&
                profileMap.get(usr.ProfileId).UserLicense.Name == Constants.FCI_DISTRIBUTOR_PROFILE_LICENSE);
    }
}