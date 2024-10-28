({
    doInit: function(component, event, helper) {
        helper.setDataOnInit(component, event, helper);
        helper.fetchRecordTypeName(component);//B2B144
    },
    //B2B144
    handleSearch : function(component, event, helper) {
        var searchTerm = component.get("v.searchTerm");
        if (searchTerm.length > 0) {
            helper.searchAccountPlans(component, searchTerm);
        } else {
            component.set("v.searchResults", []);
        }
    },
    selectAccountPlan: function(component, event, helper) {
        var accountId = event.currentTarget.dataset.id;
        var accountName = event.currentTarget.dataset.name;
        component.set("v.selectedAccountPlan", accountName);
        component.set("v.selectedAccountPlanId", accountId);
        component.set("v.searchTerm", accountName);
        component.set("v.searchResults", []);
    },
    //B2B144
    
    handleClose : function(component, event, helper) {
        helper.closeModal(component, event, helper);
    },
    handleClick : function(component,event,helper){
        var result = component.get('v.metaDatalist');
        var index = event.getSource().get('v.name');
        if(event.getSource().get('v.checked')){
            result[index].readOnly = false;
            result[index].checkbox = true;
            component.set('v.metaDatalist',result);
        }
        else{
            result[index].readOnly = true;
            result[index].checkbox = false;
            result[index].ratingone = '';
            result[index].ratingtwo = '';
            component.set('v.metaDatalist',result);
        }
    },
    changeState: function changeState (component){ 
        component.set('v.isexpanded',!component.get('v.isexpanded'));
    },
    handleTopCheck : function(component, event, helper){
        helper.checkAllRows(component, event, helper);
    },
    handleSubmit : function(component, event, helper){
            helper.upsertData(component, event, helper);
    },
    handleAddRow : function(component, event, helper){
        helper.addRow(component, event, helper);
    },
    
    handleDeleteRow : function(component, event, helper){
        helper.deleteRow(component, event, helper);
    }
});