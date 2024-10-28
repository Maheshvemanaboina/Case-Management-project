/**
 * Created by KJM on 20/05/2019.
 */

public with sharing class Utilities {
    public static List<String> splitPicklistValues(String picklistValue) {
        if (String.isBlank(picklistValue)) {
            return new List<String>();
        }
        
        return picklistValue.split(';');
    }

    public static String returnValueOrEmpty(String val) {
        if (String.isNotEmpty(val)) {
            return val;
        }

        return '';
    }

    public static Boolean isPicklistFieldContainsValue(List<String> valuesToCheck, String picklistFieldToCheck) {
        List<String> fieldValues = picklistFieldToCheck.split(Constants.SALESFORCE_PICKLIST_SEPARATOR);
        for (String val : valuesToCheck) {
            if (String.isBlank(val)) {
                continue;
            }

            if (fieldValues.contains(val)) {
                return true;
            }
        }

        return false;
    }

    public static void sendEmailOnBatchFinish(String batchName, Database.BatchableContext bc) {
        AsyncApexJob a = [
                SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id =:bc.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject(batchName + ' ' + a.Status);
        mail.setPlainTextBody('Records processed ' + a.TotalJobItems +   ' with ' + a.NumberOfErrors + ' failures.');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
/******************************************************************************
* Author : Shweta
* Date : 1 July 2021
* Description : This method is used to send email notifications for multiple users when the batch job is completed.
* Parameters : Batch class name , Database.BatchableContext,List of To Addresses. 
* Return : Void
* *****************************************************************************/
    
    public static void sendEmailNotificationOnBatchFinish(String batchName, Database.BatchableContext bc, List<String> toAdd) {
        AsyncApexJob a = [
                SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id =:bc.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAdd);
        mail.setSubject(batchName + ' ' + a.Status);
        mail.setPlainTextBody('Records processed ' + a.TotalJobItems +   ' with ' + a.NumberOfErrors + ' failures.');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

/******************************************************************************
* Author : Shweta
* Date : 9 July 2021
* Description : This method is used for error handling when the exception is occured by creating the debug logs.
* Parameters : Exception, List of sObject, comment string
* Return : Void
* *****************************************************************************/
    
    public static void generateDebugLogsForErrorHandling(Exception stackedError, List<sObject> objList, String comment){
        
        // Log an error //
                    Boolean  isDmlException = stackedError.getTypeName() == 'System.DmlException' || stackedError.getTypeName() == 'System.EmailException';
                    String   dmlTypeName    = !isDmlException ? null : String.valueOf( stackedError.getDmlType( 0 ) );
                    String   dmlMessage     = !isDmlException ? null : stackedError.getDmlMessage( 0 );
                    String[] dmlFieldNames  = !isDmlException ? null : stackedError.getDmlFieldNames( 0 );
                    String   typeName       = stackedError.getTypeName();
                    String   message        = stackedError.getMessage();
                    DebugLog__c debugLog    = new DebugLog__c(
                        Severity__c         = 'Error',
                        Comments__c         = comment,
                        Message__c          = dmlMessage    != null ? dmlMessage.left( 255 ) : null,
                        Cause__c            = message       != null ? message.left( 255 ) : null,
                        TypeName__c         = dmlTypeName   != null ? dmlTypeName.left( 255 ) : typeName != null ? typeName.left( 255 ) : null,
                        Fields__c           = dmlFieldNames != null ? String.valueOf( dmlFieldNames ).left( 32768 ) : null,
                        StackTraceString__c = stackedError.getStackTraceString().left( 32768 ),
                        Record__c           = JSON.serialize(objList).left( 32768 ),
                        DateTime__c         = System.now()
                    );
                    Database.insert( debugLog, false );
    }
    /*public static String getAllAvailablePicklistValues(SObjectField obj) {
        String valuesString = '';
        for (Schema.PicklistEntry pickListEnt : obj.getDescribe().getPicklistValues()){
            valuesString += pickListEnt.getValue() + Constants.SALESFORCE_PICKLIST_SEPARATOR;
        }
        valuesString = valuesString.removeEnd(Constants.SALESFORCE_PICKLIST_SEPARATOR);
        return valuesString;
    }*/
}