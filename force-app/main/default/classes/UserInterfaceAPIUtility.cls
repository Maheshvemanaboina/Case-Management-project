/*
Created By : Sibananda Bhuyan
Create Date : 23-03-2020
Descrption : This class can be used to fetch any data using User Interface API.
This class uses the NAMED Credential : "Salesforce_UI_API_Credential" and Auth Provider : "Salesforce_UI_Auth"
Connected App : Salesforce User Interface App
*/

public without Sharing class UserInterfaceAPIUtility {
    
    public static final String SALESFORCE_UI_API_NAMED_CREDENTIAL = 'callout:Salesforce_UI_API_Credential';
    
    /*
	Method : getSinglePicklistValues
	Definition : This method return the controlling and dependent values for a specific record type for a specific object,
	It returns a wrapper which has 3 variables :
		1. controllingFieldValues : entire list of controlling field values
		2. dependentFieldValues : entire list of dependent field values
		3. controllingWithDependentValues : Map< controllingValue, List<DependentValue>>()

	This method takes 3 input : ( the sObjectAPIName, RecordTypeId, dependentfieldAPIName )
	NOTE: Always pass the dependent field API Name to "dependentfieldAPIName" parameter and not the controller field API Name , else results will not be correct.
	*/
    public static SinglePicklistWrapper getSinglePicklistValues(String sObjectAPIName,Id recordTypeId,String dependentfieldAPIName){
        
        String restAPIURL = SALESFORCE_UI_API_NAMED_CREDENTIAL + '/services/data/v48.0/ui-api/object-info/';
        restAPIURL = restAPIURL + sObjectAPIName + '/picklist-values/';
        restAPIURL = restAPIURL + recordTypeId + '/' + dependentfieldAPIName;
        
        HttpResponse response = new Http().send(getHttpRequest(restAPIURL,'GET'));
        system.debug('ui api response '+response.getBody());
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        //return Map<String,List<String>>()
        return getparentWithControllingMap(responseBody);
        
    }
    
    private static SinglePicklistWrapper getparentWithControllingMap(Map<String, Object> responseBody){
        
        Map<String,List<String>> parentControllingMap = new Map<String,List<String>>();
        
        Map<String,Object> controllervalues = (Map<String,Object>)responseBody.get('controllerValues');
        Map<String,Integer> controllingFieldvalueIndexMap = new Map<String,Integer>();
        
        for(String eachfield : controllervalues.keySet()){
            controllingFieldvalueIndexMap.put(eachfield, (Integer)controllervalues.get(eachfield));
        }
        
        Map<String,List<Integer>> dependentFieldValidForMap = new Map<String,List<Integer>>();
        
        List<Object> dependentValues = (List<Object>)responseBody.get('values');
        for(Integer i = 0; i < dependentValues.size() ; i++){
            Map<String, Object> a2 = (Map<String, Object>)dependentValues[i];
            
            List<Integer> validFor = new List<Integer>();
            for(Object obj : (List<Object>)a2.get('validFor')){
                validFor.add((Integer)obj);
            }
            dependentFieldValidForMap.put((String)a2.get('label'),validFor);
        }
        
        //prepare the parentControllingMap
        SinglePicklistWrapper wrapInstance = new SinglePicklistWrapper();
        for(String eachControllingFieldValue : controllingFieldvalueIndexMap.keySet()){
            
            wrapInstance.controllingFieldValues.add(eachControllingFieldValue);
            parentControllingMap.put(eachControllingFieldValue, new List<String>());
            
            for(String eachDependentFieldValue : dependentFieldValidForMap.keySet()){
                
                if(!wrapInstance.dependentFieldValues.contains(eachDependentFieldValue)){
                    wrapInstance.dependentFieldValues.add(eachDependentFieldValue);
                }
                if(dependentFieldValidForMap.get(eachDependentFieldValue).contains(controllingFieldvalueIndexMap.get(eachControllingFieldValue))){
                    
                    List<String> dependentValueSet = parentControllingMap.get(eachControllingFieldValue);
                    dependentValueSet.add(eachDependentFieldValue);
                    parentControllingMap.put(eachControllingFieldValue,dependentValueSet);
                }
            }
        }
        
        wrapInstance.controllingWithDependentValues = parentControllingMap;
        return wrapInstance;
    }
    
    public class SinglePicklistWrapper{
        @AuraEnabled public List<String> controllingFieldValues {get; set;}
        @AuraEnabled public List<String> dependentFieldValues {get; set;}
        @AuraEnabled public Map<String,List<String>> controllingWithDependentValues {get; set;}
        
        public SinglePicklistWrapper(){
            this.controllingFieldValues = new List<String>();
            this.dependentFieldValues = new List<String>();
            this.controllingWithDependentValues = new Map<String,List<String>>();
        }
    }
    
    private static httpRequest getHttpRequest(String endPointURL,String method){
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endPointURL);
        httpRequest.setMethod(method);
        return httpRequest;
    }
}