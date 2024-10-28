/**
 * Created by KJM on 17/04/2019.
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
        
        component.set("v.defaultFields", {
                    'StageName' : 'Prospecting/Universe'
                });
    }
})