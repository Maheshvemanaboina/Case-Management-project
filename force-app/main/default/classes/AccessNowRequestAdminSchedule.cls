global class AccessNowRequestAdminSchedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        // List to hold new request records to be inserted
        List<accessnow__ACNW_Request__c> requestObjList = new List<accessnow__ACNW_Request__c>();
        // List to hold new request permission records to be inserted
        List<accessnow__ACNW_Request_Permission__c> reqeustPermissionRecList = new List<accessnow__ACNW_Request_Permission__c>();
        // Map to associate UserId with User Permission Id
        Map<Id, Id> mapofUserPermission = new Map<Id, Id>();
        // Set to track UserIds who already have 'In Progress' requests
        Set<Id> inProgressUserIds = new Set<Id>();
        // Set to track UserIds belonging to the Access_Now_Administrators group
        Set<Id> groupUserIdSet = new Set<Id>();
        
        // Query GroupMember to get users in the 'Access_Now_Administrators' queue
        for (GroupMember userMembersInfo : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Type = 'Queue' 
                                            AND Group.DeveloperName = 'Acces_Now_Administrators']){
                                                groupUserIdSet.add(userMembersInfo.UserOrGroupId);
                                            }
        
        // Query for 'In Progress' requests owned by users in the group
        for (accessnow__ACNW_Request__c inprogressRequest : [SELECT OwnerId FROM accessnow__ACNW_Request__c WHERE accessnow__Status__c = 'In Progress'
                                                             AND OwnerId IN :groupUserIdSet]){
                                                                 inProgressUserIds.add(inprogressRequest.OwnerId);
                                                             }
        
        // Create new requests for group users who do not have 'In Progress' requests
        for (Id groupUser : groupUserIdSet) {
            system.debug('groupUser::'+groupUser);
            if (!inProgressUserIds.contains(groupUser)) {
                system.debug('groupUser contains::'+groupUser);
                accessnow__ACNW_Request__c requestObj = new accessnow__ACNW_Request__c(
                    accessnow__Requested_Start_Time__c = System.now(),
                    OwnerId = groupUser,
                    accessnow__Duration_Hours__c = '0.0625',
                    accessnow__Reason_for_Escalation__c = 'Standard System Admin Request',
                    accessnow__Reference_Number__c = 'Batch Request Creation',
                    accessnow__Provision_Immediately__c = false
                );
                requestObjList.add(requestObj);
                system.debug('requestObjList::'+requestObjList);
            }
        }
        
        // Insert the request objects if there are any to insert
        if (!requestObjList.isEmpty()) {
            insert requestObjList;
            System.debug('Requests inserted successfully: ' + requestObjList);
        }
        
        // Query user permissions for group members with 'System Admin' permission
        for (accessnow__ACNW_User_Permission__c permissionQuery : [SELECT Id, accessnow__User__c FROM accessnow__ACNW_User_Permission__c 
                                                                   WHERE accessnow__Permission_Name__c = 'System Admin' 
                                                                   AND accessnow__User__c IN :groupUserIdSet]) {
                                                                       mapofUserPermission.put(permissionQuery.accessnow__User__c, permissionQuery.Id);
                                                                   }
        
        // Create permission records for each request created
        for (accessnow__ACNW_Request__c request : requestObjList) {
            Id userPermissionId = mapofUserPermission.get(request.OwnerId);
            if (userPermissionId != null) {
                accessnow__ACNW_Request_Permission__c reqeustPermissionRec = new accessnow__ACNW_Request_Permission__c(
                    accessnow__User_Permission__c = userPermissionId,
                    accessnow__Request__c = request.Id
                );
                reqeustPermissionRecList.add(reqeustPermissionRec);
            }
        }
        
        // Insert the request permission records if there are any to insert
        if (!reqeustPermissionRecList.isEmpty()) {
            insert reqeustPermissionRecList;
            System.debug('Request Permissions inserted successfully: ' + reqeustPermissionRecList);
        }
        
        // Update the status of all inserted requests to 'Approved'
        for (accessnow__ACNW_Request__c request : requestObjList) {
            request.accessnow__Status__c = 'Approved';
        }
        
        // Perform the update operation on the requests
        if (!requestObjList.isEmpty()) {
            update requestObjList;
            System.debug('Requests updated successfully to Approved: ' + requestObjList);
        }
    }
    
}