/**       
@Name           - GenerateTimeStamp
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 22-02-2023
@UsedBy         - 1. Flow - Create (or) Update Child Leads from the Campaign Member


UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 21-02-2023 | Created class
--------------------|-------------------------------------|------------|--------------
* @description To return the time stamp in logged in user time zone
*/
public class GenerateTimeStamp {
    /**
     * @description Return the current time stamp in the logged in user time zone.
     * @param	requests		-	List of instances of the input variables passed from the flow
     * @return	List<Response>	-	List of responses that needs to be returned to the flow
     */
    @InvocableMethod(
        label = 'Generate Time Stamp'
        description = 'Returns the time stamp of current time.'
    )
    public static List<Response> getTimeStamp( List<Request> requests ) {
        
        List<Response> responses = new List<Response>();
        
        for ( Request req : requests ) {
            
            Response res = new Response();
            res.timeStamp = String.valueOf(DateTime.now());
            responses.add(res);
        }
        return responses;
    }
    
    /**
     * @description Wrapper class which contains the invocable variables (displayed as input variables of this Invocable Apex Action in the flows) 
     */
    public class Request {
        
        @InvocableVariable(
            label = 'Time Stamp input variable'
            description = 'Generated Time Stamp is stored in this variable.'
        )
        public String timeStamp;
    }
    
    /**
     * @description Wrapper class which contains the invocable variables (displayed as output variables of this Invocable Apex Action in the flows) 
     */
    public class Response {
                
        @InvocableVariable(
            label = 'Time Stamp output variable'
            description = 'Generated Time Stamp is stored in this variable.'
        )
        public String timeStamp;
    }
}