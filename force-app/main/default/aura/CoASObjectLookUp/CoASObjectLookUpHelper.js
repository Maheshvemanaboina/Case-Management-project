({
    showSelectedRecordPill : function(component) {

        $A.util.addClass(component.find("selectedRecord-pill"), 'slds-show');
        $A.util.removeClass(component.find("selectedRecord-pill"), 'slds-hide');
    },

    hideSelectedRecordPill : function(component) {

        $A.util.addClass(component.find("selectedRecord-pill"), 'slds-hide');
        $A.util.removeClass(component.find("selectedRecord-pill"), 'slds-show');
    },

    hideSearchResults : function(component) {

        $A.util.addClass(component.find("searchResults"), 'slds-is-close');
        $A.util.removeClass(component.find("searchResults"), 'slds-is-open');
    },

    showSearchResults : function(component) {

        $A.util.addClass(component.find("searchResults"), 'slds-is-open');
        $A.util.removeClass(component.find("searchResults"), 'slds-is-close');
    },

    hideLookupInput : function(component) {

        $A.util.addClass(component.find("lookUp-input"), 'slds-hide');
        $A.util.removeClass(component.find("lookUp-input"), 'slds-show');  
    },

    showLookupInput : function(component) {

        $A.util.addClass(component.find("lookUp-input"), 'slds-show');
        $A.util.removeClass(component.find("lookUp-input"), 'slds-hide');  
    },

    fetchRecords : function(component, searchKeyWord) {

        var action = component.get("c.getRecords");
        // set param to method  
        action.setParams({
            objectAPIName           : component.get("v.objectAPIName"),
            fieldAPIName            : component.get("v.fieldAPIName"),
            whereFieldAPIName       : component.get("v.whereFieldAPIName"),
            metaFieldsAPI           : component.get("v.metaFieldsAPI"),
            searchText              : searchKeyWord,
            recordLimit             : component.get("v.recordLimit"),
            isEnteredNumberIsUnique : component.get("v.isUnique"),
            typeOfNumber            : component.get("v.typeOfNumberEntered")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {

                var fetchedRecords = response.getReturnValue();
                if (fetchedRecords.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.sObjectRecords", fetchedRecords);
            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },

    fireNotifierEvent : function (component) {
        var chooseEvent = component.getEvent("CoASObjectNotifierEvent");
        chooseEvent.setParams({
            "recordLabel":component.get("v.selectedRecordLabel"),
            "TypeOfNumber":component.get("v.typeOfNumberEntered")
        });
        chooseEvent.fire();
    },
})