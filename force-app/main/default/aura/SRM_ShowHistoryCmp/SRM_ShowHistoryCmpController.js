({
	doInit : function(component, event, helper) {
		component.set('v.mycolumns', [
            { label: 'Rating', fieldName: 'Rating__c', type: 'text'},
            { label: 'Comment', fieldName: 'Comment__c', type: 'text'},
            {label: 'Rated Date', fieldName: 'Rated_Date__c',type: 'date',
            typeAttributes:{month: "2-digit",day: "2-digit",year: "numeric"}},
            { label: 'Rated By', fieldName: 'ratedByName', type: 'text'},
             { label: 'Year', fieldName: 'Year__c', type: 'text'},
            { label: 'Month', fieldName: 'Month__c', type: 'text'},
            { label: 'Quarter', fieldName: 'Qtr__c', type: 'text'},
            { label: 'Rating Year', fieldName: 'ratingyear', type: 'text'},
             
        ]);
        var ratingIds = component.get('v.ratingIds');
        ratingIds = JSON.stringify(ratingIds);
        helper.callAction(component, helper, "c.getHistoryRecords", { ratingIds: ratingIds}, function(result) {
            console.log('######  result '+ JSON.stringify(result));
			if (result != null) {
            
            result.forEach(function(record){
             
            //old code.
            var list = record.lstContact;
            list.forEach(function(child){
            console.log('###### child'+  JSON.stringify(child));
            console.log('###### '+ child.Rated_By__c);
            if( child.Rated_By__c !== undefined ){
            child.ratedByName = child.Rated_By__r.Name;
            }
            if(child.Supplier_Hub__c !== undefined){
            component.set('v.supplierName', child.Supplier_Hub__r.Supplier_Name__c);
            }
            if(child.Value_Element__c !== undefined ){
            component.set('v.valueElement', child.Value_Element__r.Name);
            }
            if(child.Supplier_Rating__c !== undefined ){
            component.set('v.ratingName', child.Supplier_Rating__r.Name);
            }
            if(child.Supplier_Rating__c !== undefined ){
            child.ratingyear = child.Supplier_Rating__r.Rating_Year__c;
            }
            })
            
            });
                console.log('result form server '+ JSON.stringify(result));
            
                component.set('v.objectList', result);
            }else{
            component.set('v.showError', true);
            	//window.open(component.get('v.vfMsgMethod'),'_top');
            }
        });
	},
            
	handleClick: function(component, event, helper){
        window.open(component.get('v.vfMsgMethod'),'_top');
    }
})