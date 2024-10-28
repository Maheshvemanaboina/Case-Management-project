({
    /*onfocus : function(component,event,helper){

        var searchKeyWord = component.get("v.SearchKeyWord");
        if(searchKeyWord){
            $A.util.removeClass(component.find("mySpinner"), "slds-hide");
            helper.showSearchResults(component);
            helper.fetchRecords(component, searchKeyWord);
        }
    },*/
    
    clearInputText : function(component, event, helper){       

        component.set("v.SearchKeyWord",'');
        component.set("v.sObjectRecords", [] );
        helper.hideSearchResults(component);
    },

    keyPressController : function(component, event, helper) {

        var searchKeyWord = component.get("v.SearchKeyWord"); 
        if( searchKeyWord.length > 0 ){
            
            clearTimeout(component.get("v.timer"));
            $A.util.removeClass(component.find("mySpinner"), "slds-hide");
            let timer = window.setTimeout($A.getCallback(function(){
                helper.showSearchResults(component),
                helper.fetchRecords(component, searchKeyWord)
            }), 1000);
            component.set("v.timer", timer);
        }
        else{  
            clearTimeout(component.get("v.timer"));
            helper.hideSearchResults(component);
            component.set("v.sObjectRecords", [] );
        }
    },
    //B2B-326 START
    handleSelection: function(component, event, helper) {
        var selectedRecordName = event.getParam("selectedRecordName");
        console.log("Selected Record Name: " + selectedRecordName);
        // Additional logic to handle the selected record
    },
     handleRecordSelection: function(component, event, helper) {
        var selectedRecordId = component.get("v.selectedRecordId"); // Assuming you have an attribute for recordId
        var selectedSourceName = component.get("v.sourceName"); // Assuming you have an attribute for sourceName
        var selectedRecordLabel = component.get("v.recordLabel"); // Assuming you have an attribute for recordLabel

        var selectEvent = component.getEvent("onselect");
        selectEvent.setParams({
            "recordId": selectedRecordId,
            "sourceName": selectedSourceName,
            "recordLabel": selectedRecordLabel
        });
        selectEvent.fire();
    },
    //B2B-326 END

    clear :function(component,event,helper){
        
        helper.hideSelectedRecordPill(component);
        helper.showLookupInput(component);
    
        component.set("v.SearchKeyWord",null);
        component.set("v.sObjectRecords", null );
        component.set("v.selectedRecordLabel",'');
        component.set("v.selectedRecordId",'');  
        
        helper.fireNotifierEvent(component);
    },

    handleLookupSelectEvent : function(component, event, helper) {

        var selectedRecordId = event.getParam("recordId");
        var selectedrecordLabel = event.getParam("recordLabel");

        component.set("v.selectedRecordId", selectedRecordId);
        component.set("v.selectedRecordLabel", selectedrecordLabel);

        helper.showSelectedRecordPill(component);
        helper.hideSearchResults(component);
        helper.hideLookupInput(component);
        
        helper.fireNotifierEvent(component);
    },

    setLookUpValue : function(component, event, helper){

        var params = event.getParam('arguments');
        if (params) {
            //var contentTree = params.contentTree;
            //component.set("v.contentTreeVM",params.selectedRecordId);
            //component.set("v.validContentMap", params.selectedRecordLabel);
            console.log('selected record Id '+params.selectedRecordId);
            console.log('selected record Label '+params.selectedRecordLabel);

            component.set("v.selectedRecordId", params.selectedRecordId);
            component.set("v.selectedRecordLabel", params.selectedRecordLabel);

            helper.showSelectedRecordPill(component);
            helper.hideSearchResults(component);
            helper.hideLookupInput(component);
        }
    },

})