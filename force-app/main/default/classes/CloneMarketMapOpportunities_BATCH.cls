/*******************************************************************************************************
* @author :  Nithin C.H
* @createddate :  06-07-2017
* @description : This Batch apex calss is called from schedled apex class CloneMarketMapOpportunities_SCHED
* used to send market map opportuniteis and related objects records (OpportunityTeamMember,OpportunityLineItem,Salesforce_or_Non_Salesforce_User__c) every year 31st dec to a flow called  Market_Map_Opportunities_Cloning_Process
* marked map opportunities and related records are cloned via visual flow.This class will track the record processing status and send the status to the users mentioned in Batch Status Email Recipients field on custom setting BGI Salesforce Settings 
* name updating.
*/
global without sharing class CloneMarketMapOpportunities_BATCH implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    private Integer recordsProcessed; //this variable holds the number of processed market map opportunities
    private Integer totalRecords; //this variable holds the total marker map opportunities which are to be cloned
    private String  exceptionMessage; //this variable holds exceptions in start or execute method of batch apex
    private BGI_Salesforce_Settings__c  customSettings = BGI_Salesforce_Settings__c.getOrgDefaults(); //hierarchy custom setting which stores Default Organization Level Value like Financial Year,Batch Status Email Recipients 
    private String strSOQL; // this variable is used to create dyanamic SOQL for market map opportunities
    
    static final string  SPACE_FOR_SOQL= ' ';         // this  is used to add space in the code where required
    static final string  START_QUERY='SELECT  ';      // this is used for dynamic soql 
    static final string  COMMA_FOR_SOQL=',';          // this is used to introduce common in the code where required 
    static final string  TOTAL_PRICE='TotalPrice';    // this is used to ignore Total price field when retrieving records from opportunity line item
    static final string  PRODUCT_ID='Product2Id';      // this is used to ignore Product2Id field when retrieving records from opportunity line item
    static final string  SUCCESS_MESSAGE='success';     //success message from Visual Flow
    static final string  LINE_NUMBER =' at Line Number : '; //this used as constant to show the line number when there is exception
    static final string  TOTAL_OPPORTUNITY=' Total Market Map Opportunities = '; //this is used to show the Total Marker Map opportunities in the status email
    static final string  PROCESSED_OPPORTUNITY=' Opportunities Processed  = ';   //this is used to show the Opportuntities processed in the status email
    static final string  BATCH_ERROR_MESSAGE=' Batch Process failed with error. '; //this is used to show error the status email
    static final string  BACTH_SUCCESS_MESSAGE=' Batch Process completed. ';  //this is used to show Batch job is completed in the status email
    static final string  EXCEPTION_SOQL='Select Id FROM Opportunity  LIMIT 0';   //this is used to continue the execution in start method when there is any error in start method. reuturns no record
    static final string  FLOW_VARIBALE='Flow_Message';     //this is is used to show message from flow variable 
    


/*******************************************************************************************************
* @description : Market Map opportunities having quanity greater than zero , clone__c field  null  and close date is current financial year and set as One-off are retrieved in this method
* @param Database.BatchableContext :  Represents the parameter type of a batch job method and contains the batch job ID
* @return Database.QueryLocator : market map opportunities. when there is an error then error is captured in exceptionMessage variable.
* executed method is called with no rows to process
* 
*/
global Database.QueryLocator start(Database.BatchableContext bc) {
    try{
        
        totalRecords =0;     //initialize the total opportunity records  to 0
        recordsProcessed=0;   //initialize processed opportunity records  to 0
        
        Date startDate = Date.newInstance(customSettings.Financial_Year__c.year(), 1, 1); // this variable holds start date of the current year
        Date endDate =customSettings.Financial_Year__c; // this variable holds the end date of current financial year
        
        strSOQL = START_QUERY; // this variable is used to create dyanamic SOQL for market map opportunities
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.opportunity.fields.getMap();//all opportunity fields are stored in this map
        for(String fieldName : fieldMap.keyset()){
        strSOQL = strSOQL +  String.escapeSingleQuotes(fieldName) + COMMA_FOR_SOQL ;
        }
        strSOQL=strSOQL.removeEnd(COMMA_FOR_SOQL);  //remove comma from end of the string
        strSOQL =strSOQL  + SPACE_FOR_SOQL + System.Label.Opporunity_Condition ; //custom label for Opportunity condition.
       // System.debug('strSOQL ===>' + strSOQL);
        return Database.getQueryLocator(strSOQL);
     }
     catch(Exception ex)
     {
        //System.debug('Error occurred = ' +  ex.getMessage());
        exceptionMessage=ex.getMessage() + LINE_NUMBER +ex.getLineNumber();
        return Database.getQueryLocator(EXCEPTION_SOQL);
     }
        
    }
    
