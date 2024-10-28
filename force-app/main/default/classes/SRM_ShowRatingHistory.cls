public class SRM_ShowRatingHistory {
    public ApexPages.StandardSetController standardController;
    public Set<Id> ratingIds {get;set;}
    public Map<Id, Supplier_Rating__c> selectedRatings {get;set;}
    public List<Supplier_Rating__c> selectedRatingrList {get;set;}
    public static List<String> errorStrings {get;set;}
    public static Boolean showSuccess {get;set;}
    public Boolean showSendButton {get;set;}
    public Boolean isValidationError {get;set;}
    public String customIdsStr {get;set;}
    public String retUrl{get;set;}
    //Constructor
    public SRM_ShowRatingHistory(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        errorStrings = new List<String>();
        ratingIds = new Set<Id>(); 
        selectedRatings = new Map<Id, Supplier_Rating__c>();
        showSuccess= false;
        showSendButton = true;
        selectedRatingrList = new List<Supplier_Rating__c>();
        for (Supplier_Rating__c ratingobj : (List<Supplier_Rating__c>)standardController.getSelected()){ 
            ratingIds.add(ratingobj.Id);
        }
        customIdsStr = JSON.serialize(ratingIds);
        selectedRatings = getRatings(ratingIds);
        selectedRatingrList = selectedRatings.values();
        if( selectedRatingrList.isEmpty()){
            isValidationError = true;
            errorStrings.add('Please select orders to process.!');
        }
		doAction();
    }    
    public static PageReference redirectToListView() {
        ApexPages.Action redirectAction = new ApexPages.Action('{!List}');
        return new ApexPages.Action('{!List}').invoke();
    }
    public static Map<Id, Supplier_Rating__c> getRatings(Set<Id> ratingIds){
        return new Map<Id,Supplier_Rating__c>([select Id from Supplier_Rating__c where Id IN: ratingIds]);
    }
    public void doAction(){
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