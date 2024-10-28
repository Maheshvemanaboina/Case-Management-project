({
    getLabelMetaValues : function (component, event, helper) {

        //Set field Value
        helper.setLabel(component);

        //Set Meta Values
        helper.setMetaValues(component);
        
    },
     
    handleRecordSelect : function (component) {
        var chooseEvent = component.getEvent("SObjectLookupEvent");
        chooseEvent.setParams({
            "recordId" : component.get("v.record").Id,
            "recordLabel":component.get("v.recordLabel")
        });
        chooseEvent.fire();
    },
})