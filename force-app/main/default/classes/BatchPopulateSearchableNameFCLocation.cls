public class BatchPopulateSearchableNameFCLocation implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT id , Supplier_Hub__c, Location__c, Location__r.Name, Location__r.Is_Active__c from Supplier_Location__c WHERE Location__r.Is_Active__c = TRUE';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Supplier_Location__c> records){
        system.debug('count '+ records.size());
        List<Id> locaitonIds = new List<Id>();
        List<Supplier_Location__c> fcLocaitonUpdateList = new List<Supplier_Location__c>();
        for(Supplier_Location__c obj: records){
            if(obj.Location__c != null){
                locaitonIds.add(obj.Location__c);
            }
        }
        for(Location__c loc : [SELECT Id, Name FROM Location__c WHERE Id IN :locaitonIds]){
            for(Supplier_Location__c sl: records){
                if( loc.Name != null && sl.Location__c != null && sl.Location__c == loc.Id ){
                    sl.Location_Name_Searchable__c  = loc.Name;
                    fcLocaitonUpdateList.add(sl);
                }
            }
        }
        if(!fcLocaitonUpdateList.isEmpty()){
            Database.SaveResult[] srList = Database.update(fcLocaitonUpdateList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully updated  ID is : ' + sr.getId());
                } else {
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug(' oject field which are affected by the error:' 
                                     + objErr.getFields());
                    }
                }
        }
        }
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}