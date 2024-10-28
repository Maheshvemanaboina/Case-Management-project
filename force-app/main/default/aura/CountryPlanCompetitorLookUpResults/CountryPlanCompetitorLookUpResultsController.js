({
    selectRecord : function(component, event, helper){   
        
        console.log('sObject Name --> '+component.get("v.objectName"));
        if(component.get("v.objectName") == helper.custLocAccountName){
            helper.fireCustLocCompEvent(component, event, helper);
        }else{
            helper.fireSelectedRecordEvent(component, event, helper);
        }
    },
})