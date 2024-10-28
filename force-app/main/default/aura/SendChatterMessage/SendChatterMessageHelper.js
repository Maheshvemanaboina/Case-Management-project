/**
 * Created by KJM on 27/06/2019.
 */

({
    checkAvailabilityForUser : function(component, event, helper) {
        var action = component.get("c.isChatterAvailableForUser");
        action.setParams({
            personName : component.get('v.personName')
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var result = response.getReturnValue();
                if (result == false) {
                    component.set('v.userChatterAvailable', false);
                    helper.displayErrorMessage(component, event, helper, 'Direct message to this user is unavailable, please send message to the another person');
                }
            } else {
                helper.displayErrorMessage(component, event, helper, null);
            }
        });
        $A.enqueueAction(action);
    },

    sendMessage : function(component, event, helper) {
        var action = component.get("c.sendDirectChatterMessage");
        action.setParams({
            personName : component.get('v.personName'),
            subject : component.find("subjectTA").get("v.value"),
            message : component.find("messageTA").get("v.value")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                helper.hideModal(component, event, helper, "Message Sent Successfully!", false);
            } else {
                helper.displayErrorMessage(component, event, helper, null);
            }
        });

        $A.enqueueAction(action);
    },

    displayErrorMessage : function(component, event, helper, message) {
        var errorMessage = 'An error has occurred, please try again or contact System Administrator';
        if (message != null) {
            errorMessage = message;
        }

        component.set('v.errorMessage', errorMessage);
    },

    hideModal : function(component, event, helper, message, manually) {
        var compEvt = component.getEvent("hideCompEvt");
        compEvt.setParams({
            "onHideMessage" : message,
            "manually" : manually
        });
        compEvt.fire();
    },
});