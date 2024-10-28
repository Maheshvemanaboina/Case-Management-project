trigger QualtricsSurveyResponse on Qualtrics_Survey_Response__c (after insert, after update, before insert, before update, before delete) {
    
    QualtricsSurveyResponseTriggerHandler handler=new QualtricsSurveyResponseTriggerHandler();
    handler.process();
}