({
    handleCloseModal: function(component, event, helper) {
        helper.handleCloseModalHelper(component, event, helper);
    },
    
    handleSave : function(component, event, helper){
        helper.showSpinnerHelper(component);
        let conAccIdObj = component.get('v.conAccIdObj');
        if(conAccIdObj.includes(component.get('v.contactId')+component.get('v.accountId'))){
            helper.hideSpinnerHelper(component);
            helper.showToast(component, event, helper, "Error!", "error", 'The Additional customer location '+component.get('v.custLocLabel')+' has already been added.');
        }else{
            helper.handleSaveHelper(component, event, helper);
        }
    },
    
    hideSpinner : function(component, event, helper){
        helper.hideSpinnerHelper(component);
    },
    
    handleSObjectLookUpSelect : function(component, event, helper){
        helper.handleSObjectLookUpSelect(component, event, helper); 
    }
})