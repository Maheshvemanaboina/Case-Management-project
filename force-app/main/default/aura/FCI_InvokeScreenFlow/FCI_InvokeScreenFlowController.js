({
    /* 
      @Description :This controller method will execute when user will click on the Global action button
      @CreatedBy :Mohammad RAfi
      @Prams: component, event,Helper
    */
    doInit : function (component,event,helper) {
        let flow = component.find("flow");
        flow.startFlow("New_Case");
    }
})