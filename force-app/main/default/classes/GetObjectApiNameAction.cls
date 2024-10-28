/*------------------------------------------------------------  
Author:       João Almeida
Company:      Cognizant
Description:  Get the SObject API name using record Id
Test Class: CPQQuoteTriggerHandlerTest

History
2023-12-07    João Almeida    Created class
------------------------------------------------------------*/
public with sharing class GetObjectApiNameAction {

    @InvocableMethod(label='Get SObject API name through record Id')
    public static List<String> getSObjectApiName(List<Id> recordIds) {
        Set<String> objectApiNames = new Set<String>();
        if (recordIds != null) {
            for (Id recordId : recordIds) {
                try {
                    objectApiNames.add(recordId.getSObjectType().getDescribe().getName());
                }
                catch (Exception ex) {}
            }
        }
        return new List<String>(objectApiNames);
    }
}