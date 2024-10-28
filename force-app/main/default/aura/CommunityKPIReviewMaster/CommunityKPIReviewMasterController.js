({
    doInit : function(component, event, helper) {
        helper.setTable(component, event, helper);
    },
    pushOrPopOperation : function(component, event, helper) {
       /* var array = [];
        array = component.get("v.arrayValues");
        var IdVal = event.getParam("RelatedEntityId");
 		
        if(array.includes(IdVal)){
            const index = array.indexOf(IdVal);
            if (index > -1) {
                array.splice(index, 1);
            }
        }else{
            array.push(IdVal);
        }
        component.set("v.arrayValues",array); */
        
        let kpiObjFromEvent = event.getParam("relatedKPI");
        let kpiMap = component.get('v.kpiMap');
        let kpiObj = {kpiComments : kpiObjFromEvent.kpiComments, kpiConfirmedBySM : kpiObjFromEvent.kpiConfirmedBySM};
        kpiMap[kpiObjFromEvent.kpiRecordId] = kpiObj;
        component.set('v.kpiMap', kpiMap);
        console.log('kpiMap = ', JSON.stringify(kpiMap));
    },
    SaveRec : function(component, event, helper){
        helper.saveRecord(component, event, helper);
    },
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})