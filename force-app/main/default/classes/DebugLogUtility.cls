/**
 * @description Utility class that contains reusable methods to perform dml operations on any sobject records and log the error records
 */
public without sharing class DebugLogUtility {
    
    /** 
     * @description Reusable method to update the list of sobject records and generate the error log instances
     * @param	records -	List of SObject records which needs to be updated
     * @param	debugLog - instance of the DebugLogWrapper which contains the details of the error
     * @param	errorLogs - List of error log records in which the error log instances are added
     */
    public static void dynamicUpdate(List<SObject> records, DebugLogWrapper debugLog, List<DebugLog__c> errorLogs){
        if(records.size() > 0) {
            String listType = 'List<' + debugLog.objectAPIName + '>';
            List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(records);
            Database.SaveResult[] srList = Database.update(castRecords, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){
                    for(Database.Error err : srList[i].getErrors()) {
                        DebugLog__c errs = logError(string.valueof(castRecords[i]),err.getStatusCode()+': '+err.getMessage(),'Occured when updating '+debugLog.objectLabel,debugLog);
                        errorLogs.add(errs);
                    }
                } 
            }
        }
    }
    
    /** 
     * @description Reusable method to insert/update the list of sobject records and insert the error log records
     * @param	records -	List of SObject records which needs to be inserted/updated
     * @param	debugLog - instance of the DebugLogWrapper which contains the details of the error
     */
    public static void performInsertOrUpdate(List<SObject> records, DebugLogWrapper debugLog){
        
        if(!records.isEmpty()){
            
            Database.SaveResult[] srList = debugLog?.dmlType == 'INSERT' ? Database.insert(records, false) : debugLog?.dmlType == 'UPDATE' ? Database.update(records, false) : new Database.SaveResult[]{};
                if(!srList.isEmpty()){
                    processSaveResultAndLogErrors(srList, records, debugLog);
                }
        }
    }
    
    /** 
     * @description Loops through the SaveResults of sobject records inserted/updated and inserts the error log records
     * @param	srList - List of Database.SaveResult records
     * @param	records - sobject records that were inserted/updated
     * @param	debugLog - instance of the DebugLogWrapper which contains the details of the error
     */
    private static void processSaveResultAndLogErrors(Database.SaveResult[] srList, List<SObject> records, DebugLogWrapper debugLog){
        List<DebugLog__c> errorLogs = new List<DebugLog__c>();
        
        for(Integer i=0;i<srList.size();i++){
            if(!srList[i].isSuccess()){
                for(Database.Error err : srList[i].getErrors()) {
                    DebugLog__c errs = logError(string.valueof(records[i]),err.getStatusCode()+': '+err.getMessage(),'Error Occured when updating '+debugLog?.objectLabel,debugLog);
                    errs.TypeName__c = debugLog?.typeName;
                    errs.Fields__c = string.join(err.getFields(),', ');
                    errs.Comments__c = debugLog.comments != null ? errs.Comments__c + '\n' + debugLog.comments : errs.Comments__c;
                    errs.RecordId__c = records[i].Id != null ? records[i].Id : '';
                    errorLogs.add(errs);
                }
            }
        }
        
        if(!errorLogs.isEmpty()){
            Database.insert(errorLogs, false);
        }
    }
    
    /**
        * @description  To add  errors in errorlog custom object
        * @param        record
        * @param        errorMessage
        * @param        comment
        * @param        debugLog
        * @return       DebugLog__c
    */ 
    public static DebugLog__c logError(String record, String errorMessage, String comment, DebugLogWrapper debugLog){
        DebugLog__c errorLog = new DebugLog__c(); 
        errorLog.Object__c = debugLog?.objectAPIName;
        errorLog.Record__c = record;
        errorLog.Errored_Process_Type__c = debugLog?.processType;
        errorLog.Errored_Process_Name__c = debugLog?.className;     
        errorLog.Operation_Name__c = debugLog?.methodName;
        errorLog.Severity__c = debugLog?.severity;
        errorLog.Message__c = errorMessage != null ? errorMessage.left(255) : null;
        errorLog.TypeName__c = 'INTERNAL ERROR';
        errorLog.Comments__c = comment;  
        return errorLog;
    }

	/**
	 * @description Wrapper class to store the main details to log the errors
	 */    
    public class DebugLogWrapper{
        public String objectLabel;
        public String objectAPIName;
        public String processType;
        public String className;
        public String methodName;
        public String severity;
        public String dmlType;
        public String comments;
        public String faultyFields;
        public String typeName;
        
        /**
            * @description  Constructor for this wrapper class
            * @param        objectLabel
            * @param        objectAPIName
            * @param        processType
            * @param        className
            * @param        methodName
            * @param        severity
    	*/
        public DebugLogWrapper(String objectLabel, String objectAPIName, String processType, String className, String methodName, String severity){
            this.objectLabel	=	objectLabel;
            this.objectAPIName	=	objectAPIName;
            this.processType	=	processType;
            this.className		=	className;
            this.methodName		=	methodName;
            this.severity		=	severity;
        }
    }
}