({
    getProperRecordIdentifier : function(component, event, helper) {
        let action = component.get("c.getLoggedUserSupplierHubId");
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state=="SUCCESS"){
                let result = response.getReturnValue();
                component.set("v.recordId", result);
                helper.doReRender(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    doReRender: function (component, event, helper) {
        let subjectID = component.get("v.recordId");
        let feedContainer = component.find("feedContainer");
        if(feedContainer) {
            $A.createComponent(
                "forceChatter:feed", {
                    "type": "Record",
                    "feedDesign": "DEFAULT",
                    "subjectId": subjectID
                },
                function (recordFeed) {
                    //Add the new button to the body array
                    if (feedContainer.isValid()) {
                        feedContainer.set("v.body", recordFeed);
                    }
                });
        }
    },
});