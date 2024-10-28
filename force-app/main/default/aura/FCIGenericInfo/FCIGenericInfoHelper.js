({
	setBreadCrumbsOnInit : function(component, event, helper) {
		var myBreadcrumbs = [
            {
                label: 'FrieslandCampina General Information',
                name: 'FrieslandCampina General Information'
            }
        ];
        component.set('v.breadCrumbs', myBreadcrumbs);
	},
    
    setBaseUrl : function(component, event, helper) {
       var urlString = window.location.href;
       var baseURL = urlString.substring(0, urlString.indexOf("/s"));
       component.set("v.baseUrl", baseURL);
    },
    
    displayIFrameOnClick :function(component, clickedLink){
        component.set("v.displayFileIFrame",true);
        console.log('clickedLink --> '+clickedLink);
        if(clickedLink == 'Lead with sustainaibility'){
            component.set("v.iFrameSrc",'https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001daqj/f.H1R21LZhcOON.HYgs.G9VqA4tQl5eyvGl81HYUioY');
        }
        else if(clickedLink == 'FrieslandCampina Introduction'){
            component.set("v.iFrameSrc",'https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001dar8/FMyp2oUnVhZr2yW.YRFWtH8ZhsgzyFUjXqfxxYa2gp8');
        }
        else if(clickedLink == 'FrieslandCampina Ingredients Introduction'){
            component.set("v.iFrameSrc",'https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001dar3/95mNS7_yOFc1ZFyrn0W9z9eRug2lb.fzNSbLqPR_YCk');
        }
        else if(clickedLink == 'FCI Early Life Nutrition'){
            component.set("v.iFrameSrc",'https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001daqp/r_C8o2ppNGK_TmaoqorB92XZ3bXSiYohyJPY6e1Cq7A');
        }
        else if(clickedLink == 'FCI Food & Beverages and Animal Nutrition'){
            component.set("v.iFrameSrc",'https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001daqq/xk85QaQLjkDoEL5FFZD.zFxZbskOw2533dK8aWF.5F0');
        }
        else if(clickedLink == 'FCI Adult Nutrition'){
            component.set("v.iFrameSrc",'https://frieslandcampinaconnect.my.salesforce.com/sfc/p/58000000ZNVx/a/4H000001daqo/eEuoyABtH.Gf_QfyaSbR5zXOjbEiwg1vqKkPn3d06zY');
        }
    },
    
    hideIFrame : function(component, event, helper){
        component.set("v.displayFileIFrame",false);
        component.set("v.iFrameSrc",'');
    },
    
    setBreadCrumbsOnChange : function(component, clickedLink){
        var breadCrumbs = component.get('v.breadCrumbs');
        var breadCrumbsLength = breadCrumbs.length;
        
        breadCrumbs[breadCrumbsLength] = {
            label: clickedLink,
            name: clickedLink
        };

        component.set('v.breadCrumbs', breadCrumbs);
    },
    
    setBreadCrumbData : function(component, event, helper, name){
        if(name == 'FrieslandCampina General Information'){
            helper.hideIFrame(component, event, helper);
            helper.setBreadCrumbsOnInit(component, event, helper);
        }
    }
})