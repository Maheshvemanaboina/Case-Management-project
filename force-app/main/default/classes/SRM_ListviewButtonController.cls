public class SRM_ListviewButtonController {
    public String retUrl{get;set;}
    // Define constructor for standartset controller
    public SRM_ListviewButtonController(ApexPages.StandardSetController controller) {
     doAction();
    }             public void doAction(){
        System.debug('--- Executed listview button method ---');
        // get the return url if it's in Lightning view
        retUrl = apexpages.currentpage().getParameters().get('vfRetURLInSFX');      
        // get the return url if it's in classic view
        if(String.isBlank(retUrl))
            retUrl = apexpages.currentpage().getParameters().get('retURL');        
        // do page reference
        system.debug('returnurl '+ retUrl);
    }
}