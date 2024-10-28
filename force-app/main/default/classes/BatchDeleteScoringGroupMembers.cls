public class BatchDeleteScoringGroupMembers implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'select id, Assessment_Scoring_Group__c from Scoring_Group_Member__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Scoring_Group_Member__c> records){
        system.debug('count '+ records.size());
        
        Database.deleteResult[] srList = Database.delete(records, false);
        for (Database.deleteResult result : srList) {
            if (result.isSuccess()) {
                //System.debug('Record Deleted is: ' + result.getId());
            }
            else {
                //Error ecountered              
                for(Database.Error error : result.getErrors()) {
                    //Handle error
                    System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                 ' Fields that affected the error: ' + error.getFields());
                    
                }
            }
        }
        Database.emptyRecycleBin(records); 
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}