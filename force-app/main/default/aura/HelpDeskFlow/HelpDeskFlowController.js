({
    callFlow : function(component, event, helper) {
        component.set('v.isOpen', true);
        var flow = component.find('flow');
        flow.startFlow('Helpdesk_case_for_new_user_access');
    },
 
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
 
    closeModalOnFinish : function(component, event, helper) {
         if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
            var outputVar;
            var caseId;
            var outputVariables = event.getParam("outputVariables");
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === "caseId") {
                    caseId = outputVar.value;                    
                }  
            }
            if(caseId != ''){
                var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                    "recordId": caseId,
                    "isredirect": "true"
                });
                urlEvent.fire();
            }
        }
    }
})