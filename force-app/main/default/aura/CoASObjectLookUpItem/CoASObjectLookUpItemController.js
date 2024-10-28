({
    getLabelMetaValues : function (component, event, helper) {

        //Set field Value
        helper.setLabel(component);

        //Set Meta Values
        helper.setMetaValues(component);
        
    },
     
    handleRecordSelect : function (component) {
        var chooseEvent = component.getEvent("CoASObjectLookupEvent");
        chooseEvent.setParams({
            "recordLabel":component.get("v.recordLabel"),
            "TypeOfNumber":component.get("v.typeOfNumberEntered")
        });
        chooseEvent.fire();
    },
})