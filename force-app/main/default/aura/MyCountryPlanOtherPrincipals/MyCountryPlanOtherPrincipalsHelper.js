({
	fireToastMessage : function(component, event, helper, toastTitle, ToastMessage, ToastType){

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : toastTitle,
            message: ToastMessage,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: ToastType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})