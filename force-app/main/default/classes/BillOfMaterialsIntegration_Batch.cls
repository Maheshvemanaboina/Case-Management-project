/*------------------------------------------------------------
Author:       Hugo Costa
Company:      waeg
Description:  Batch process that will set the CPQ data having the SAP BW Forecast as original data

History
v1.0       2019-10-29    Hugo Costa    Created batch class
------------------------------------------------------------*/
global without sharing class BillOfMaterialsIntegration_Batch implements Database.Batchable<sObject>, Database.Stateful, Schedulable,Database.RaisesPlatformEvents {
     
	global void execute (SchedulableContext sc) {
		BillOfMaterialsIntegration_Batch cls = new BillOfMaterialsIntegration_Batch ();
		database.executebatch(cls, 100);
	}
    
	global Iterable<sObject> start(Database.BatchableContext BC){ 
		return BillOfMaterialsIntegration_DataHandler.getBoMReady(); 
	}     

	global void execute(Database.BatchableContext BC, List<AggregateResult> scope){
		if(scope != null){ 
			List<AggregateResult> bomList = scope;
			BillOfMaterialsIntegration_DataHandler.setBOMData(bomList);
		}
	}
    
	global void finish(Database.BatchableContext BC){
		
		integer toProcess = database.countQuery('select count() from CPQ_Bill_Of_Material_SAP__c where TECH_ToProcess__c = true');
		Id jobId = BC.getJobId();
		// Query the AsyncApexJob object to retrieve the current job's metadata.
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
           TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :jobId];             
               
        // Email the Batch Job's submitter that the Job is finished.
        // Note that this requires the email administration->deliverability->access level to be set to All Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Salesforce CPQ Bill Of Materials Integration - Batch');
        String strPlainTextBody = ' There are still ' + toProcess + ' to process. Please confirm the data. \n\n';
        strPlainTextBody += ' Best regards, \n';
		strPlainTextBody += ' Salesforce Suport Team \n\n';  
        strPlainTextBody += ' [No Replacement Job Executed]\n\n ';     
        strPlainTextBody += ' Salesforce.com Job Statistics:\n\n ';
        strPlainTextBody += ' Number of Errors='+job.NumberOfErrors+'\n\n ';
        strPlainTextBody += ' Status='+job.Status+'\n\n';
                     
        mail.setPlainTextBody(strPlainTextBody);
          
        if ( !Test.isRunningTest() ) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}