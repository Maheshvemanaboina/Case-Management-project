({
	handleBackOrHomeClick : function(component, event, helper) {
		var homeclick = component.get("v.HomeBut");
        if(homeclick){
            helper.returnToHomePage(component, event, helper);
            
        }
        else{
            helper.returnToBackPage(component, event, helper);
        }
	}
})