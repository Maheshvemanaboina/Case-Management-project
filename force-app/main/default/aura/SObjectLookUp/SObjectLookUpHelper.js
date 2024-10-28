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
            objectAPIName       : component.get("v.objectAPIName"),
            fieldAPIName        : component.get("v.fieldAPIName"),
            whereFieldAPIName   : component.get("v.whereFieldAPIName"),
            metaFieldsAPI       : component.get("v.metaFieldsAPI"),
            recordTypeDevNames  : component.get("v.recordTypeDeveloperNames"),
            searchText          : searchKeyWord,
            recordLimit         : component.get("v.recordLimit"),
            contactId			: component.get("v.contactId"),
            contentOwnerFilter	: component.get("v.contentOwnerFilter")//ENH-4370
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            
            //$A.util.removeClass(component.find("mySpinner"), "slds-show");
            $A.util.addClass(component.find("mySpinner"), "slds-hide");
            var state = response.getState();
            if (state === "SUCCESS") {

                var fetchedRecords = response.getReturnValue();
                if (fetchedRecords.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                let objName = component.get("v.objectAPIName");
                let tilesFilter = component.get("v.tilesFilter");
                if(objName === 'Tile__c' && tilesFilter === 'Yes'){
                    var result = fetchedRecords.filter((thing, index, self) =>
                        index === self.findIndex((t) => (
                      		t.UI_Name__c === thing.UI_Name__c
                    ))
                  )
                     component.set("v.sObjectRecords", result);
                }else{
                      component.set("v.sObjectRecords", fetchedRecords);
                }
               
            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },

    fireNotifierEvent : function (component) {
        var chooseEvent = component.getEvent("SObjectNotifierEvent");
        var sourceName = component.get("v.sourceName");
        sourceName = (sourceName) ? sourceName : null;
        chooseEvent.setParams({
            "recordId" : component.get("v.selectedRecordId"),
            "recordLabel":component.get("v.selectedRecordLabel"),
            "sourceName" : sourceName
        });
        chooseEvent.fire();
    },
})