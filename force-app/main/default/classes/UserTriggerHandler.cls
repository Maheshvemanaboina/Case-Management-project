/* 
*   04-08-2019 - Created by Sibananda to share accounts, Opportunities, cases on user create/Update.
*   29-01-2021 - Updated to move all code from UserTriggerHandler to UserSharingUtility & changes for New Account Re-design
*/
public with sharing class UserTriggerHandler extends TriggerHandler {

    public override void processAfterInsert(){
        
        UserSharingUtility.calculateSharingOnUserCreate((List<User>)trigger.new);
        UserPermSetAssignmentUtility.assignKPIsFieldAccessPermissionSet((List<User>)trigger.new);
    }

    public override void processAfterUpdate(){

        UserSharingUtility.recalculateSharingOnUserUpdate((List<User>)trigger.new);
        //userFCRoleSyncWithAccountTeamMemberRole.syncUserRoleWithATMRole((List<User>)trigger.new);
        UserPermSetAssignmentUtility.assignOrRemoveKPIsFieldAccessPermissionSet((Map<Id, User>)trigger.oldMap, (List<User>)trigger.new);
    }
   
}