/*       
@Name           - UpdateLeadQueue
@Author         - suyogya jain
@ModifiedBy     - 
@Version        - 1.0
@CreatedDate    - 28-02-2022
@UsedBy         - inactiveLeadDeletionBatch
@Description    - Used to add update call in apex queue since 'leadSharingUtility - LeadTriggerHandler' future method is called in turn from class 'inactiveLeadDeletionBatch'
 */



public class UpdateLeadQueue implements Queueable{
    class MyException extends Exception{}
 public List<lead> ldList ; 
    map<id,lead> leadMapToUpdate = new map<id,lead>();
    list<DebugLog__c> debugLogsToInsert = new list<DebugLog__c>();
    
    public UpdateLeadQueue(List<lead> leadList){
        this.ldList = leadList ;  
    }
    public void execute(QueueableContext context) {       
        try{
            leadMapToUpdate.putall(ldList);
        	update leadMapToUpdate.values();
             if(Test.isRunningTest())
                {
                    throw new MyException();
                }
        }    
        catch(Exception excp){
            debugLogsToInsert.add(logError('lead','',string.valueof(ldList),'Apex Class','UpdateLeadQueue','execute','Error',excp.getMessage(),'','When lead owner is updated',excp.getStackTraceString()));    
        }
        if(debugLogsToInsert.size()>0){
            insert debugLogsToInsert;
        }
        
        
    }
    
     public static DebugLog__c logError(String Objectname,string objectNumber,string record,string processType,string processName,string opertationName,string severity,string errorMessage,string status,string comment,string stackTrace){
        DebugLog__c errorLog = new DebugLog__c(); 
        errorLog.Object__c = Objectname;
        errorLog.Object_Number__c =objectNumber;
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