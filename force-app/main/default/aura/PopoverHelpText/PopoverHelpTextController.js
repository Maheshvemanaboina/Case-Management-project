({
	handleMouseOver : function(component, event, helper){
    var tooltipId = event.target.getAttribute("data-tooltipId");
    console.log(tooltipId);
    $A.util.removeClass(component.find(tooltipId), 'slds-fall-into-ground');
    $A.util.addClass(component.find(tooltipId), 'slds-rise-from-ground');
    },

    handleMouseOut : function(component, event, helper){
    
    var tooltipId = event.target.getAttribute("data-tooltipId");
    $A.util.removeClass(component.find(tooltipId), 'slds-rise-from-ground');
    $A.util.addClass(component.find(tooltipId), 'slds-fall-into-ground');
   }
})