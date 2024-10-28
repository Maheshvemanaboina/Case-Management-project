({
    doInit : function(component, event, helper) {
        helper.AmendmentofOtherConditions(component, event, helper);
        //showToastMessage(component, event, helper);
    },
    handleLoad : function(component, event, helper) {
        var recUi = event.getParam("recordUi");
        console.log('On Load Executed');
        var totsales,intialLSD,termper,tempdev;
        if(recUi.record.fields["Deviations_from_RFC_LSD_Template__c"] != undefined && recUi.record.fields["Deviations_from_RFC_LSD_Template__c"] != null){
            component.set('v.templateDeviation', recUi.record.fields["Deviations_from_RFC_LSD_Template__c"].value);
        }
        if(recUi.record.fields["Deviations_from_RFC_LSD_Template__c"] != undefined && recUi.record.fields["Deviations_from_RFC_LSD_Template__c"] != null){
            component.set('v.DeviationRFC', recUi.record.fields["Deviations_from_RFC_LSD_Template__c"].value);
            tempdev = component.get('v.DeviationRFC');
        }
        if(recUi.record.fields["Status_of_LSD__c"] != undefined && recUi.record.fields["Status_of_LSD__c"] != null){
            component.set('v.StatusValue', recUi.record.fields["Status_of_LSD__c"].value);
        }
        //  component.set('v.extensionType', recUi.record.fields["Extension_Type__c"].value);
        //component.set('v.SCAFCount', recUi.record.fields["SCAF_Count__c"].value);
        if(recUi.record.fields["Total_Net_Sales_Value__c"] != undefined && recUi.record.fields["Total_Net_Sales_Value__c"] != null){
            component.set('v.TotalNetSales', recUi.record.fields["Total_Net_Sales_Value__c"].value);
            totsales = component.get('v.TotalNetSales');
        }
        if(recUi.record.fields["Initial_Term_of_LSD_In_Months__c"] != undefined && recUi.record.fields["Initial_Term_of_LSD_In_Months__c"] != null){
            component.set('v.InitialTermsLSD', recUi.record.fields["Initial_Term_of_LSD_In_Months__c"].value);
            intialLSD = component.get('v.InitialTermsLSD');
        }
        if(recUi.record.fields["Termination_Notice_Period_In_Months__c"] != undefined && recUi.record.fields["Termination_Notice_Period_In_Months__c"] != null){
            component.set('v.TerminationPeriod', recUi.record.fields["Termination_Notice_Period_In_Months__c"].value);
            termper = component.get('v.TerminationPeriod');
        }
    }
})