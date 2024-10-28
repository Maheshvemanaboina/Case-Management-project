({
    // Component initialization
    doInit: function (component, event, helper) {
        helper.getProperRecordIdentifier(component, event, helper);
    },
    doRefresh: function (component, event, helper) {
        helper.doReRender(component, event, helper);
    }

});