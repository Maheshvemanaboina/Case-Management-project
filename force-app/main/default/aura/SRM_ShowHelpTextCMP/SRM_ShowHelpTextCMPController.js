({
    doAction : function(component, event, helper) {
       var vfRetURLInSFX = '{!JSENCODE($CurrentPage.parameters.vfRetURLInSFX)}';
    },
    handleClick: function(component, event, helper){
        window.open(component.get('v.vfMsgMethod'),'_top')
    }
})