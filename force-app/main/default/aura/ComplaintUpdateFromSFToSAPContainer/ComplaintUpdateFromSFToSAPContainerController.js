({
    doInit : function(component,event,helper){
      helper.checkTaskType(component,event,helper);
    },
    closemodal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();

    },
    updateFilesCount: function(component,event,helper){
        let eventValue = event.getParam('filesSelected');
        component.set("v.noOfFilesSelected",eventValue);
        if(eventValue == 'None'){
          component.set("v.hideShowAddFileAndFileCount",false);
        }
        else if(eventValue>0){
          component.set("v.enableAddFileButton",false);
        }else{
          component.set("v.enableAddFileButton",true);
        }    
        
    },
    attchFilesToTask : function(component, event, helper) {
        component.find("complaintUpdate").addFilesToTask();
    },
    sendDetailsToSAP : function(component, event, helper){
      component.find("complaintUpdate").syncTaskToSAP();
    }
})