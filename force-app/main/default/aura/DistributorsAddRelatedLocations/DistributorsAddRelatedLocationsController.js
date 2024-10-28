({
	
   openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
      helper.openModel(component, event, helper);
      
   },
  
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false 
      helper.closeModel(component, event, helper); 
      
   },

   handleSObjectLookUpSelect : function(component, event, helper){

      helper.handleSObjectLookUpSelect(component, event, helper); 
    
    },

   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      helper.submitDetails(component, event, helper);
      
   },

   onChange : function(component, event, helper) {
      helper.onChange(component, event, helper);
      
   },

   removeRecord : function(component, event, helper) {
      helper.removeRecord(component, event, helper);
      helper.onChange(component, event, helper);
      
   }
})