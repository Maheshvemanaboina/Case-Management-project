/*******************************************************************************************
* User Story       AMS-42
* Created Date     06-jun-2024
* Created By       Manichandra
* @description     This is a test class for the AccessNowSchedule Apex class.
*****************************************/
@isTest
private class AccessNowScheduleTest {

    @isTest
    static void testRequestApprovalAccess() {
       User sysProfile = [SELECT Id, ProfileId, CreatedDate FROM User
                   WHERE UserType = 'Standard'
                   AND IsActive = TRUE
                   ORDER BY CreatedDate ASC 
                   LIMIT 1];
        
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
            
            
        accessnow__ACNW_Request__c req = new accessnow__ACNW_Request__c();
        req.accessnow__Duration_Hours__c = '2'; 
        req.accessnow__Provision_Immediately__c = false ;
        req.accessnow__Reason_for_Escalation__c = 'Test';
        req.accessnow__Requested_Start_Time__c = System.now().addMinutes(1);
        req.accessnow__Reference_Number__c =  '1234';
        req.OwnerId = UserInfo.getUserId();
        INSERT req;    
       
        accessnow__ACNW_Request_Permission__c reqPermissions = new accessnow__ACNW_Request_Permission__c();
        reqPermissions.accessnow__Request__c = req.Id;
        reqPermissions.accessnow__User_Permission__c = userPermission.Id;
        INSERT reqPermissions;
        
        
        AccessNowSchedule.requestWrapper wrapper = new AccessNowSchedule.requestWrapper();
        wrapper.requestId = req.Id;
        
        List<AccessNowSchedule.requestWrapper> wrappers = new List<AccessNowSchedule.requestWrapper>();
        wrappers.add(wrapper);
        
        Test.startTest();
        AccessNowSchedule.approveAccess(wrappers);
        Test.stopTest();
        
       
        
    }

}