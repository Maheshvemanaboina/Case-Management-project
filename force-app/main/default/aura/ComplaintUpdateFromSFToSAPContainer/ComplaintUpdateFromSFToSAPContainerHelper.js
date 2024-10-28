({
    checkTaskType : function(component,event,helper) {

        let action = component.get("c.getTaskType");
        action.setParams({"taskRecordId":(component.get("v.recordId"))});
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state==='SUCCESS'){
                let result = response.getReturnValue();
                console.log('taskType-->'+result);
                if(result != null && result != undefined){
                    component.set("v.taskType",result);
                }
                if(result == 'Request Sample from Customer'){
                    component.set("v.hideShow",true);    
                    helper.synchTaskToSAP(component,event,helper);                
                }else{
                    component.set("v.hideShow",false);    
                }
               
            }
            else{
                console.log('State-->'+state);
                console.log('error-->'+response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    synchTaskToSAP :function(component,event,helper){
        let action = component.get("c.synchTaskDetailsToSAP");
        action.setParams({
            "taskRecordId":component.get("v.recordId"),
            "taskDescription":null,
            "taskType":component.get("v.taskType"),
            "reportAcceptedOrRejected":null
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state==='SUCCESS'){
                let result = response.getReturnValue();
                $A.get("e.force:closeQuickAction").fire();
                component.find('notify').showToast({
                    "variant": "success",
                    "title": "Success",
                    "message": result
                });
            }
            else{
                $A.get("e.force:closeQuickAction").fire();
                component.find('notify').showToast({
                    "variant": "success",
                    "title": "Error",
                    "message": "Error Occured"
                });
                console.log('State-->'+state);
                console.log('error-->'+response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})