/**
 * Created by KJM on 03/07/2019.
 */

({
    handleOpenSendMessageClick : function(component, event, helper) {
        helper.showMessageComponent(component, event, helper);
    },
    
    handleHideSendMessageModal : function(component, event) {
        component.set("v.renderSendMessageComponent", false);
        
        if (event.getParam("manually") == true) {
            return;
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : 'success',
            "title": "Success!",
            "message": event.getParam("onHideMessage")
        });
        toastEvent.fire();
        
    },
    
    getclickeddata : function(component, event, helper){
        
        var selectedItem = event.currentTarget;
        var fieldPosition = selectedItem.dataset.id;
        var Elements = component.find('teamId');
        
        for (var i = 0; i < Elements.length; i++) {
            var val = Elements[i].getElement().getAttribute('data-id'); 
            if(fieldPosition == val){
                var dataval = Elements[i].getElement().getAttribute('data-val');
                var x = Elements[i].getElement().querySelectorAll(".slds-show");
                var y = Elements[i].getElement().querySelectorAll(".slds-hide");
                $A.util.removeClass(x[0], 'slds-show');
                $A.util.addClass(x[0], 'slds-hide');
                $A.util.removeClass(y[0], 'slds-hide');
                $A.util.addClass(y[0], 'slds-show');        
                var sortdirection = x[0].getAttribute("data-sort-dir");
                helper.sortData(component,fieldPosition,sortdirection);
            }  
        }
        
    }
});