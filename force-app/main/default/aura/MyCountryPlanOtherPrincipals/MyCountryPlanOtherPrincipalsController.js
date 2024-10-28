({
    doInit : function(component, event, helper) {
        var principalObj = component.get("v.otherPrincipalsObj");
        principalObj.dirOrIndirVal = 'Yes';
    },
    
	dirOrIndirChange : function(component, event, helper) {
		var dirOrInditValue = component.find('dirOrIndirId').get('v.value');
        var principalObj = component.get("v.otherPrincipalsObj");
        principalObj.dirOrIndirVal = dirOrInditValue;
	},
    
    addNewRow : function(component, event, helper) {
        var competitorObj = component.get("v.otherPrincipalsObj");

        if(competitorObj.recordName.length == 0 || competitorObj.CompetitorId.length == 0){
            helper.fireToastMessage(component, event, helper, 'Error', 'Name & Competitor should be selected before creating adding new comptitor Info', 'error');
        }else{
            component.getEvent("AddRowEvt").fire();
        }
    },
    
    removeRow : function(component, event, helper) {
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex"),
                                                      "CompetitorInfoObj" : component.get("v.otherPrincipalsObj")}).fire();
    }
})