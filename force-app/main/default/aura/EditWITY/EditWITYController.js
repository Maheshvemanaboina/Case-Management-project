({
    doInit: function(component, event, helper) {
        helper.setDataOnInit(component, event, helper);
    },
    
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
    handleTopCheck : function(component, event, helper){
        helper.checkAllRows(component, event, helper);
    },
    handleSubmit : function(component, event, helper){
        helper.saveData(component, event, helper);
    },
    handleAddRow : function(component, event, helper){
        helper.addRow(component, event, helper);
    },
    
    handleDeleteRow : function(component, event, helper){
        helper.deleteRow(component, event, helper);
    }
});