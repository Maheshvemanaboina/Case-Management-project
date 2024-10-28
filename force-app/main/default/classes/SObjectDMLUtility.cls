/**       
@Name           - SObjectDMLUtility
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 25-07-2023
@UsedBy         - 1. Flow - Update LSD Status to Expired

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 25-07-2023 | Created class
--------------------|-------------------------------------|------------|--------------

* @description It updates the list of SObject records passed from the flow and log the erros in debug log object if any errors occurred during the update
*/
public class SObjectDMLUtility {
    /** 
     * @description Add the SObject records collected from the flow to a list, update the list and the log errors if any
     * @param	requests -	Wrapper of the Invocable variables passed from the flow
     */
    @InvocableMethod(
        label = 'SObjectDMLUtility'
        description = 'Updates the list of sObject records collected from the flow'
    )
    public static void performDML(List<Request> requests){
        
        List<SObject> sObjectRecordsList = new List<SObject>();
        List<DebugLog__c> errorLogs = new List<DebugLog__c>();
        
        for(Request req : requests){
            sObjectRecordsList.addAll(req.sObjectList);
        }
        
        //Create DebugLogWrapper instance which will be used to log more details if error occurs during dml operation
        DebugLogUtility.DebugLogWrapper logWrapObj = new DebugLogUtility.DebugLogWrapper(
            requests[0].objectLabel,
            requests[0].objectAPIName,
            'Apex Class',
            'SObjectDMLUtility',
            'performDML',
            'Error'
        );
        
        logWrapObj.dmlType = requests[0].dmlType; //Set DML Operation that needs to be performed on the list of sobject records
        logWrapObj.comments = requests[0].comments; //Set comments which will be logged in the comments field of debug log record when error occurred
        logWrapObj.typeName = requests[0].typeName; //Set Error Type/Category to categorize and identify the corresponding debug log records easily
        
        //Perform insert or update operation on the list of sobject records that are collected from the flow
        DebugLogUtility.performInsertOrUpdate(sObjectRecordsList, logWrapObj);
    }
        
    //Wrapper that contains all the invocable variables passed from the flow
    public class Request{
        
        @InvocableVariable(
            label = 'Sobject List'
            description = 'List of Sobject records to be processed'
            required = true
        )
        public List<SObject> sObjectList;
        
        @InvocableVariable(
            label = 'DML Operation'
            description = 'Please enter the valid DML operation that needs to be performed - INSERT/UPDATE/DELETE/UNDELETE/UPSERT'
            required = true
        )
        public String dmlType;
        
        @InvocableVariable(
            label = 'SObject Label'
            description = 'Please enter the Label of the SObect'
            required = true
        )
        public String objectLabel;
        
        @InvocableVariable(
            label = 'SObject API Name'
            description = 'Please enter the API Name of the SObect'
            required = true
        )
        public String objectAPIName;
        
        @InvocableVariable(
            label = 'Comments'
            description = 'More details if error occurs, such as Triggering Point, Triggering Object, etc., Please Enter atleast the Triggering Point.'
            required = true
        )
        public String comments;
        
        @InvocableVariable(
            label = 'Error Category'
            description = 'Enter the Category for this error to filter the debug log records easily'
            required = true
        )
        public String typeName;
    }
}