({
    myAction : function(component, event, helper) {

    },
    navigateToPage1 : function(component,event,helper){
        event.preventDefault();//enables you to bypass the standard link and use your custom link.
        
    },
    init : function (component,event,helper){
      // window.setTimeout(function(){init(component,event,helper)},1500);
    // debugger;
        var urlVal = window.location.href;
        var breadCrumbs={};
        console.log('urlVal::'+urlVal);
        var ind = urlVal.indexOf('s/');
        console.log('index:: '+ind);
        var lastInd = urlVal.lastIndexOf('/');
        var subsData = urlVal.substring(urlVal.indexOf('s/')+2);
        console.log('subsData:: '+subsData);
        if(subsData !=undefined && subsData.includes('my-performance')){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'}];
            component.set("v.mybCrumbs",breadCrumbs);
        }
        else if(subsData !=undefined && subsData.includes('business-strategy')){
                var recData = subsData.substring(subsData.lastIndexOf('/')+1);
                if(recData !=undefined && !recData.includes('bs-') && !recData.includes('ap') && recData.includes('Default')){
                breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'}];
                component.set("v.mybCrumbs",breadCrumbs);
            }
        }
        else if(subsData !=undefined && subsData.includes('commercial-activity')){
         var recData =subsData.substring(subsData.lastIndexOf('/')+1);
         if(recData !=undefined && !recData.includes('ca') && recData.includes('Default')){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities',name:'Commercial Activities'}];
            component.set("v.mybCrumbs" , breadCrumbs);  
        }
    }
    else if(subsData != undefined && subsData.includes('sales-funnel')){
        var recData = subsData.substring(subsData.lastIndexOf('/')+1);
        if(recData !=undefined && !recData.includes('s-') && recData.includes('Default')){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Sales Funnel',name:'My Sales Funnel'}];
            component.set("v.mybCrumbs",breadCrumbs);
        }
    }
    else if(subsData !=undefined && subsData.includes('forecast-accuracy')){
        var recData = subsData.substring(subsData.lastIndexOf('/')+1);
        if(recData !=undefined && recData.includes('Default')){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Forecast Accuracy',name:'My Forecasts'}];
            component.set("v.mybCrumbs",breadCrumbs);
        }
    }
    else if(subsData !=undefined && subsData.includes('fci-customer-support')){
        var recData = subsData.substring(subsData.lastIndexOf('/')+1);
        if(recData !=undefined && recData.includes('Default') && !recData.includes('support-no-')){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support',name:'FCI Customer Support'}];
            component.set("v.mybCrumbs",breadCrumbs);
        }
    }
    
   
       
        
    },
    navigateTo: function (cmp, event, helper) {
        //get the name of the breadcrumb that's clicked
        var name = event.getSource().get('v.name');
		console.log(event.getSource().get("v.value"));
        console.log(name);
        //your custom navigation here
        var urlVal = window.location.href;
        var baseUrl = window.location.href.substring(0,urlVal.indexOf('/s'));
        console.log("baseUrl"+baseUrl)
        console.log('urlVal in navigate:: '+urlVal);
        if (name =='My Performance'){
            //alert('alert'+urlVal );
            
            var reDirectUrl = baseUrl + '/s/' + 'my-performance';
            //alert(reDirectUrl);
            cmp.set("v.performPath",reDirectUrl);
           // cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/my-performance");
        }
        else if(name =='Home'){
            var hmUrl = baseUrl + '/s/';
            cmp.set("v.performPath",hmUrl);
            
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/");
        }
        else if(name =='My Business Strategy'){
            
				var reDirectUrl = urlVal //+'/s/'+ 'business-strategy/Business_Strategy__c/Default';
            //alert(reDirectUrl);
            cmp.set("v.performPath",reDirectUrl);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/business-strategy/Business_Strategy__c/Default");
        }
        else if(name =='My Sales Funnel'){
            cmp.set("v.performPath",urlVal);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/sales-funnel/Sales_Funnel__c/Default");
        }
        else if(name =='Commercial Activities'){
            cmp.set("v.performPath",urlVal);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/commercial-activity/Commercial_Activity__c/Default");
        }
        else if(name =='My Forecasts'){
            cmp.set("v.performPath",urlVal);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/forecast-accuracy/Forecast_Accuracy__c/Default");
        }
        else if(name=='FCI Customer Support'){
            cmp.set("v.performPath",urlVal);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/fci-customer-support/FCI_Customer_Support__c/Default");
        }
    
    },
    fetchUrlChange : function(cmp,event,helper){
        var urlVal = window.location.href;
        console.log('urlVal::+urlVal');
        var token = event.getParam("token");
        console.log('token::'+token);
        var querystring = event.getParam("querystring");
        console.log('queryString:: '+querystring);

    }
})