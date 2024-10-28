/**
 * Created by KJM on 26/08/2019.
 */

({
    runOrderAndDeliveryScript : function(component, event, helper){
        var action = component.get("c.runOrderAndDeliveryScriptOption");

        action.setParams({
            commercialCustomer : component.find('commCust').get('v.value'),
            customLocations : component.find('custLoc').get('v.value'),
            year : component.find('year').get('v.value'),
            communityName : component.find('commName').get('v.value'),
        });

        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var resp = response.getReturnValue();
                if (resp.Success == true) {
                    component.set('v.successMessage', 'Script created data successfully!');
                } else {
                     component.set('v.errorMessage', resp.ErrorMessage);
                }
            } else {
                component.set('v.errorMessage', 'An unexpected error has occurred, try again or contact the developer.');
            }
        });

        $A.enqueueAction(action);
    },
});