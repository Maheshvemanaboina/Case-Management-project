/**
 * Created by KJM on 08/04/2019.
 */
({
    doInit : function(component, event, helper) {
        helper.setRecordTypes(component, event, helper);
        helper.getSessionInfo(component, event, helper);
    },
    closeModal:function(component,event,helper){
        component.set('v.ismodalClicked', false);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    openmodal: function(component,event,helper) {
        component.set('v.ismodalClicked', true);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    }
})