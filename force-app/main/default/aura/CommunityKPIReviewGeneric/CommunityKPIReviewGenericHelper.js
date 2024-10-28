({
    confirmedKey : "confirmed",
    IdKey : "Id",
    smCommentKey : "Approval_Rejection_Reason__c",//ENH-4586 - Added to fetch the Approval Rejection Reason value
    
    toggleConfirm : function(component, event, helper, relatedId, confirmedVal, smComment, callFromEditIcon) {
        if(!callFromEditIcon){
            if(confirmedVal){
                component.set("v.confirmedorNot",false);
            }else{
                component.set("v.confirmedorNot",true);
            }
        }
        let kpiObj = {kpiRecordId : relatedId, kpiComments : smComment, kpiConfirmedBySM : component.get("v.confirmedorNot")};
        component.getEvent("commEvent").setParams({"relatedKPI" : kpiObj}).fire();
    }
})