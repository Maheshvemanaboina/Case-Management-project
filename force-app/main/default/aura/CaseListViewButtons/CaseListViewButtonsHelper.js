/**
 * Created by KJM on 05/06/2019.
 */

({
     setRecordTypes : function(component, event, helper) {
        var action = component.get("c.getRecordTypeList");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.recordTypeOptions", result);
            }
        });
        $A.enqueueAction(action);
    },

    setUserInfo : function(component, event, helper) {
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.defaultFields", {
                    'ContactId' : result.ContactId,
                    'AccountId' : result.WorkLocationId,
                    'Parent_Account__c' : result.AccountId,
                    //'Sold_to_Location__c' : result.WorkLocationId,
                    'Status' : 'New'
                });
            }
        });
        $A.enqueueAction(action);
    }
});