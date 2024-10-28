({  
    handleLoad : function(component, event, helper) {
        var recUi = event.getParam("recordUi");
        //alert("hi");
        //console.log('Execute');
        
        if(recUi.record.fields["Business_Segment__c"].value=='Food & Beverages'){
            component.set('v.iFrameSrc','https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001dZe3/1s1bqehMkjyZs.sC8hvuRNhQA4oM_DMUYE1pgVmkFLY');
        
        }   else if(recUi.record.fields["Business_Segment__c"].value=='Adult Nutrition'){
            component.set('v.iFrameSrc','https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001dZdo/acS7zUoITdR.kc5ZRQbDeDgmnOiVOABByzmBpWyGkvA');
            
        }   else if(recUi.record.fields["Business_Segment__c"].value=='Early Life Nutrition & Cell Nutrition'){
            component.set('v.iFrameSrc','https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001dZdy/JYYtIAcPyu5bVGcAIsQAJYc9ckZTcZmqtxaU_c1NpbA');
            
        }
            else if(recUi.record.fields["Business_Segment__c"].value=='Animal Nutrition'){
                component.set('v.iFrameSrc','https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001dZdt/_Zw238ZBNygoZHMKXidT6tsFHS5B4MKneJNvncRoC.s');
        }
    }
})