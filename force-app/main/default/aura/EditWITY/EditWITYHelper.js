({
    setDataOnInit: function(component, event, helper) {
        var action = component.get("c.getEditDataOnInit");
        action.setParams({
            wityId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.metaDataLength",result.length);
                for(var x in result){
                    result[x]['index'] = x;
                    result[x]['readOnly'] = true;
                    result[x]['quesReadOnly'] = true;
                }
                component.set("v.metaDatalist", result);
            }
        });
        $A.enqueueAction(action);
    },
    saveData : function(component, event, helper){
        var action = component.get("c.saveEditRecord");
        console.log(component.get("v.recordId"));
        component.set("v.rId",component.get("v.recordId"));
        action.setParams({
            wityId : component.get("v.recordId"),
            records : JSON.stringify(component.get("v.metaDatalist"))
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var result = response.getReturnValue();
                helper.closeModal(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    checkAllRows : function(component, event, helper){
        var data = component.get("v.metaDatalist");
        const cmps = component.find("checkId");
        
        if(event.getSource().get('v.checked')){
            for(var x in data){
                data[x]['readOnly'] = false;
            }
            if ($A.util.isArray(cmps)) {
            cmps.forEach(cmp => {
                cmp.set("v.checked", true);
            })
            }
        }
        if(!event.getSource().get('v.checked')){
            for(var x in data){
                data[x]['readOnly'] = true;
            }
                if ($A.util.isArray(cmps)) {
            cmps.forEach(cmp => {
                cmp.set("v.checked", false);
            })
            }
        }
        component.set("v.metaDatalist",data);
    },
    deleteRow : function(component, event, helper){
        var lastIndex=event.currentTarget.getAttribute("data-index");
        console.log(lastIndex);
        var data = component.get("v.metaDatalist");
        data.splice(lastIndex,1);
        component.set("v.metaDatalist",data);  
    },
    addRow : function(component, event, helper){
        var temp = component.get("v.metaDatalist");
        var addRow = {};
        addRow['readOnly'] = true;
        addRow['quesReadOnly'] = false;
        addRow['index'] = temp.length;
        addRow['quesName'] = '';
        addRow['ratingone'] = '';
        addRow['ratingtwo'] = '';
        if(temp.length > 0 ){
            temp.push(addRow);
        }
        component.set("v.metaDatalist", temp);
    }
});