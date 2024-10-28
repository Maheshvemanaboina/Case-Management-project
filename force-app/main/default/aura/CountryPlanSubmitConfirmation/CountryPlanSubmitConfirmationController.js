({      
    handleOpenModal : function(component, event, helper){

        helper.OpenModal(component, event, helper);
        helper.setBusinessStrategyInfo(component, event, helper, component.get("v.BusinessStrategyId"));

    },
   	
    handleCloseModalClick : function(component, event, helper){
        
        helper.closeModal(component, event, helper);
    },

    handleSubmit : function(component, event, helper){
        
        helper.submitBusinessStrategy(component, event, helper, component.get("v.BusinessStrategyId"));
    },
})