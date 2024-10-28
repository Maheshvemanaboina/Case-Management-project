/**
 * Created by KJM on 26/08/2019.
 */

({
    handleRunScriptButtonClick : function(component, event, helper) {
        component.set('v.successMessage', '');
        component.set('v.errorMessage', '');

        var option = component.get('v.radioOption');
        if (option === 'orderAndDel') {
            helper.runOrderAndDeliveryScript(component, event, helper);
        }
    },
});