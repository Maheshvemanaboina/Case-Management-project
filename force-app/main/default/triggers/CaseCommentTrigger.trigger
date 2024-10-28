trigger CaseCommentTrigger on CaseComment (after insert) {

    if(trigger.isAfter && trigger.isInsert){
    CaseCommentTriggerHandler caseCommentObj = new CaseCommentTriggerHandler();
    caseCommentObj.process();
    }    
     
}