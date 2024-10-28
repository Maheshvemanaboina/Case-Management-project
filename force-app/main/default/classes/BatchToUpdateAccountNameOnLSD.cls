/*       
@Name                  BatchToUpdateAccountNameOnLSD
@Author                Rekha
@Version               1
@CreatedDate           24-08-2021
@UsedBy                
@Description           This batch updates account name on LSD records (Select LSD: Record type = LSD Agent,
					   SCAF Approval Status = Approved,Account Name = Blank, SAP Number <> Blank AND Match against Account records where
					   LSD:SAP Number = Account:SAP Number,Account: Record Type = Agent)
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
*/

global class BatchToUpdateAccountNameOnLSD implements Database.Batchable<sObject>,Schedulable{
    
    global void execute(SchedulableContext sc) {
        BatchToUpdateAccountNameOnLSD executeBatchToUpdate = new BatchToUpdateAccountNameOnLSD(); 
        database.executebatch(executeBatchToUpdate);
    }
    
   	 global Database.QueryLocator start(Database.BatchableContext bc) {   
         
         // query all LSD records with record type : LSD Agent and SCAF Approval status: Approved
         
		 string agentRecordType = system.label.LSD_Agent_Record_Type;
         string approvalStatus='Approved';
         String query='SELECT id,SAP_Number__c,Account_Name__c FROM Legal_Sales_Document__c';
         query = query+' WHERE recordtype.developerName =:agentRecordType and SAP_Number__c!=NULL and Account_Name__c=NULL';
         system.debug('----query'+query);
         return Database.getQueryLocator(query);
     } 
    
     global void execute(Database.BatchableContext BC, List<Legal_Sales_Document__c> batchList) {
         
         set<string> sapNumberSet = new set<string>();
         map<string,id> sapNumberAccountMap = new map<string,id>();
         list<Legal_Sales_Document__c> listofLSDSToUpdate = new list<Legal_Sales_Document__c>();
         list<DebugLog__c> errorLogs = new list<DebugLog__c>();
     
         if(!batchList.isEmpty()){
         	
             // collect all sap numbers from the list of LSD records
             for(Legal_Sales_Document__c lsd : batchList){
             	sapNumberSet.add(string.valueof(Integer.valueof(lsd.SAP_Number__c)));	    
             }
             //system.debug('------'+sapNumberSet);
             
             //match and find the account
             for(account acc : [SELECT id,SAP_Number__c,SAP_Number_Without_Zeros__c FROM account WHERE recordtype.developerName='BGI_Agent' and SAP_Number_Without_Zeros__c IN : sapNumberSet]){
             	sapNumberAccountMap.put(acc.SAP_Number_Without_Zeros__c,acc.id);    
             }
             //system.debug('------'+sapNumberAccountMap);
             
             //update the account name on LSD             
             for(Legal_Sales_Document__c lsd : batchList){   
                 string lsdSapNumber = string.valueof(Integer.valueof(lsd.SAP_Number__c));
                 if(!sapNumberAccountMap.isEmpty() && sapNumberAccountMap.containskey(lsdSapNumber) && sapNumberAccountMap.get(lsdSapNumber)!=NULL)                 
                 lsd.Account_Name__c = sapNumberAccountMap.get(lsdSapNumber);
                 listofLSDSToUpdate.add(lsd);
             }
             
             if(!listofLSDSToUpdate.isEmpty()){
                 //update listofLSDSToUpdate;
                 // DML statement
                 Database.SaveResult[] srList = Database.update(listofLSDSToUpdate, false);            
                 for(Integer i=0;i<srList.size();i++){
                    if(!srList[i].isSuccess()){  
                        for(Database.Error err : srList[i].getErrors()) {
                            DebugLog__c errs = logError('LSD','',string.valueof(listofLSDSToUpdate[i].id),string.valueof(listofLSDSToUpdate[i]),'Apex Class','BatchToUpdateAccountNameOnLSD','execute','Error',err.getStatusCode()+': '+err.getMessage(),'INTERNAL ERROR','When updating Account name from sap number on LSD','');
                            errorLogs.add(errs);
                        }
                    }    
                 }
                 
                 //insert debug log
                if(!errorLogs.isEmpty())
                insert errorLogs;
             }    
             
         }
     }

	 global void finish(Database.BatchableContext bc){
     } 
    
     //this method logs error 
     public static DebugLog__c logError(String Objectname,string objectNumber,string recordId,string record,string processType,string processName,string opertationName,string severity,string errorMessage,string status,string comment,string stackTrace){
        DebugLog__c errorLog = new DebugLog__c(); 
        errorLog.Object__c = Objectname;
        errorLog.Object_Number__c =objectNumber;
        errorLog.RecordId__c = recordId;
        errorLog.Record__c = record;
        errorLog.Errored_Process_Type__c = processType;
        errorLog.Errored_Process_Name__c = processName;      
        errorLog.Operation_Name__c = opertationName; 
        errorLog.Severity__c = severity;
        errorLog.Message__c = errorMessage;
        errorLog.TypeName__c = status;
        errorLog.Comments__c = comment;
        errorLog.StackTraceString__c  = stackTrace; 
        
        return errorLog;
     }

}