/*******************************************************************************************************
* @description : Market map opportunities and its child records are passed from this method to flow Market_Map_Opportunities_Cloning_Process for cloning purpose. 
* if there is an error in flow then flowMessage variable shows the error occurred for that batch.if no error flowMessage shows success and that scope is added to recordsProcessed variable
* @param Database.BatchableContext : Represents the parameter type of a batch job method and contains the batch job ID
* @param List<Opportunity> : this paramter holds the market map opportunities to process in the current batch
* @return void : this method does not return any value
* 
*/
 global void execute(Database.BatchableContext bc, List<Opportunity> scope){
  try{
    if(String.isBlank(exceptionMessage))
    {
        Map<Id,Opportunity> oldOpportunityIdMap = new Map<Id,Opportunity>();  // this map holds opportunity ids of market map opportunities 
        List<OpportunityTeamMember> oldOpportunityTeamMemberList = new List<OpportunityTeamMember>(); // this list holds opportunity team members of market map opportunities
        List<OpportunityLineItem>   oldOpportunityLineItemList   = new List<OpportunityLineItem>(); // this list holds oportunity products of market map opportunities
        List<Salesforce_or_Non_Salesforce_User__c> oldNonSalesforceTeamMembersList   = new List<Salesforce_or_Non_Salesforce_User__c>(); // this list holds Non Salesforce Team Members of market map opportunities
        Set<Id> oppIdSet =  new Set<Id>();
        
        totalRecords=totalRecords+scope.size();
        oldOpportunityIdMap.putAll(scope); //add all the records to map so that we can use records ids in related list
        oppIdSet = oldOpportunityIdMap.keyset();//put all the record ids to set to use in where clause of related lists
        
        strSOQL = START_QUERY; // this variable is holds dyanamic SOQL for OpportunityTeamMember
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.OpportunityTeamMember.fields.getMap();//all opportunity team members who are active fields are stored in this map
        for(String fieldName : fieldMap.keyset()){
        strSOQL = strSOQL + String.escapeSingleQuotes(fieldName) + COMMA_FOR_SOQL ;
        }
        strSOQL=strSOQL.removeEnd(COMMA_FOR_SOQL); 
        strSOQL =strSOQL + SPACE_FOR_SOQL +System.Label.OpportunityTeamMember_Condition; //custom label for Opportunity Team Member condition.
        //System.debug('strSOQL - OpportunityTeamMember  ===>' + strSOQL);
        oldOpportunityTeamMemberList = Database.query(strSOQL);
        
        
        strSOQL = START_QUERY;// this variable is holds dyanamic SOQL for Opportunity Products
        fieldMap = Schema.SObjectType.OpportunityLineItem.fields.getMap();//all opportunity products fields are stored in this map
        for(String fieldName : fieldMap.keyset()){ 
          if( !fieldName.equalsIgnoreCase(TOTAL_PRICE)&& !fieldName.equalsIgnoreCase(PRODUCT_ID)) //exclude total price and product2 id field because we cannot use these fields in FAST CREATE element in flow
           {
                strSOQL = strSOQL + String.escapeSingleQuotes(fieldName) + COMMA_FOR_SOQL ;  
           }              
           
        }
        strSOQL=strSOQL.removeEnd(COMMA_FOR_SOQL); 
        strSOQL =strSOQL+ SPACE_FOR_SOQL +  System.Label.OpportunityLineItem_Condition; //custom label for Opportunity Product condition.
        //System.debug('strSOQL - OpportunityLineItem ===>' + strSOQL);
        oldOpportunityLineItemList =Database.query(strSOQL);

        strSOQL = START_QUERY;// this variable is holds dyanamic SOQL for Salesforce_or_Non_Salesforce_User__c
        fieldMap = Schema.SObjectType.Salesforce_or_Non_Salesforce_User__c.fields.getMap();//all non salesforce team member lists are stored in this map
        for(String fieldName : fieldMap.keyset()){
        strSOQL = strSOQL + String.escapeSingleQuotes(fieldName) + COMMA_FOR_SOQL ;
        }
        strSOQL=strSOQL.removeEnd(COMMA_FOR_SOQL); 
        strSOQL =strSOQL + SPACE_FOR_SOQL+ System.Label.Non_Salesforce_Opportunity_Team_Condition; //custom label for Non Slaesforce Opportunity Team condition.
        //System.debug('strSOQL - Salesforce_or_Non_Salesforce_User__c  ===>' + strSOQL);
        oldNonSalesforceTeamMembersList =Database.query(strSOQL);
        
        
        //assign market map opportunities to Flow Collections
        Map<String, Object> params = new Map<String, Object>();
        List<String> listNames = new List<String>();
        listNames=System.Label.List_Names_in_Flow.split(COMMA_FOR_SOQL); //get all the 4 lists from custom label list names in flow
        params.put(listNames[0], scope);
        params.put(listNames[1], oldOpportunityTeamMemberList);
        params.put(listNames[2], oldOpportunityLineItemList);
        params.put(listNames[3], oldNonSalesforceTeamMembersList);

        // call the Flow
        Flow.Interview.Market_Map_Opportunities_Cloning_Process flowCall = new Flow.Interview.Market_Map_Opportunities_Cloning_Process(params);
        flowCall.start();

        //result from flow is stored in this variable
         String  flowMessage = (String) flowCall.getVariableValue(FLOW_VARIBALE); 
        // System.debug('flowMessage - ' + ' ' + flowMessage);
         
         if(flowMessage.equalsIgnoreCase(SUCCESS_MESSAGE))
         {
             recordsProcessed = recordsProcessed + scope.size(); // if flow cloned opportunity and related lists then only processed opportunity count is added to record Processed variable
         }
    
         
      }
    }
      catch(Exception ex)
        {
           // System.debug('Error occurred = ' +  ex.getMessage());
             exceptionMessage=ex.getMessage()+ LINE_NUMBER + ex.getLineNumber();
        }
        
        
    }    
