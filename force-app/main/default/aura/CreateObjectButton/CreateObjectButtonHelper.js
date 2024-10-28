/**
 * Created by KJM on 08/04/2019.
 */
({
    showModal : function(component, event, helper) {
        var modalContainer = component.find("modalContainer");
        $A.util.removeClass(modalContainer, "slds-hide");
    },

    hideModal : function(component, event, helper) {
        var modalContainer = component.find("modalContainer");
        $A.util.addClass(modalContainer, "slds-hide");
    },

    openNewObjectCreation : function(component, event, helper){

        var recordTypeValue = component.get('v.recordTypeValue');
        if (recordTypeValue != null && recordTypeValue != undefined && recordTypeValue != '') {
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": component.get("v.objectName"),
                "recordTypeId": recordTypeValue
            });
            debugger;
            var defaultFields = component.get("v.defaultFieldValues");
            if (defaultFields != null && defaultFields != '' && defaultFields != 'undefined') {
                 createRecordEvent.setParams({
                     "defaultFieldValues": component.get("v.defaultFieldValues")
                });
            }
            createRecordEvent.fire();
        } else {
            helper.displayError(component, true, "Please select record type.");
        }
    },

    displayError : function(component, displayError, errorMessage) {
        component.set("v.hasError", displayError);
        component.set("v.errorMessage", errorMessage);
    }

})