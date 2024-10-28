({
    myAction : function(component, event, helper) {


    },
    
    doInit : function(component, event, helper){
       debugger;
        console.log("Inside DoInit")
        var objFieldData = component.get("v.recordFieldObj");
        //console.log("objFieldData.RecordType.Name="+objFieldData.RecordTypeId);
        var breadCrumbs={};
        var counter =0;
        var recId =component.get("v.recordId");
        console.log("++++++#####Records"+JSON.stringify(component.get("v.recordFieldObj")));
       // console.log("CaseNumber"+objFieldData.CaseNumber)
       console.log("objFieldData.RecordType.Name="+objFieldData.RecordType.Name);
      //  console.log("afterrec");
       /// console.log(component.get("v.recordId"));
     // var setLoc = objFieldData.Distributor_Location__c;
     var setLoc = objFieldData.Distributor_Location__c;
        console.log("setLoc"+setLoc)
        if(setLoc != undefined)
        {
            component.set("v.location",setLoc);
		}
      
        
        console.log("location"+component.get("v.location"));
       
        console.log("objFieldData.RecordType"+objFieldData.RecordTypeId);
        console.log("recId"+recId);
        
        if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Commercial Activity - High & Low Lights' ){
            //console.log('objFieldData Name:: '+objFieldData.Name);
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
            
        }
        else if(objFieldData != undefined  && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='High & Low Lights'){
            
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'}, {label:objFieldData.Business_Strategy_High_Low_Lights__r.Name , name :objFieldData.Business_Strategy_High_Low_Lights__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            //breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Commercial_Activity_High_Low_Lights__r.Name ,name:objFieldData.Commercial_Activity_High_Low_Lights__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Commercial Activity - Customer Visits'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if (objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Competition') {
           	console.log("Inside Competition")
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'}, {label:objFieldData.Business_Strategy_Competition__r.Name , name :objFieldData.Business_Strategy_Competition__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            //breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'}, {label:objFieldData.Commercial_Activity_Competition__r.Name , name :objFieldData.Commercial_Activity_Competition__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Commercial Activity - Competition'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Commercial Activity - Promotion Activities'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Commercial Activity - Samples'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Promotion Activity'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Commercial_Activity_Promotion_Activity__r.Name , name :objFieldData.Commercial_Activity_Promotion_Activity__r.Name} ,{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Customer Visit'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'},{label:objFieldData.Commercial_Activity_Customer_Visit__r.Name , name :objFieldData.Commercial_Activity_Customer_Visit__r.Name} ,{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Samples'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Commercial Activities' ,name:'Commercial Activities'}, {label:objFieldData.Commercial_Activity_Sample__r.Name , name :objFieldData.Commercial_Activity_Sample__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Business Strategy Master'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined &&  objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Business Strategy - Account Plan'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Distributor Country Plan'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:objFieldData.Distributor_Business_Strategy__r.Name , name:objFieldData.Distributor_Business_Strategy__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Distributor Account Plan'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:objFieldData.Distributor_Business_Strategy__r.Name , name:objFieldData.Distributor_Business_Strategy__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs); 
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Sales Funnel - Distributor Sales To End Customer'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Sales Funnel' ,name:'Sales Funnel'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Distributor Sales To End Customer'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Sales Funnel' ,name:'Sales Funnel'},{label:objFieldData.Sales_Funnel_Sales_To_End_Customer__r.Name ,name:objFieldData.Sales_Funnel_Sales_To_End_Customer__r.Name}, {label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Sales Funnel Master'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Sales Funnel' ,name:'Sales Funnel'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Forecast Master'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Forecast Accuracy' ,name:'My Forecasts'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Forecast Accuracy - Local Stock'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Forecast Accuracy' ,name:'My Forecasts'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        } 
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Local Stock'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Forecast Accuracy' ,name:'My Forecasts'},{label:objFieldData.Forecast_Accuracy_Local_Stock__r.Name ,name:objFieldData.Forecast_Accuracy_Local_Stock__r.Name},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='FCI Customer Support Master'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='FCI Customer Support - Complaints'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='FCI Customer Support - Order Process'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Order Process'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.FCI_Customer_Support_Order_Process__r.Name , name:objFieldData.FCI_Customer_Support_Order_Process__r.Name},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
       
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Pricing' ){
            
           console.log('Pricing Name:: '+objFieldData.CaseNumber);
            console.log('Pricing Name:: '+objFieldData.FCI_Customer_Support__r.Name);
            console.log('Pricing Name:: '+objFieldData.CaseNumber);
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.FCI_Customer_Support__r.Name, name:objFieldData.FCI_Customer_Support__r.Name},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
           
        
        /*else if(objFieldData !=undefined && objFieldData.RecordType.Name =='Pricing'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);//change this.
        }*/
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='Helpdesk Case'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'}, {label:objFieldData.FCI_Customer_Support__r.Name, name:objFieldData.FCI_Customer_Support__r.Name},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name =='FCI TSS Case'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.FCI_Customer_Support__r.Name, name:objFieldData.FCI_Customer_Support__r.Name},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name == 'Distributor End Customer Case'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.End_Customer_Cases__r.Name ,name:objFieldData.End_Customer_Cases__r.Name},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);            
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name == 'FCP TSS Case'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);
                    }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name == 'Complaint Case'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name == 'QA_SALES'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name == 'Support Request'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined &&  objFieldData.RecordType.Name == 'Business Strategy - Competition'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
        else if(objFieldData !=undefined && objFieldData.RecordType!=undefined && objFieldData.RecordType.Name == 'Business Strategy - High & Low Lights'){
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:objFieldData.Name , name:objFieldData.Name}];
            component.set("v.mybCrumbs",breadCrumbs);
           
        }
         else if(objFieldData !=undefined && recId.startsWith("500")){ //objFieldData.RecordTypeId=='01225000000GPVMAA4'){//case
           // alert("FCI_Customer_Support__c");
            console.log("Distributor End Customer Case");
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'FCI Customer Support' ,name:'FCI Customer Support'},{label:objFieldData.FCI_Customer_Support__r.Name ,name:objFieldData.FCI_Customer_Support__r.Name},{label:objFieldData.CaseNumber , name:objFieldData.CaseNumber}];
           // alert(breadCrumbs)
                component.set("v.mybCrumbs",breadCrumbs);
            
            
        }
        else if(objFieldData !=undefined && objFieldData.RecordTypeId=='01225000000bstvAAA' ){ //objFieldData.RecordTypeId=='01225000000GPVMAA4'){//case
            //alert("FCI_Customer_Support__c");
            console.log("Distributor End Customer Case");
            breadCrumbs =[{label:'Home', name:'Home'},{label:'My Performance' ,name:'My Performance'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:'My Business Strategy' ,name:'My Business Strategy'},{label:objFieldData.Distributor_Business_Strategy__r.Name , name:objFieldData.Distributor_Business_Strategy__r.Name},{label:objFieldData.Field_of_Play__r.Name , name:objFieldData.Field_of_Play__r.Name},{label:objFieldData.Name ,name:objFieldData.Name}];
            //alert(breadCrumbs)
                component.set("v.mybCrumbs",breadCrumbs);
            
           
        }


    },
    
    navigateTo: function (cmp, event, helper) {
        
        //get the name of the breadcrumb that's clicked
        //alert("inside navigateTo ");
       
        var name = event.getSource().get('v.name');
        var location =cmp.get('v.location');
		console.log(event.getSource().get("v.value"));
        console.log('###name###'+name); 
        console.log('location'+location);
        //your custom navigation here
        var urlVal = window.location.href;
        var baseUrl = window.location.href.substring(0,urlVal.indexOf('/s'));
        console.log('urlVal in navigate:: '+baseUrl);

        if (name =='My Performance'){
            var path = baseUrl +'/s'+'/my-performance';
            cmp.set("v.performPath",path);
        }
        else if(name =='Home'){
            var path = baseUrl+'/s';
            cmp.set("v.performPath",path);
            
        }
        else if(name =='My Business Strategy'){//
           // alert("inside my business stat");
            var path = baseUrl+'/s/'+'business-strategy/Business_Strategy__c/Default';
           // alert('https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity');
           // alert(path);
            cmp.set("v.performPath",path);
            
        }
        else if(name.includes('High & Low Lights -')){//'ST -'
            debugger;
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Business_Strategy__c',
                               'recName': name,
                             'loc':location
                             });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/business-strategy/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                }
            });
       $A.enqueueAction(action);

        }
         else if(name.includes('Account Plan -')){//'ST -'
             //alert("Account Plan")
             console.log('location'+location);
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Business_Strategy__c',
                               'recName': name,
                             'loc':location });
            console.log(JSON.stringify( action.setParams));
                action.setCallback(this,function(response){
                    
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    console.log('res'+res);
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/business-strategy/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                }
            });
       $A.enqueueAction(action);

        }
        else if(name.includes('ST -')){
            debugger;
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Business_Strategy__c',
                               'recName': name });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/business-strategy/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                }
            });
       $A.enqueueAction(action);

        }
        else if(name.includes('Competition')){
         //  alert("inside Competition");
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Business_Strategy__c',
                               'recName': name,
                             'loc':location });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/business-strategy/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                }
            });
       $A.enqueueAction(action);

        }
             else if(name.includes('Customer Visit')){
          // alert("inside Customer Visit");
                 
                 console.log(location);
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Commercial_Activity__c',
                               'recName': name,
                             'loc':location
                             });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/business-strategy/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                }
            });
       $A.enqueueAction(action);

        }
         else if(name.includes('Promotion Activity')){
           //alert("inside Promotion Activity");
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Commercial_Activity__c',
                               'recName': name,
                             'loc':location });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/commercial-activity/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                }
            });
       $A.enqueueAction(action);

        }
        else if(name.includes('Samples')){
           //alert("inside Samples");
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Commercial_Activity__c',
                               'recName': name,
                             'loc':location });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/commercial-activity/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                }
            });
       $A.enqueueAction(action);

        }
        else if(name.includes('AP-')){
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Field_of_Play__c',
                               'recName': name });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/field-of-play/'+res+'/'+val1;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);

            //var val = name.toLowerCase();Field_of_Play__c
            //cmp.set("v.performPath", "https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/field-of-play/a0D250000062UFfEAM/"+val);
        }
        else if(name =='Sales Funnel'){
            var path = baseUrl+'/s/'+'sales-funnel/Sales_Funnel__c/Default';
            cmp.set("v.performPath",path);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/sales-funnel/Sales_Funnel__c/Default");
        }
        else if(name.includes('Sales To End Customer')){//'S -'
            console.log("inside sales")
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Sales_Funnel__c',
                               'recName': name,
                             'loc':location
                             });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    console.log('performPath:: '+cmp.get("v.performPath"));
                    var cmpUrl = baseUrl +'/s'+'/sales-funnel/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);

            //var val = name.replace(/ /g,'').toLowerCase();
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/sales-funnel/a1W25000000F0nwEAC/"+val);
        }
        else if(name.includes('DSales -')){
            var val =name.replace(/ /g,'').toLowerCase();
            cmp.set("v.performPath","https://"+DomainCreator.getExperienceCloudSitesHostname()+"/IngredientsMyDistributorcommunity/s/distributor-sales-to-end-customer/a1X25000000FFMzEAO/"+val); 
        }
        else if(name =='Commercial Activities'){
            var path = baseUrl +'/s/'+'commercial-activity/Commercial_Activity__c/Default';
            cmp.set("v.performPath",path);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/commercial-activity/Commercial_Activity__c/Default");
        }
        else if(name.includes('A-')){

            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Commercial_Activity__c',
                            'recName':name});
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/commercial-activity/'+res+'/'+val1;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);


            //var val =name.replace(/ /g,'').toLowerCase();
            //var val1 = val.replace('-','');
            //var urlstr = cmp.get("v.performPath") ;
            //cmp.set("v.performPath",urlstr);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/commercial-activity/a1P2500000226I0EAI/"+val1);
        }
        else if(name =='My Forecasts'){
            var path = baseUrl +'/s/'+'forecast-accuracy/Forecast_Accuracy__c/Default';
            cmp.set("v.performPath",path);
           // cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/forecast/Forecast__c/Default");
        }
        else if (name.includes('F -')) {
            //var val =name.replace(/ /g,'').toLowerCase();
            //var val1 =val.replace(':','-');
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Forecast_Accuracy__c',
                            'recName':name});
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/forecast-accuracy/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);

            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/forecast/a1Z25000002McBaEAK/"+val1);
        }
         else if (name.includes('Local Stock')) {
             console.log("Inside Local Stock"+location);
            //var val =name.replace(/ /g,'').toLowerCase();
            //var val1 =val.replace(':','-');
            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName' : 'Forecast_Accuracy__c',
                            'recName':name,
                             'loc':location });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    //var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/forecast-accuracy/'+res+'/'+val;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);

            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/forecast/a1Z25000002McBaEAK/"+val1);
        }
        /*else if(name.includes('LS :')){
            var val =name.replace(/ /g,'').toLowerCase();
            var val1 =val.replace(':','-');
            cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/local-stock/a1a25000003QlalAAC/"+val1);  
        }*/
        else if(name=='FCI Customer Support'){
            //alert("FCI")
            var path = baseUrl+'/s/'+'fci-customer-support/FCI_Customer_Support__c/Default';
            cmp.set("v.performPath",path);
            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/fci-customer-support/FCI_Customer_Support__c/Default");
        }
        else if(name.includes('FCI Support -')){
            var val =name.replace(/ /g,'-').toLowerCase();
            

            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName':'FCI_Customer_Support__c',
                'recName' : name});
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'-').toLowerCase();
                    var val1 = val.replace('---','-');
                    var cmpUrl = baseUrl +'/s'+'/fci-customer-support/'+res+'/'+val1;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);

            //cmp.set("v.performPath","https://test-frieslandcampinab2b.cs80.force.com/IngredientsMyDistributorcommunity/s/fci-customer-support/a1U25000001aCd3EAE/"+val1);
        }
        else if(name.includes('Support ')){
            var val =name.replace(/ /g,'-').toLowerCase();
            

            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName':'FCI_Customer_Support__c',
                'recName' : name});
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'-').toLowerCase();
                    var val1 = val.replace('---','-');
                    var cmpUrl = baseUrl +'/s'+'/fci-customer-support/'+res+'/'+val1;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);


        }
        else if(name.includes('Order Process')){
            console.log("Inside Order Process");
            var val =name.replace(/ /g,'-').toLowerCase();
            

            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName':'FCI_Customer_Support__c',
                'recName' : name,
                 'loc':location });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'-').toLowerCase();
                    var val1 = val.replace('---','-');
                    var cmpUrl = baseUrl +'/s'+'/fci-customer-support/'+res+'/'+val1;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);


        }
           else if(name.includes('Complaints ')){
            console.log("Inside Order Process");
            var val =name.replace(/ /g,'-').toLowerCase();
            

            var action = cmp.get("c.fetchGenRecId");
            action.setParams({'objName':'FCI_Customer_Support__c',
                'recName' : name,
                  });
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'-').toLowerCase();
                    var val1 = val.replace('---','-');
                    var cmpUrl = baseUrl +'/s'+'/fci-customer-support/'+res+'/'+val1;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);


        }
        else if(name.includes('0001') && !name.includes('-')){
            var action = cmp.get("c.fetchRecId");
            action.setParams({'caseNum' : name});
                action.setCallback(this,function(response){
                var state = response.getState();
                if(state ==="SUCCESS"){
                    var res =response.getReturnValue();
                    //component.set("v.recordId" ,res);
                    var val =name.replace(/ /g,'').toLowerCase();
                    var val1 = val.replace('-','');
                    var cmpUrl = baseUrl +'/s'+'/fci-customer-support/'+res+'/'+val1;
                    cmp.set("v.performPath",cmpUrl);
                    
                }
            });
       $A.enqueueAction(action);


        }  
    
    },
})