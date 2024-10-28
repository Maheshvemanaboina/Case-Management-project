/*
* @Author : Mohan 
* @Date : 31th Aug 2021
* @Desc : Batch  class to set the BOM delete flag, batch query configured in GeneralBatchSetting__c
		  custom settings.
* @Jira : SCPQ-1111
		
*/

global class BOMDeleteFlagSetBatch implements Database.Batchable<sObject>{
    public GeneralBatchSetting__c batchSettings = GeneralBatchSetting__c.getValues('BOMDeleteFlagSetBatch');
    public string bomBatchQuery = batchSettings.Batch_Query__c;
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query;
         Date todaydate = date.today();
            integer days = todaydate.day()-1;
            Date firstofday = todaydate.addDays(-days);	
        if(test.isRunningTest()){
            query = 'select Id,Delete__c,External_Key__c from CPQ_Bill_Of_Material_SAP__C' ;
        }else{           		
            query =bomBatchQuery+' And LastModifiedDate <=:firstofday';
        }
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        if(!scope.isEmpty()){
            BOMDeleteFlagSetBatchHelper.setDeleteFlag(scope);
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
    
}