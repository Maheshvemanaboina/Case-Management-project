//It will retrive recordid from toast message and redirect user to quote detail page
({
    redirectToNewRecord: function(component, event, helper) {
        var messageData = event.getParam('messageTemplateData');
        if (!$A.util.isEmpty(messageData)) {
            var executionComponent = messageData[1].executionComponent;
            if (!$A.util.isEmpty(executionComponent) && messageData[0] ==='Quote') {
                var recordId = executionComponent.attributes.recordId;
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
        }
    }
})