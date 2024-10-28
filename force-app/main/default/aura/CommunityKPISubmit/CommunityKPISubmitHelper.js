({
    getKPIInfoWithUserData : function(component, event, helper) {

        var action = component.get("c.getKPIInformation");
        component.set("v.Spinner", true);
        action.setParams({
            kpiId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            var result;
            if (status === "SUCCESS") {
                result = response.getReturnValue();
                component.set("v.kpiInformation",result);
                component.set("v.Spinner", false);
            }
        });
        
        $A.enqueueAction(action);
    },

    handKPISubmission : function(component, event, helper){

        var action = component.get("c.handleSaveForSubmission");
        component.set("v.Spinner", true);
        action.setParams({
            kpiId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            var result;
            if (status === "SUCCESS") {
                component.set("v.Spinner",false);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    title: "Submission Successful",
                    message: "The record has been submitted to "+response.getReturnValue(),
                    type : "success"
                    
                }); 
                resultsToast.fire();
                
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})