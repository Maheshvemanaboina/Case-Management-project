({
    doInit : function(component, event, helper) {

        helper.getKPIInfoWithUserData(component, event, helper);
    },

    handleCloseModalClick : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    handleSubmit : function(component, event, helper){

        helper.handKPISubmission(component, event, helper);
    }
    
})