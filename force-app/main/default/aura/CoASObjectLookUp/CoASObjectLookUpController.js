({
    onfocus : function(component,event,helper){

        $A.util.addClass(component.find("mySpinner"), "slds-show");
        helper.showSearchResults(component);
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.fetchRecords(component,event,getInputkeyWord);
    },
    
    onblur : function(component, event, helper){       

        component.set("v.sObjectRecords", null );
        helper.hideSearchResults(component);
    },

    keyPressController : function(component, event, helper) {

        var searchKeyWord = component.get("v.SearchKeyWord"); 
        if( searchKeyWord.length > 0 ){
            
            clearTimeout(component.get("v.timer"));
            let timer = window.setTimeout($A.getCallback(function(){
                helper.showSearchResults(component),
                helper.fetchRecords(component, searchKeyWord)
            }), 1000);
            component.set("v.timer", timer);
        }
        else{  
            component.set("v.sObjectRecords", null );
            helper.hideSearchResults(component);
        }
    },

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
})