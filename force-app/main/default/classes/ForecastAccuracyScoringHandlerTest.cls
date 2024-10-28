@isTest
public class ForecastAccuracyScoringHandlerTest {

    @isTest
    public static void test1(){
         set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Forecast_Master');
        recordTypeDevNameSet.add('Forecast_Accuracy_Local_Stock');
        recordTypeDevNameSet.add('Local_Stock');
       
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE DeveloperName IN : recordTypeDevNameSet]; 
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
        Forecast_Accuracy__c parentRecord = new Forecast_Accuracy__c();
        parentRecord.Name = 'parent rec';
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Forecast_Master');
        insert parentRecord;
        Forecast_Accuracy__c subParent = new Forecast_Accuracy__c();
        subParent.Name = 'parent rec';
        subParent.Fiscal_Year_FY__c =String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Forecast_Accuracy_Local_Stock');
        subParent.Parent_Forecast__c = parentRecord.Id;
        insert subParent;
        Forecast_Accuracy__c childRecord1 = new Forecast_Accuracy__c();
        childRecord1.Name = 'parent rec';
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Local_Stock_Status__c = '> One month of stock';
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Local_Stock');
        childRecord1.Forecast_Accuracy_Local_Stock__c = subParent.Id;
        insert childRecord1;
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update childRecord1;
        try{
           delete childRecord1; 
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('You cannot delete KPI records'));
        }
        
    }
    
    @isTest
    public static void test2(){
         List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType];
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
        Forecast_Accuracy__c parentRecord = new Forecast_Accuracy__c();
        parentRecord.Name = 'parent rec';
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Forecast_Master');
        insert parentRecord;
        Forecast_Accuracy__c subParent = new Forecast_Accuracy__c();
        subParent.Name = 'parent rec';
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Forecast_Accuracy_Local_Stock');
        subParent.Parent_Forecast__c = parentRecord.Id;
        insert subParent;
        List<Forecast_Accuracy__c> childRecordList = new List<Forecast_Accuracy__c>();
        Forecast_Accuracy__c childRecord1 = new Forecast_Accuracy__c();
        childRecord1.Name = 'parent rec';
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Local_Stock_Status__c = '> One month of stock';
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Local_Stock');
        childRecord1.Forecast_Accuracy_Local_Stock__c = subParent.Id;
        childRecordList.add(childRecord1);
        Forecast_Accuracy__c childRecord2 = new Forecast_Accuracy__c();
        childRecord2.Name = 'parent rec';
        childRecord2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord2.Period__c = '1st Half Year';
        childRecord2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord2.Distributor_Account__c = customerLocation.Id;
        childRecord2.RecordTypeId = reccordTypeNameMap.get('Local_Stock');
        childRecord2.Forecast_Accuracy_Local_Stock__c = subParent.Id;
        childRecord2.Confirmed_by_FCI_Sales_Manager__c = 'No';
        childRecordList.add(childRecord2);
        insert childRecordList;
        
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update childRecord1;
        
    }
    
    @isTest
    public static void test3(){
         List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType];
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
        Forecast_Accuracy__c parentRecord = new Forecast_Accuracy__c();
        parentRecord.Name = 'parent rec';
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Forecast_Master');
        insert parentRecord;
        Forecast_Accuracy__c subParent = new Forecast_Accuracy__c();
        subParent.Name = 'parent rec';
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Forecast_Accuracy_Local_Stock');
        subParent.Parent_Forecast__c = parentRecord.Id;
        insert subParent;
        Forecast_Accuracy__c childRecord1 = new Forecast_Accuracy__c();
        childRecord1.Name = 'parent rec';
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Local_Stock');
        childRecord1.Forecast_Accuracy_Local_Stock__c = subParent.Id;
        insert childRecord1;
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        update childRecord1;        
        subParent.Parent_Forecast__c =null;
        Update subParent;
        Delete subParent;
        
        
    }
    
}