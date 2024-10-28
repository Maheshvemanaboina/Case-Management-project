/*----------------------------------------------------------------------------------
Author:       Lilith Van Biesen
Company:      Waeg
Description:  JS Controller for the BoM View Lightning Component.
----------------------------------------------------------------------------------*/

({
	init: function (cmp, event, helper) {
        var ingredients = $A.get("$Label.c.BoM_Ingredients");
		cmp.set("v.ingredientsLBL", ingredients);
        var totalCost = $A.get("$Label.c.BoM_Total_cost_price_per_mT");
		cmp.set("v.totalCostPricePerMtLBL", totalCost);
         var sgp = $A.get("$Label.c.BoM_SGP");
		cmp.set("v.sgpLBL", sgp);
        document.body.setAttribute('style', 'overflow: visible;');
        helper.prepareTable(cmp, helper);
    },
    handleIdChange: function (cmp, event, helper) {
        cmp.set("v.showTable", false);
        helper.getParent(cmp);
        helper.fetchData(cmp);
        
        
    },
    handleLabelChange: function (cmp, event, helper) {
        helper.prepareTable(cmp, helper);
        
    }
})