/*      
@Name                  ContactTriggerHandler
@Author                ?
@ModifiedBy            
@Version               1.1
@CreatedDate           ??-??-????
@UsedBy                ContactTrigger
@Description           Handler class to manage contact trigger developments run order
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
*/
public with sharing class ContactTriggerHandler extends TriggerHandler {
    
    /* @Description

    Method to manage developments order in after update contact trigger

    @return void
    */
    public override void processAfterUpdate(){
        ContactSharingUtility.recalculateContactSharingOnContactUpdate((List<Contact>)trigger.new, UserUtility.getAllCommunityUsers());
        //AccountMirrorSharingUtility.recalculateAccountMirrorSharingOnContactUpdate((Map<Id, Contact>)trigger.oldMap, (List<Contact>)trigger.new); // feature
        //CommunityKPISharingUtility.recalculateKPISharingOnContactUpdate((Map<Id, Contact>)trigger.oldMap, (List<Contact>)trigger.new);
        ContactUtility.assignKPIsFieldAccessPermissionSet((List<Contact>)trigger.new, (Map<Id, Contact>)trigger.oldMap);
    }
    
    public override void processBeforeUpdate(){
        ContactUtility.validateAccountChangeWithAdditionalCustLocs((List<Contact>)trigger.new);
    }
}