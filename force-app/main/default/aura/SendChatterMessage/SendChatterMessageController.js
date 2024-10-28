/**
 * Created by KJM on 27/06/2019.
 */

({
    doInit : function(component, event, helper) {
        helper.checkAvailabilityForUser(component, event, helper);
    },

    handleSendMessageClick : function(component, event, helper) {
        helper.sendMessage(component, event, helper);
    },

    handleCloseModalClick : function(component, event, helper) {
        helper.hideModal(component, event, helper, '', true);
    }
});