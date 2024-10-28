({
    handleCreatelead : function(component, event, helper) {
        var showValidationError = false;
        var vaildationFailReason = '';
        var fields = component.find("requiredField");
        var payload = event.getParams().response;
        fields.forEach(function (field) {
            // alert('hiii');
            if(field.get("v.fieldName") === 'Campaign_Name__c' && $A.util.isEmpty(field.get("v.value"))){
                showValidationError = true;
                vaildationFailReason = "Please fill all the required fields.";
            }
        });
        if (!showValidationError) {
            component.set("{!v.isLoading}", true);
            component.find("accForm").submit();
        }
        else {
            component.find('OppMessage').setError(vaildationFailReason);
            component.set('v.isLoading', false); 
        }
        // component.set("{!v.isLoading}", true);
    },
    handleError: function (component, event, helper) {
        component.set('v.isLoading', false);        
    },
    handleSuccess : function(component, event, helper) {
        component.set("{!v.isLoading}", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type":"success",
            "message": "The record has been saved successfully."
        });
        toastEvent.fire();
        var payload = event.getParams().response;
        var navService = component.find("navService");
        
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": payload.id,
                "objectApiName": "Lead",
                "actionName": "view"
            }
        }
        // event.preventDefault();
        navService.navigate(pageReference);  
    },
    cancelModel : function(component, event, helper) {
        var navService = component.find("navService");
        let pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'list'
            },
            state: {
                filterName: "Recent"
            }
        }
        navService.navigate(pageReference); 
    } 
})