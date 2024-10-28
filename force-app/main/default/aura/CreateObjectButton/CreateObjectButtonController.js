/**
 * Created by KJM on 08/04/2019.
 */
({
    handleNewObjectClick : function(component, event, helper){
        helper.displayError(component, false, "");
        helper.showModal(component, event, helper);
    },

    handleCloseModalClick : function(component, event, helper) {
        helper.displayError(component, false, "");
        helper.hideModal(component, event, helper);
    },

    handleNextButtonClick : function(component, event, helper) {
        helper.displayError(component, false, "");
        helper.openNewObjectCreation(component, event, helper);
    },
})