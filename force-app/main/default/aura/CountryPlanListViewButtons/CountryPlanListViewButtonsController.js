({
    doInit : function(component, event, helper){

        var objFieldData = component.get("v.recordFieldObj");
        console.log('record type name --> '+objFieldData.RecordType.Name);
        if(objFieldData !=undefined && (objFieldData.RecordType.Name =='Business Strategy - Account Plan' || objFieldData.RecordType.Name =='Distributor Account Plan')){

            component.set("v.isBusinessStrategyAccountPlanPage",true);
        }
    },
    
    handleNewObjectClick : function(component, event, helper) {

        if(event.getSource().get("v.label") == helper.newButtonLabel){
            helper.redirectToCountryPlanPage(component, event, helper);
            
        }else if(event.getSource().get("v.label") == helper.editButtonLabel){
            helper.navigateToEditAccountPlanComponent(component, event, helper);
            
        }else if(event.getSource().get("v.label") == helper.cloneButtonLabel){
            helper.navigateToCloneAccountPlanComponent(component, event, helper);
            
        }
    },

    handleCloneButtonClick : function(component, event, helper) {

        helper.navigateToCloneAccountPlanComponent(component, event, helper);
    },

})