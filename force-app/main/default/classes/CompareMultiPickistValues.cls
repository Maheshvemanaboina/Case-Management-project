/**       
@Name           - CompareMultiPickistValues
@Author         - Praneeth Krishna | Email - praneeth.krishna@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 17-02-2023
@UsedBy         - 1. Flow - Update Child Lead
				- 2. Flow - Create (or) Update Child Leads from the Campaign Member

@Description    - Compare Multi-select picklist values with the campaign fields master data and return the common values

UserId              | Author-Email                          | Date       | Comment
====================|=======================================|============|==============
0054H000007nyPTQAY  | praneeth.krishna@frieslandcampina.com | 17-02-2023 | Created class
--------------------|---------------------------------------|------------|--------------
* @description Compare Multi-select picklist values with the campaign fields master data and return the common values
*/
public class CompareMultiPickistValues {
    
    /** 
     * @description Compare two multi-select picklist field values passed from the flow and return common values
     * @param	requests		-	List of instances of the input variables passed from the flow
     * @return	List<Response>	-	List of responses that needs to be returned to the flow
     */
    @InvocableMethod(
        label = 'Multi-Select Picklist Fields Comparison'
        description = 'Compares two field values from multi-select picklists (or any ; delimited text) and determines similarities'
    )
    public static List<Response> execute( List<Request> requests ) {
        
        List<Response> responses = new List<Response>();
        
        for ( Request req : requests ) {
            
            // avoid null pointer exceptions
            Set<String> picklistValuesA = String.isBlank( req.picklistA ) ? new Set<String>() : new Set<String>( req.picklistA.split('(\\s*;\\s*)') );
            Set<String> picklistValuesB = String.isBlank( req.picklistB ) ? new Set<String>() : new Set<String>( req.picklistB.split('(\\s*;\\s*)') );
            
            Set<String> commonValues = new Set<String>( picklistValuesA );
            commonValues.retainAll( picklistValuesB );
            
            Response res = new Response();
            
            // if this is called from flow, flow can't check if a variable list is empty
            // but it can check if the variable is null. So if any set is empty we return null.
            res.commonValues  = ( commonValues.size() > 0 )  ? String.join(new List<String>(commonValues), ';')  : null;
            responses.add( res );
            
        }
        
        return responses;
    }
    
    /**
     * @description Wrapper class which contains the invocable variables (displayed as input variables of this Invocable Apex Action in the flows) 
     */
    public class Request {
        
        @InvocableVariable(
            label = 'First Multi-Select Picklist'
            description = 'Value from first multi-select picklist field to compare'
        )
        public String picklistA;
        
        @InvocableVariable(
            label = 'Second Multi-Select Picklist'
            description = 'Value from second multi-select picklist field to compare'
        )
        public String picklistB;
        
    }
    
    /**
     * @description Wrapper class which contains the invocable variables (displayed as output variables of this Invocable Apex Action in the flows) 
     */
    public class Response {
                
        @InvocableVariable(
            label = 'Common Multi-Select Values'
            description = 'Common values found in both multi-select picklists'
        )
        public String commonValues;
    }
}