({
   handleCloseModal: function(component, event, helper) {
      component.set("v.isOpen", false);
      $A.get("e.force:closeQuickAction").fire();
   },

   handleClone: function(component, event, helper) {
      component.set("v.isLoading", true);
      helper.cloneAssessmentRecord(component, event, helper);
   }
})