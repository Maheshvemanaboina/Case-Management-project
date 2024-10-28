({
    searchHelper : function(component,event,getInputkeyWord,objName) {
        var action = component.get("c.getCompetitorAccountsByName");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'sObjectName' : objName
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var competitorRecords = response.getReturnValue();
                if (competitorRecords.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", competitorRecords);
            }
        });
        $A.enqueueAction(action);
    },
    
    fireToastMessageforCompetitor : function(component, event, helper, toastTitle, ToastMessage, ToastType){

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : toastTitle,
            message: ToastMessage,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: ToastType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})