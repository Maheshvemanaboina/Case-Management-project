({
    doInit : function(component, event, helper) {
        component.set("v.fileName",'No File Selected..');
        component.set("v.SFUrl",window.location.hostname);
    },
    
    handleFilesUploadChange : function(component,event,helper){
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.fileName",fileName);
            
        }
        else{
            component.set("v.fileName",'No File Selected..');
        }
    },
    
    
    handleSubmit : function(component,event,helper){
        helper.UploadAndSave(component,event,helper,'save');
        
    },
    
    handleSaveNew : function(component,event,helper){
        helper.UploadAndSave(component,event,helper,'SaveAndClone');
    },
    
    handleClose : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },

    handleChildClearEvent : function(component, event, helper){
        // get the selected Account record from the COMPONETN event 	 
        var lookupVal = event.getParam("removedRecord");
        console.log('lookupVal --> '+lookupVal);
        helper.handleNullifyingChilds(component,event,helper,lookupVal);
    }
    
    
})