({
    doinit : function(component, event, helper) {
        component.set('v.columns', [
            //{ label: 'WITY Name', fieldName: 'wityName', type: 'text', iconName: 'standard:opportunity' },
            { label: 'Key Areas', fieldName: 'Question_Name__c', type: 'text', cellAttributes: { alignment: 'center' } },
            { label: 'Important to Customer', fieldName: 'Rating_One__c', type: 'number' },
            { label: 'FCI Current Performance', fieldName: 'Rating_Two__c', type: 'number' },
            { label: 'Comments', fieldName: 'Comments__c', type: 'text', cellAttributes: { alignment: 'center' } }
        ]);
        helper.fetchData(component, event, helper);
        helper.setURL(component, event, helper)
    }
})