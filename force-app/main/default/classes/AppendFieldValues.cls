/**       
@Name           - AppendFieldValues
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 21-02-2023
@UsedBy         - 1. Flow - Update Child Lead

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 21-02-2023 | Created class
--------------------|-------------------------------------|------------|--------------

* @description Concatenation of Previous value with the new value for the text/text area fields of child lead record
*/
public class AppendFieldValues {
    
    /** 
     * @description Check whether any of the text/textArea fields of the child lead object already contains the value, if yes, append the newly added value.
     * @param	requests		-	List of instances of the input variables passed from the flow
     * @return	List<Response>	-	List of responses that needs to be returned to the flow
     */
    @InvocableMethod(
        label = 'Append Field Values'
        description = 'Checks the fields in which the value should be appended and returns the concatenated value'
    )
    public static List<Response> concatenateFieldValues( List<Request> requests ) {

        /* Variables Declaration */
        
        // List to store the responses to be returned to the flow output variables
        List<Response> responses = new List<Response>();
        
        //Set to store the list of fields for which the concatenation logic should be calculated
        Set<String> childLeadFields = new Set<String>();
        
        // Get Campaign object fields map
        Map<String, Schema.SObjectField> sObjFieldsMap = Schema.Campaign.getSObjectType().getDescribe().fields.getMap();
        
        // Get Child Lead object fields map
        Map<String, Schema.SObjectField> childLeadFieldsMap = Schema.Child_Lead__c.getSObjectType().getDescribe().fields.getMap();
        
        // Map to store the field api name and field values of the Campaign record passed as input variable from the flow
        Map<String, Object> campaignMap = new Map<String, Object>();
        
        // Process the logic based on the parameters passed from the flow
        for (Request req : requests){

            Boolean inputVariablesNotBlank = (req.campaignRecord != null && (req.masterLeadRecord != null || req.contactRecord != null) && req.childLeadRecord != null);
            
            String campaignRecordString = JSON.serialize(req.campaignRecord);
            campaignMap = (Map<String, Object>) JSON.deserializeUntyped(campaignRecordString);

            removeAttributesKeyFromtheMap(campaignMap);

            // Check whether the campaign record variable is passed from the flow and fields to be calculated is not empty
            if(
                getObjectAPIName(req.campaignRecord.Id) == 'Campaign' && !campaignMap.isEmpty() && inputVariablesNotBlank == true
              )
            {
                childLeadFields = getFieldsToCalculate(campaignMap, childLeadFieldsMap);
            }

            // Check whether the child lead record variable is passed from the flow and fields to be calculated is not empty
            if(getObjectAPIName(req.childLeadRecord.Id) == 'Child_Lead__c' && !childLeadFields.isEmpty()){

                String  leadOrContactMessageWithTimeStamp = '',
                        leadOrContactMessage='';
                
                req.childLeadRecord = concatenateAndUpdateFields(childLeadFields, req, childLeadFieldsMap);
            }
            
            // Add the response and add it to the response list which will be returned to the flow
            Response res = new Response();
            res.childLead = req.childLeadRecord;
            responses.add(res);
        }
        return responses;
    }
    
    /* @description get data type of the field
     * @param	objFieldMap		-	Map of the fields of an sObject
     * @param	objFieldApiName	-	Api name of the field for which you need to get the data type
     * @return	String			-	Data Type of the field
     */
    private static String getFieldType(Map<String, Schema.SObjectField> objFieldMap, String objFieldApiName){

        String objFieldApiNameLowerCase = objFieldApiName.toLowerCase(); // convert the field api name to lowercase
        
        String fieldType = objFieldMap.containsKey(objFieldApiName) ? String.valueOf(objFieldMap.get(objFieldApiName).getDescribe().getType()) :
        (objFieldMap.containsKey(objFieldApiNameLowerCase) ? String.valueOf(objFieldMap.get(objFieldApiNameLowerCase).getDescribe().getType()) : '');

        return fieldType;
    }

    /* @description get object api name
     * @param	recordId		-	sobject record id
     * @return	String			-	Api Name of the sObject
     */
    private static string getObjectAPIName(Id recordId){
        return recordId != null ? recordId.getSObjectType().getDescribe().getName() : '';
    }

    /* @description Get the List of fields that needs to be considered for concatenation calculation
     * @param	campaignMap				-	Map of field api name and field values of the Campaign record passed as input variable from the flow
     * @param	childLeadFieldsMap		-	sObject fields map (Child Lead object fields map)
     * @return	Set<String>				-	Set of field api names of the child lead object for calculation
     */
    private static Set<String> getFieldsToCalculate(Map<String, Object> campaignMap, Map<String, Schema.SObjectField> childLeadFieldsMap){

        /* Variables Declaration */
        String	fieldValue,
            	childLeadFieldType; // String variables to store ield value and the field type of each field based on the iteration
        
        Set<String> childLeadFieldsSet = new Set<String>(); // Set that collects all the child lead fields on which the concatenation logic needs to be calculated

        		// Loop through the lsit of fields and identify the actual fields on which the concatenation needs to be performed
                for(String fieldApiName : campaignMap.keySet()){
                    
                    fieldValue = String.valueOf(campaignMap.get(fieldApiName));
                    
                    childLeadFieldType = getFieldType(childLeadFieldsMap, fieldApiName.substringAfter('Calculate_'));
                                        
                    if(fieldValue == 'true' && Boolean.valueOf(fieldValue) && (childLeadFieldType == 'STRING' || childLeadFieldType == 'TEXTAREA')){
                        childLeadFieldsSet.add(fieldApiName.substringAfter('Calculate_'));
                    }
                }

        return childLeadFieldsSet;
    }

