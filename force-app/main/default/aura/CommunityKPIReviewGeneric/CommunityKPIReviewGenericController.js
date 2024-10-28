({
    doInit : function(component, event, helper){
        
        var mapData = component.get("v.rowData");
        var eachRowListVal = component.get("v.eachRowList");
        for(var eachKey in mapData){
            if(eachKey == helper.confirmedKey && mapData[eachKey] == 'true'){
                component.set("v.confirmedorNot",true);
            }else{
                component.set("v.confirmedorNot",false);
            }
            if(eachKey == helper.IdKey){
                component.set("v.rowId",mapData[eachKey]);
            }
            if(eachKey == helper.smCommentKey){
                component.set("v.smComment", mapData[eachKey]);
            }
            eachRowListVal.push({
                key : eachKey,
                value : mapData[eachKey]
            });
            
        }
        component.set("v.eachRowList",eachRowListVal);
    },
    handleConfirmClick : function(component, event, helper) {
        var RelatedId = event.currentTarget.getAttribute("data-val");
        let smComment = !$A.util.isEmpty(component.get('v.smComment')) ? component.get('v.smComment') : '';
        
        helper.toggleConfirm(component, event, helper, RelatedId, component.get("v.confirmedorNot"), smComment, false);
    },
    
    //Makes the Approval/Rejection Reason comments field editable and fires the event on editing the comments
    handleEditComments : function(component, event, helper){
        let source = event.getSource().get('v.name');
        if(source == 'editIcon'){
            component.set('v.showEditIcon', false);
        } 
        else if(source == 'apprRejComments'){
            component.set('v.showEditIcon', true);
            component.set('v.smComment', event.getSource().get('v.value'));
            helper.toggleConfirm(component, event, helper, component.get('v.rowId'), component.get("v.confirmedorNot"), component.get('v.smComment'), true);
        }
    }
})