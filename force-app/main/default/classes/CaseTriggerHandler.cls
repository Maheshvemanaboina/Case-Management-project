/*      
@Name                  CaseTriggerHandler
@Author                ?
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               1.1
@CreatedDate           ??-??-????
@UsedBy                CaseTrigger
@Description           Handler class to manage case trigger developments run order
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 03.03.2021 | Adjusted to call the CaseSharingUtility methods with new signatures
*/
public with sharing class CaseTriggerHandler extends TriggerHandler {


    /* @Description
       
        perform validation and prepopulate case fields based on some conditions on before insert

    @return void
    */
    public override void processBeforeInsert(){
        CaseFieldsValidationAndUpdates.validateAndUpdateFiledsOnBeforeInsert((List<Case>)trigger.new);
    }
    
    /* @Description

    Method to manage developments order in after insert case trigger

    @return void
    */
    public override void processAfterInsert(){
        CaseSharingUtility.recalculateCaseSharingOnCaseCreate((List<Case>)trigger.new);
        ComplaintBusinessSegmentAndOwnerUpdate.updateBusinessSegmentAndOwnerIfCreatedByCustomer((List<Case>)trigger.new);
    }

    /* @Description

    Method to manage developments order in after update case trigger

    @return void
    */
    public override void processAfterUpdate(){
        CaseSharingUtility.recalculateCaseSharingOnCaseUpdate((List<Case>)trigger.new, UserUtility.getAllFilteredCommunityUsers((List<Case>)trigger.new));
    }

    /* @Description

        perform validation and prepopulate case fields based on some conditions on before update

    @return void
    */
    public override void processBeforeUpdate(){
        CaseFieldsValidationAndUpdates.validateAndUpdateFiledsOnBeforeUpdate((List<Case>)trigger.new,(Map<id,case>)trigger.oldMap);
    }
    
}