({
    setBusinessStrategyInfo : function(component,event,helper, businessStrategyId) {

        component.set("v.Spinner",true);
    	var action = component.get("c.getKPIInformation");
        action.setParams({
            kpiId : businessStrategyId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                component.set("v.Spinner",false);
                var result = response.getReturnValue();
                component.set("v.kpiInformation",result);
            }else {
                console.log('Error Message set business Info --> '+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    submitBusinessStrategy : function(component, event, helper, businessStrategyId) {

        component.set("v.Spinner",true);
    	var action = component.get("c.handleSaveForSubmission");
        action.setParams({
            kpiId : businessStrategyId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){

                component.set("v.Spinner",false);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    title: "Submission Successful",
                    message: "The record has been submitted to "+response.getReturnValue(),
                    type : "success"
                    
                }); 
                resultsToast.fire();
                
                $A.get('e.force:refreshView').fire();
                helper.closeModal(component, event, helper);
            }else {
                console.log('Error Message set business Info --> '+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    closeModal : function(component, event, helper) {

    	var modalContainer = component.find("modalContainer");
        $A.util.addClass(modalContainer, "slds-hide");
    },

    OpenModal : function(component, event, helper) {

    	var modalContainer = component.find("modalContainer");
        $A.util.removeClass(modalContainer, "slds-hide");
    },
})