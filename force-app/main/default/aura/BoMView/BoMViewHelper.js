/*----------------------------------------------------------------------------------
Author:       Lilith Van Biesen
Company:      Waeg
Description:  JS Helper for the BoM View Lightning Component.
----------------------------------------------------------------------------------*/
({
    prepareTable: function (cmp, helper){
        console.log('On load method call');
    	var currency = cmp.get("v.parentQuoteLine.SBQQ__Quote__r.CurrencyIsoCode");
        
        var ingredientsLBL = cmp.get("v.ingredientsLBL");
        var mpLastTimeQuotedLBL = cmp.get("v.mpLastTimeQuotedLBL");
        var newMPLBL = cmp.get("v.newMPLBL");
        var costPriceMPLBL = cmp.get("v.costPriceMPLBL");
        var mpCostPriceLastTimeQuotedLBL = cmp.get("v.mpCostPriceLastTimeQuotedLBL");
        var ppCurrentQuoteLBL = cmp.get("v.ppCurrentQuoteLBL");
        var costPricePPLBL = cmp.get("v.costPricePPLBL");
        var deltaIngredientPriceLBL = cmp.get("v.deltaIngredientPriceLBL");
        var deltaWeightedIngrPriceLBL = cmp.get("v.deltaWeightedIngrPriceLBL");
        var isContractRateAppliedLBL = cmp.get("v.isContractRateAppliedLBL");
	    var maxdigits = 5;
        var minFractionDigits = 2;
        var maxFractionDigits = 2;
	
        cmp.set('v.columns', [
            {label: isContractRateAppliedLBL, fieldName: 'isContractRateApplied__c', type: 'Boolean',cellAttributes: { iconName: {fieldName: 'displayIconName'},alignment: 'center'}},
            {label: ingredientsLBL, fieldName: 'SBQQ__ProductName__c', type: 'text'},
            {label: mpLastTimeQuotedLBL, fieldName: 'MP_Last_Time_Quoted__c', type: 'currency', typeAttributes: { currencyCode: currency, maximumFractionDigits: maxFractionDigits, minimumFractionDigits: minFractionDigits}}, //maximumSignificantDigits: maxdigits, 
            {label: newMPLBL, fieldName: 'New_MP__c', type: 'currency', typeAttributes: { currencyCode: currency, maximumFractionDigits: maxFractionDigits, minimumFractionDigits: minFractionDigits}}, //maximumSignificantDigits: maxdigits, 
            {label: deltaIngredientPriceLBL, fieldName: 'Delta_Ingredient_Price__c', type: 'text'},
            {label: costPriceMPLBL, fieldName: 'Cost_Price_MP__c', type: 'currency', typeAttributes: { currencyCode: currency, maximumFractionDigits: maxFractionDigits, minimumFractionDigits: minFractionDigits}}, //maximumSignificantDigits: maxdigits, 
            {label: mpCostPriceLastTimeQuotedLBL, fieldName: 'MP_Cost_Price_Last_Time_Quoted__c', type: 'currency', typeAttributes: { currencyCode: currency, maximumFractionDigits: maxFractionDigits, minimumFractionDigits: minFractionDigits}}, //maximumSignificantDigits: maxdigits, 
            {label: ppCurrentQuoteLBL, fieldName: 'PP_Current_Quote__c', type: 'currency', typeAttributes: { currencyCode: currency, maximumFractionDigits: maxFractionDigits, minimumFractionDigits: minFractionDigits}}, //maximumSignificantDigits: maxdigits, 
            {label: deltaWeightedIngrPriceLBL, fieldName: 'Delta_Weighted_Ingr_Price__c', type: 'text'},
            {label: costPricePPLBL, fieldName: 'Cost_Price_PP__c', type: 'currency', typeAttributes: { currencyCode: currency, maximumFractionDigits: maxFractionDigits, minimumFractionDigits: minFractionDigits}}, //maximumSignificantDigits: maxdigits
        ]);
	},
    getParent: function(cmp){
      
        var action = cmp.get("c.getParentQuoteLine");
        action.setParams({
            quotelineId : cmp.get("v.quotelineId")
        });
      
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.parentQuoteLine", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
	 $A.enqueueAction(action);
    },
    fetchData: function (cmp) {
        var action = cmp.get("c.getChildQuoteLines");
        action.setParams({
            quotelineId : cmp.get("v.quotelineId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
        	if(state === "SUCCESS"){
                var rows = response.getReturnValue();
                var num;
                rows.forEach(function(row){
                    if(row != null && row != 'undefined'){
                        if(row.Delta_Ingredient_Price__c != null && row.Delta_Ingredient_Price__c != 'undefined'){
                            //row.Delta_Ingredient_Price__c = row.Delta_Ingredient_Price__c / 100;
                            num = parseFloat(row.Delta_Ingredient_Price__c).toFixed( 2 );
                            //console.log(typeof row.Delta_Ingredient_Price__c);
                            row.Delta_Ingredient_Price__c = num + "%";
                            //console.log('delta =' + row.Delta_Ingredient_Price__c);
                            //console.log(typeof row.Delta_Ingredient_Price__c);
                            //console.log('num =' + num);
                        }
                        if(row.Delta_Weighted_Ingr_Price__c != null && row.Delta_Weighted_Ingr_Price__c != 'undefined'){
                            //row.Delta_Weighted_Ingr_Price__c = row.Delta_Weighted_Ingr_Price__c / 100;
                            num = parseFloat(row.Delta_Weighted_Ingr_Price__c).toFixed( 2 );
                            row.Delta_Weighted_Ingr_Price__c = num + "%";
                        }
                        if(row.isContractRateApplied__c){
                        row.displayIconName='utility:contract_doc';
                        row.isContractRateApplied__c ='';
                        
                    }   else{
                        row.displayIconName='';
                        row.isContractRateApplied__c ='';
                    }
                    }
                });
                cmp.set('v.data', rows);
                //console.log("rows",rows);
                cmp.set("v.showTable", true);
        	} else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
    	$A.enqueueAction(action);
    }
})