/******************************
* Written By : CoreFlex Solutions 
* Userstory : 155364
* Purpose : To Create the Answer records from the survey Response objects *
* ****************************/
public class QualtricsSurveyResponseTriggerHandler extends TriggerHandler {
    
        public override void processAfterInsert(){
        List<QualtricsAnswer__c> recordsToCreate = new List<QualtricsAnswer__c>();
        for(Qualtrics_Survey_Response__c response :(List<Qualtrics_Survey_Response__c>)Trigger.new){
            String projectname =response.Survey_Response_Name__c;
            recordsToCreate.addAll(IndividualAnswerRecordCreator.createIndividualsFromResponses(response,projectname));  
        }
        
        if (!recordsToCreate.isEmpty()) {
            try {
                insert recordsToCreate;
            } catch (DmlException e) {
                System.debug('Error creating Individuals: ' + e.getMessage());
            }
        }
        
    }
    
}