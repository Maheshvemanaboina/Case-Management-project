({
    cloneAssessmentRecord : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get("c.cloneAssessment");
        action.setParam('assessmentId', recordId);
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state=='SUCCESS'){
                // Process server success response
                let returnValue = response.getReturnValue();
                let navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": returnValue.Id,
                    "slideDevName": "Detail"
                });
                navEvt.fire();
            }
            else {
                let errors = response.getError();
                helper.handleErrors(errors);
                //component.set("v.isLoading", false);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    // Process error returned by server
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            mode: 'sticky',
            title: "Error",
            message: $A.get("$Label.c.SRM_UnexpectedError") , // Default error message
            type: "error",

        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
});