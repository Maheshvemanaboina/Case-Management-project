/*******************************************************************************************************
* @author :  Nithin C.H
* @createddate :  06-07-2017
* @description : This Scheduled apex calss is invoked every year december 31st at 10 PM.
* this class will invoke batch apex class CloneMarketMapOpportunities_BATCH to start the market map cloning process
*/
global without sharing class CloneMarketMapOpportunities_SCHED implements Schedulable {

  private BGI_Salesforce_Settings__c  customSettings = BGI_Salesforce_Settings__c.getOrgDefaults(); //hierarchy custom setting which stores Default Organization Level Value like Financial Year,Batch Status Email Recipients

// private static String cronExpression= '0 0 22 31 12 ? *'; // scheduled job will run every year 31st december at 10 PM

/*******************************************************************************************************
* @description : this method triggers Market Map opportunities cloining process based on scope set in custom settings BGI Salesforce Settings
* @param SchedulableContext : Represents the parameter type of a method in a class that implements the Schedulable interface and contains the scheduled job ID
* @return void : this method does not return any value
*/
global void execute(SchedulableContext SC) {
     //call batch apex CloneMarketMapOpportunities_BATCH and schedule for next year december 31st 10 PM
     Database.executeBatch(new CloneMarketMapOpportunities_BATCH(),integer.valueof(customSettings.No_Of_Opportunities_Per_Batch__c)) ; 

   }
}