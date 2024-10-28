/*
@Author     : Rohit Kumar
@CreatedDate: 10-05-2021
@UsedBy     : CaseCommentTrigger
@Description: Handler class to manage case comment trigger developments run order
*/

public with sharing class CaseCommentTriggerHandler extends TriggerHandler {

    public override void  processAfterInsert(){
         CaseUpdateOnCreationOfCaseCommentHandler.updateCaseStatusOnCreationOfCaseComment((List<CaseComment>)trigger.new);
    }
}