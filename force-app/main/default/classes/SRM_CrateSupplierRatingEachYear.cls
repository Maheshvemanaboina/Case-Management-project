public class SRM_CrateSupplierRatingEachYear implements Database.Batchable<sObject>{
    public String query;
    Map<Id, Value_Element__c> valueElementMap;
    Map<String, List<Value_Element__c>> segment2ValueElementsMap;
    public SRM_CrateSupplierRatingEachYear() {
         segment2ValueElementsMap = new Map<String, List<Value_Element__c>>();
        valueElementMap = new Map<Id, Value_Element__c>([select id, Segment__c, Is_Active__c, Name from Value_Element__c WHERE Is_Active__c = TRUE ]);
        for(Value_Element__c ve :valueElementMap.values()) {
            if(segment2ValueElementsMap.containsKey(ve.Segment__c)) {
                segment2ValueElementsMap.get(ve.Segment__c).add(ve);
            } else {
                segment2ValueElementsMap.put(ve.Segment__c, new List<Value_Element__c> { ve });
            }
        }
    }
    public Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select id, Business_Group__c, Supplier_Hub__c, Supplier_Hub__r.Supplier_Name__c, Location__c, Location__r.Name,Is_Active__c,Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__r.Segment__c from Supplier_Location__c where Is_Active__c = true ');
    }
    public void execute(Database.BatchableContext BC, List<Supplier_Location__c> scope) {
        system.debug('scope '+ scope);
        
        List<Supplier_Rating__c> supplierRatingInsertList = new List<Supplier_Rating__c>();
        for(Supplier_Location__c sl : scope) {
            for(Value_Element__c ve : segment2ValueElementsMap.get(sl.Supplier_Hub__r.Segment__c)) {
                if( sl.Is_Active__c  ){
                    supplierRatingInsertList.add(new Supplier_Rating__c(SRM_Business_Group__c = sl.Business_Group__c, Value_Element__c = ve.Id, Supplier_Hub__c = sl.Supplier_Hub__c, Location__c = sl.Location__c, FC_Location__c= sl.Id, Rating_Year__c = '2023',Rating_Is_Active__c = true, Supplier_Rating_Header__c = sl.Supplier_Hub__r.Supplier_Rating_Header__c));
                }
            }
        }
        system.debug('supplierRatingInsertList '+ supplierRatingInsertList);
        
        Database.SaveResult[] srList = Database.insert(supplierRatingInsertList, false);
        List<SRM_Rating_Error_Log__c> failedRecs = new List<SRM_Rating_Error_Log__c>();
        for(Integer j=0; j<supplierRatingInsertList.size(); j++){
            system.debug('supplierRatingInsertList '+ supplierRatingInsertList.get(j));
            if(! srList.get(j).isSuccess()){
                for(Database.Error objErr : srList.get(j).getErrors()) {
                    system.debug('failed record '+ supplierRatingInsertList.get(j));
                    Supplier_Rating__c failedRatingRecord = supplierRatingInsertList.get(j);
                    SRM_Rating_Error_Log__c log = new SRM_Rating_Error_Log__c();
                    log.Supplier_Hub_c__c = failedRatingRecord.Supplier_Hub__c;
                    log.SRM_Business_Group_c__c=failedRatingRecord.SRM_Business_Group__c;
                    log.Value_Element_c__c=failedRatingRecord.Value_Element__c;
                    log.Rating_Year_c__c=failedRatingRecord.Rating_Year__c;
                    log.Location_c__c=failedRatingRecord.Location__c;
                    log.FC_Location_c__c=failedRatingRecord.FC_Location__c;
                    log.ErrorDescription__c= 'status code: '+ objErr.getStatusCode()+ 'Error Message '+ objErr.getMessage()+ 'error Fields '+ objErr.getFields();
                    failedRecs.add(log);
                }
                
            }
        }
        insert failedRecs;
        
    }
    public void finish(Database.BatchableContext BC) {}
    
}