/****************************************************************************************       
@Name          : AdminRequestCreationQueueableTest
@Author        : Coreflex Team
@CreatedDate   : 12-09-2024
@Description   : Test class for AdminRequestCreationQueueableTest
******************************************************************************************/
@isTest
public class AdminRequestCreationQueueableTest {
    @IsTest
    static void testExecute() {
        User sysProfile = [SELECT Id, ProfileId, CreatedDate FROM User
                   			WHERE UserType = 'Standard' AND Profile.Name = 'System Administrator' AND IsActive = TRUE
                   			ORDER BY CreatedDate ASC LIMIT 1];
        System.runAs(sysProfile){
        Group groupInfo = [SELECT id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AccessNow_Request_Batch_Administrators' Limit 1];
            system.debug('groupInfo::'+groupInfo);
        GroupMember testGroupMember = new GroupMember(GroupId = groupInfo.Id, UserOrGroupId = sysProfile.Id);
        insert testGroupMember;        
        
       
        accessnow__ACNW_Permission__c permission = new accessnow__ACNW_Permission__c();
        permission.accessnow__SF_Permission_Id__c = sysProfile.ProfileId ;
        permission.accessnow__License_Required__c = 'Salesforce';
        permission.accessnow__Name__c = 'System Admin';
        permission.accessnow__Type__c = 'Profile';
        permission.accessnow__Approval_relavent__c = TRUE;
        INSERT permission;
        
        accessnow__ACNW_User_Permission__c userPermission = new accessnow__ACNW_User_Permission__c();
		userPermission.accessnow__Permission__c = permission.Id; 
        userPermission.accessnow__User__c = UserInfo.getUserId();
        INSERT userPermission;
        
        accessnow__ACNW_Request__c requestObj = new accessnow__ACNW_Request__c();
        requestObj.accessnow__Requested_Start_Time__c = System.now();
        requestObj.OwnerId = UserInfo.getUserId();
        requestObj.accessnow__Duration_Hours__c = System.Label.AccessNow_Batch_Request_duration;
        requestObj.accessnow__Reason_for_Escalation__c = 'Standard System Admin Request';
        requestObj.accessnow__Reference_Number__c = 'Batch Request Creation';
        requestObj.accessnow__Provision_Immediately__c = false;
        Insert requestObj;
		
       	accessnow__ACNW_Request_Permission__c reqeustPermissionRec = new accessnow__ACNW_Request_Permission__c();
        reqeustPermissionRec.accessnow__User_Permission__c = userPermission.Id;
        reqeustPermissionRec.accessnow__Request__c = requestObj.Id;
        Insert reqeustPermissionRec;
        
        requestObj.accessnow__Status__c = 'Approved';
        update requestObj;
        
        requestObj.accessnow__Status__c = 'In Progress';
        update requestObj;
            
        requestObj.accessnow__Status__c = 'Completed';
        update requestObj;
        }
    }
}