    /* @description Get the Child Lead record 
     * @param	fieldsList			-	Set of field api names of the child lead object for calculation
     * @param	reqObj				-	Instance of the input variables passed from the flow
     * @param	childLeadFieldsMap	-	Map of Child Lead fields
     * @return	Child_Lead__c		-	Child Lead record after calculating the concatenation logic for the required fields
     */
    private static Child_Lead__c concatenateAndUpdateFields(Set<String> fieldsList, Request reqObj, Map<String, Schema.SObjectField> childLeadFieldsMap){

        /* Variables Declaration */
        // String variables to store the corresponding field value of related lead or contact and field type of each field based on the iteration
        String  existingValue = '',
                leadOrContactMessage,
                leadOrContactMessageWithTimeStamp,
                childLeadFieldType;

        // Loop through the list of fields and set (or) append the new value
        for(String fieldToUpdate : fieldsList){

            // Get the data type of field of child lead object
            childLeadFieldType = getFieldType(childLeadFieldsMap, fieldToUpdate);
                  
            leadOrContactMessage = getParentLeadOrContactFieldValue(reqObj, fieldToUpdate);
            
            // Lead or Contact field value with the time stamp
            leadOrContactMessageWithTimeStamp = String.valueOf(DateTime.now()) + ' : ' + leadOrContactMessage;
            
            // Remove the html tags if any (in case of rich text area fields)
            leadOrContactMessageWithTimeStamp = leadOrContactMessageWithTimeStamp.stripHtmlTags();
            
            // Get the existing value of the field
            existingValue = String.valueOf(reqObj.childLeadRecord.get(fieldToUpdate));
            
            // Check if the value exists in the field, if yes, append otherwise assign the new value (copied from the related parent lead or contact)
            if(String.isBlank(existingValue)){
                reqObj.childLeadRecord.put(fieldToUpdate, leadOrContactMessageWithTimeStamp);
            }
            else if(String.isNotBlank(existingValue) && !existingValue.stripHtmlTags().containsIgnoreCase(leadOrContactMessage)){
                reqObj.childLeadRecord.put(fieldToUpdate, reqObj.childLeadRecord.get(fieldToUpdate) + (childLeadFieldType == 'TEXTAREA' ? '\n'+' <br/> ' : '') + leadOrContactMessageWithTimeStamp);
            }
        }
        return reqObj.childLeadRecord;
    }
    
    /* @description Check whether the child lead is related lead or contact and get corresponding field value that needs to be copied from the related parent lead or contact
     * @param	reqObj			-	Instance of the input variables passed from the flow
     * @param	fieldToUpdate	-	Child Lead field that needs to be updated
     * @return	String			-	corresponding field value that needs to be copied from the related parent lead or contact
     */
    private static String getParentLeadOrContactFieldValue(Request reqObj, String fieldToUpdate){
        
        // Store the corresponding field value of related lead or contact
        String leadOrContactMessage;
            leadOrContactMessage =	(reqObj.childLeadRecord.Is_Existing_Contact_Lead__c && reqObj.contactRecord != null && reqObj.contactRecord.get(fieldToUpdate) != null) ? String.valueOf(reqObj.contactRecord.get(fieldToUpdate)) :
            						(!reqObj.childLeadRecord.Is_Existing_Contact_Lead__c && reqObj.masterLeadRecord != null && reqObj.masterLeadRecord.get(fieldToUpdate) != null) ? String.valueOf(reqObj.masterLeadRecord.get(fieldToUpdate)) : '';
            
            // Remove the html tags if any (in case of rich text area fields)
            leadOrContactMessage = leadOrContactMessage.stripHtmlTags();
        return leadOrContactMessage;
    }
    
    /* @description Check whether the campaignMap contains the key attributes, if yes, remove it
     * @param	campaignMap		-	Map of Campaign field type as key and field value as its values
     */
    private static void removeAttributesKeyFromtheMap(Map<String, Object> campaignMap){
        if(campaignMap.containsKey('attributes')){
            campaignMap.remove('attributes');
        }
    }

    /** 
     * @description Wrapper class which contains the invocable variables (displayed as input variables of this Invocable Apex Action in the flows) 
     */
    public class Request {
        
        @InvocableVariable(
            label = 'Campaign Record'
            description = 'Campaign Record with all the fields that needs to be considered for the calculation'
        )
        public Campaign campaignRecord;
        
        @InvocableVariable(
            label = 'Child Lead Record'
            description = 'Child Lead Record with all the fields that needs to be included in the calculation'
        )
        public Child_Lead__c childLeadRecord;
        
        @InvocableVariable(
            label = 'Master Lead Record'
            description = 'Master Lead Record with all the fields that needs to be included in the calculation'
        )
        public Lead masterLeadRecord;
        
        @InvocableVariable(
            label = 'Contact Record'
            description = 'Contact Record with all the fields that needs to be included in the calculation'
        )
        public Contact contactRecord;
        
    }
    
    /**
     * @description Wrapper class which contains the invocable variables (displayed as output variables of this Invocable Apex Action in the flows) 
     */
    public class Response {
                
        @InvocableVariable(
            label = 'Child Lead Record'
            description = 'Field values are appended as per the configuration defined in the Campaign Record'
        )
        public Child_Lead__c childLead;
    }
}