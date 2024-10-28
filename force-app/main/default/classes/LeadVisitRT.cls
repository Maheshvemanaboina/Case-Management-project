public class LeadVisitRT {
    
   @AuraEnabled        
    public static Map<String,String> fetchRecordTypeValues(){
         Map<String,String> recordTypeMap = new Map<String,String>();
         for(RecordTypeInfo info: Visit_Report__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() && info.getName() != 'Master' && info.getName() != 'FCI - Lead Visit Report') {
                    if(info.getName() == 'FCI Visit Report'){
                        recordTypeMap.put(info.getName()+'',info.getDeveloperName());
                    }else if(info.getName() == 'FCI Visit Report_NA'){
                        recordTypeMap.put(info.getName()+' (FCI)',info.getDeveloperName());
                    }else if(info.getName() == 'Visit Reports'){
                        recordTypeMap.put(info.getName()+' (DE)',info.getDeveloperName());
                    }else if(info.getName() == 'NC Visit Report'){
                        recordTypeMap.put(info.getName()+' (Nutrition Community Visit Report)',info.getDeveloperName());
                    }else{
                        recordTypeMap.put(info.getName(),info.getDeveloperName());
                    }
                    
                }
		 }
        return recordTypeMap;
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Visit_Report__c.getRecordTypeInfosByDeveloperName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }      
}