({
	//Fetch CoA for particular delivery or all delivery under particular Order
    fetchCoAHelper  : function(component, event, helper) {
        var action = component.get("c.fetchCertificateOfAnalysis");
        component.set("v.showSpinner",true);
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        action.setParams({
            "recordid":component.get("v.recordId"),
            "baseURLSFDC":baseURL
        });
        
        action.setCallback(this,function(response){
            let state = response.getState();
            let files = component.get("v.allCoAFilesRelated");
            let toastEvent = $A.get("e.force:showToast");
            
            if(state==='SUCCESS'){
                
                let result = response.getReturnValue();
                let errors = result.errorsMessage;
                let files= result.coaRecord;
                
                
                if(errors!=null && errors!='' && files.length == 0){
                    component.set("v.showSpinner",false);
                    component.set("v.message",errors);
                    
                    let filesData = component.get("v.allCoAFilesRelated");
                    filesData =[];
                    toastEvent.setParams({
                        title : 'Error',
                        message: errors,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'Error',
                        
                    });
                    toastEvent.fire();
                    component.set("v.allCoAFilesRelated",filesData);
                }
                else if(files.length>0){
                    component.set("v.showSpinner",false);
                    component.set("v.message",'');
                    
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Number of Files Found '+files.length,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'Success',
                        
                    });
                    toastEvent.fire();
                    component.set("v.allCoAFilesRelated",files);
                    
                    if(errors!=null && errors!='' && errors=='Some of the Certificates under this Sales Order Number had errors and were not received. The technical team has been notified.'){
                       
                        toastEvent.setParams({
                        title : 'Error',
                        message: errors,
                        duration:'8000',
                        key: 'info_alt',
                        type: 'Error',
                                           });
                    toastEvent.fire();
                    }
                }
                    else if((errors==null || errors=='') && files.length == 0){
                        
                        component.set("v.showSpinner",false);
                        component.set("v.message",'Certificate data not found !');
                        
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Certificate data not found!',
                            duration:'5000',
                            key: 'info_alt',
                            type: 'Error',
                            
                        });
                        toastEvent.fire();
                        
                         component.set("v.message",'Certificate data not found!');
                        component.set("v.allCoAFilesRelated",files);
                        
                    }
                
            }
            else if(state==='ERROR'){
                component.set("v.showSpinner",false);
                component.set("v.message",'');
                let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Not able to connect to server, please try after some time',
                            duration:'5000',
                            key: 'info_alt',
                            type: 'Error',
                            
                        });
                        toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
       
        
    }
})