/*******************************************************************************************************
* @description : Result from market map cloning process will be sent to the users in this method.
* if there is an error in this method. the email will not be sent to the users
* @param Database.BatchableContext : Represents the parameter type of a batch job method and contains the batch job ID
* @return void : this method does not return any value
* 
*/
global void finish(Database.BatchableContext bc){
        try
        {
            
            //System.debug('Total Market Map Opportunities = ' +  totalRecords);
            //System.debug('Opportunities Processed = ' +  recordsProcessed);
            //System.debug('exceptionMessage = ' +  exceptionMessage);
            
            String [] emailAddress=customSettings.Batch_Status_Email_Recipients__c.split(COMMA_FOR_SOQL); // email address from custom setting BGI Salesforce Settings
            String statusMessage=TOTAL_OPPORTUNITY+totalRecords +PROCESSED_OPPORTUNITY+recordsProcessed; // this variable status of total and processed opportunities
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailAddress); 
            mail.setSenderDisplayName(customSettings.Sender_Display_Name__c); 
            mail.setSubject(customSettings.Email_Subject__c);
            if(!String.isBlank(exceptionMessage) )
            {
              mail.setPlainTextBody(BATCH_ERROR_MESSAGE + exceptionMessage); //exceptions from start or execute method are set in the email body. 
            }
            else if(totalRecords <> recordsProcessed )
            {
              mail.setPlainTextBody(BACTH_SUCCESS_MESSAGE + statusMessage  + SPACE_FOR_SOQL +  customSettings.Batch_Job_Failue_Message__c); /*exceptions from flow are not cpatured. 
                                                                                                                                                                        report has to be created on market map opportuniteis to check status*/
            }
            else
            {
                
                customSettings.Financial_Year__c=Date.newInstance(customSettings.Financial_Year__c.year()+1, customSettings.Financial_Year__c.month(), customSettings.Financial_Year__c.day()); // when total market opportunites and processed opportunites both count matches then financial year in custom setting is incremented by 1 year 
                database.update(customSettings,false);
                mail.setPlainTextBody(BACTH_SUCCESS_MESSAGE + statusMessage + SPACE_FOR_SOQL + customSettings.Batch_Job_Success_Message__c ); 
            }
            
            Messaging.SendEmailResult[] results=Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           
        
        }
        catch(Exception ex)
        {
            //System.debug('Error occurred = ' +  ex.getMessage());
             exceptionMessage=ex.getMessage()+ LINE_NUMBER + ex.getLineNumber();
        }
        
        
    }    

}