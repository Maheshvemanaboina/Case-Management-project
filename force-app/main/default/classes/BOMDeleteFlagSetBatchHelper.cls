/*
* @Author : Mohan 
* @Date : 31th Aug 2021
* @Desc : Helper class to set the BOM delete flag
* @Jira : SCPQ-1111
*/
public class BOMDeleteFlagSetBatchHelper {
     
     // PROPERTIES //
    @testVisible
    private static Boolean throwException = false;
    
    //This Method logic contains to set Bom Flag to true
    Public static void setDeleteFlag(List<CPQ_Bill_Of_Material_SAP__c> lstBOM){
       List<CPQ_Bill_Of_Material_SAP__c> lstDeleteBOM = new  List<CPQ_Bill_Of_Material_SAP__c>();
        //added by shiva - start
        GeneralBatchSetting__c batchSettings = GeneralBatchSetting__c.getValues('BOMDeleteFlagSetBatch');
    	string bomBatchQuery = batchSettings.Batch_Query__c;
        Map<String, CPQ_Bill_Of_Material_SAP__c> mapBOMRecords = new Map<String, CPQ_Bill_Of_Material_SAP__c>();

        Date todaydate = date.today();
        integer days = todaydate.day()-Integer.ValueOf(batchSettings.Days__c);
        Date firstofday = todaydate.addDays(-days);	
        string query;
        // retriving new records which are updated after 1st date of current month
        if(!test.isRunningTest()){
        query =bomBatchQuery+' And LastModifiedDate >:firstofday'; 
        }else{
             query = 'select Id,Delete__c,External_Key__c from CPQ_Bill_Of_Material_SAP__C limit 1' ;            
        }
        
        List<CPQ_Bill_Of_Material_SAP__c> lstNewBOMData = Database.query(query);
        for(CPQ_Bill_Of_Material_SAP__c Boms : lstNewBOMData){
			mapBOMRecords.put(Boms.External_Key__c,Boms);
        }        
        // added by shiva -end
        for(CPQ_Bill_Of_Material_SAP__c Boms : lstBOM){
            CPQ_Bill_Of_Material_SAP__c Bom = new CPQ_Bill_Of_Material_SAP__c();
            if(!mapBOMRecords.containsKey(Boms.External_Key__c)){//added by shiva- check external key
                Bom = Boms;
                Bom.Delete__c = true;
                lstDeleteBOM.add(Bom);
            }            
        }
        if(!lstDeleteBOM.isEmpty()){
            try{
                Database.update(lstDeleteBOM, false);
                 // In case of testing, throw an exception //
                if ( throwException ) throw new NullPointerException();
                
            }catch(Exception stackedError){
                 String comment = 'Failed while attempting to update the BOM delete flag values';
                 Utilities.generateDebugLogsForErrorHandling(stackedError, lstDeleteBOM, comment);
            }
            
        }
        
    }
    
}