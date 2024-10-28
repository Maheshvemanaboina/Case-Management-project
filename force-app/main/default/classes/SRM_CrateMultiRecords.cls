public class SRM_CrateMultiRecords {
@AuraEnabled
    public static List<Supplier_Hub__c > getSUpplier(String searchType,string searchText){
        Set<Id> supplierSet = new Set<Id>();
        searchText = searchText+ '%';
        String query = 'select id, Supplier_Name__c, DUNS_Number__c, Segment__c  from Supplier_Hub__c';
        if (String.isNotBlank(searchText) && searchtype == 'Supplier Name') {
            query += ' where Supplier_Name__c   like: searchText';
        }else if(String.isNotBlank(searchText) && searchtype == 'Duns Number'){
            query += ' where DUNS_Number__c   like: searchText';
        }else if(String.isNotBlank(searchText) && searchtype == 'Vendor BK Number'){
            query = 'select id,Supplier_Hub__c from Supplier_SAP_Numbers_And_Payment_Terms__c';
            query += ' where Vendor_Sap_Number__c like: searchText';
            
            List<Supplier_SAP_Numbers_And_Payment_Terms__c> vendorDataList =  Database.query(query);
            if(! vendorDataList.isEmpty()){
                for(Supplier_SAP_Numbers_And_Payment_Terms__c obj: vendorDataList){
                    supplierSet.add(obj.Supplier_Hub__c);
                }
            }
            if(! supplierSet.isEmpty()){
                return [Select id, Supplier_Name__c, DUNS_Number__c, Segment__c  from Supplier_Hub__c  where Id   IN : supplierSet ];
            }
        }
        system.debug('query '+query );
         List<Supplier_Hub__c> lacc =  Database.query(query);
        SYSTEM.debug('LENGHT '+ lacc.size());
        return lacc;
    }
}