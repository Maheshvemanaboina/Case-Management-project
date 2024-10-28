({
	showToastMessage : function(mssg, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: "You clicked: " + event.getSource().get("v.label"),
            type : mssg
        });
        toastEvent.fire();
    }
})