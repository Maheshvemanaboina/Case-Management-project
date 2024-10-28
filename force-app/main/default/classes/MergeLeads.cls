/**       
@Name           - MergeLeads
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 10-04-2023
@UsedBy         - 1. Flow - Update Child Lead Email

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 10-04-2023 | Created class
--------------------|-------------------------------------|------------|--------------

* @description merge lead records
*/
public without sharing class MergeLeads {    
    /** 
     * @description merge lead records based on the parameters passed.
     * @param	requests		-	List of instances of the input variables passed from the flow
     * @return	List<Response>	-	List of responses that needs to be returned to the flow
     */
    @InvocableMethod(
        label = 'Merge Leads'
        description = 'merge the lead records'
    )
    public static List<Response> mergeLeadRecords( List<Request> requests ) {

        /* Variables Declaration */
        
        // List to store the responses to be returned to the flow output variables
        List<Response> responses = new List<Response>();
        Lead masterLead = new Lead();
        List<Lead> duplicateLead = new List<Lead>();
        // Process the logic based on the parameters passed from the flow
        for (Request req : requests){
            masterLead = req.masterRecord;
            duplicateLead.add(req.duplicateRecord);
        }
        
        system.debug('masterLead => '+masterLead);
        system.debug('duplicateLead => '+duplicateLead);
        Database.MergeResult[] mergeResults = Database.merge(masterLead, duplicateLead, false);
        
        for(Database.MergeResult res : mergeResults){
            if (res.isSuccess()){
                
                // Add the response and add it to the response list which will be returned to the flow
                Response response = new Response();
                response.mergedSuccessfully = true;
                response.mergeError = 'Leads has been merged successfully.';
                responses.add(response);                    
            }else{
                for(Database.Error err : res.getErrors()) {
                    
                    // Add the response and add it to the response list which will be returned to the flow
                    Response response = new Response();
                    response.mergedSuccessfully = false;
                    response.mergeError = err.getMessage();
                    responses.add(response);
                }
            }
        }
        
        return responses;
    }

    /** 
     * @description Wrapper class which contains the invocable variables (displayed as input variables of this Invocable Apex Action in the flows) 
     */
    public class Request {
        
        @InvocableVariable(
            label = 'Master Record'
            description = 'Lead Record - Master'
        )
        public Lead masterRecord;
        
        @InvocableVariable(
            label = 'Duplicate Record'
            description = 'Lead Record - Duplicate'
        )
        public Lead duplicateRecord;
        
    }
    
    /**
     * @description Wrapper class which contains the invocable variables (displayed as output variables of this Invocable Apex Action in the flows) 
     */
    public class Response {
                
        @InvocableVariable(
            label = 'Is Merged?'
            description = 'Boolean variable to store whether the merge is successful or not'
        )
        public Boolean mergedSuccessfully;
        
        @InvocableVariable(
            label = 'Merge Error Message'
            description = 'Error Message while mergeing the lead records'
        )
        public String mergeError;
    }
}