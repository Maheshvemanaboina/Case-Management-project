/**
 * Created by KJM on 08/04/2019.
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
    
    getSessionInfo : function(component, event, helper) {
        var action = component.get("c.isAnotherUserLoginOnBehalf");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                if(response.getReturnValue() === false)
                {
                    $A.util.addClass(component.find("toggleArea"), "slds-hide");
                }
                //component.set("v.isUserTypeStandard", response.getReturnValue());
                console.log("UserType",response.getReturnValue());
            }
        
    });
        $A.enqueueAction(action);
    }
})