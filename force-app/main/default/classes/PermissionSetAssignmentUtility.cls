/*       
@Name           - PermissionSetAssignmentUtility
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 16-03-2022
@UsedBy         - 1. UserPermSetAssignmentUtility
				  2. ContactUtility

@Description    - Utility class for Permission Set Assignment based on the given users and permission set id

UserId              | Author-Email                        | Date          | Comment
====================|=====================================|===============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 22-03-2022    | Created class
--------------------|-------------------------------------|---------------|--------------
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 22-04-2022    | Added a method to get userId along with PermissionSetAssignment based on the selected userIds
*/
public with sharing class PermissionSetAssignmentUtility {
    
    /*
     * Return Value - This method returns the user id along with the permission set assignment record if you need to get the
     * PermissionSetAssignment records for the selected set of users.
	 * 
	 * Purpose - It is helpful if you need to remove the specific permission for some set of users
	*/
    public static Map<Id, PermissionSetAssignment> getPermSetAssignmentForSelectedUsers(List<User> usersList, Id permissionSetId){
        Map<Id, PermissionSetAssignment> userPermissionSetAssignmentMap = new Map<Id, PermissionSetAssignment>();
        for(PermissionSetAssignment psa : [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment
                                           WHERE AssigneeId IN : usersList AND
                                           PermissionSetId =: permissionSetId])
        {
            userPermissionSetAssignmentMap.put(psa.AssigneeId, psa);
        }
        return userPermissionSetAssignmentMap;
    }
    
    /*
     * Return Value - This method returns the user id along with the permission set assignment record if you need to get the
     * PermissionSetAssignment records for the selected set of users.
	 * 
	 * Purpose - It is helpful if you need to remove the specific permission for some set of users
	*/
    public static Map<Id, PermissionSetAssignment> getPermSetAssignmentForSelectedUsers(Set<Id> userIdSet, Id permissionSetId){
        Map<Id, PermissionSetAssignment> userPermissionSetAssignmentMap = new Map<Id, PermissionSetAssignment>();
        for(PermissionSetAssignment psa : [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment
                                           WHERE AssigneeId IN : userIdSet AND
                                           PermissionSetId =: permissionSetId])
        {
            userPermissionSetAssignmentMap.put(psa.AssigneeId, psa);
        }
        return userPermissionSetAssignmentMap;
    }
    
    /*
     * Return Value - returns the new instance of PermissionSetAssignment record by setting the AssigneeId and PermissionSetId
     * based on the given inputs
     * 
     * Usage - Useful while creating new PermissionSetAssignment record
	*/
    public static PermissionSetAssignment addPermissionSetAssignment(Id userId, Id permissionSetId){
        return new PermissionSetAssignment(
            AssigneeId = userId,
			PermissionSetId = permissionSetId
        );
    }
    
    /*
     * Return Value - Returns the permissionset id based on the given permissionset api name
     * 
     * Purpose - Helpful to get the Permission set id based on the permission set api name
	*/
    public static Id getSelectedPermissionSetId(String permissionSetApiName){
        return [SELECT Id FROM PermissionSet WHERE Name =: permissionSetApiName][0].Id;
    }
}