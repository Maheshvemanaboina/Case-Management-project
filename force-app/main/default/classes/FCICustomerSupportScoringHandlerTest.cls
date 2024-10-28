@isTest
public class FCICustomerSupportScoringHandlerTest {

    @isTest
    public static void test1(){
         set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('FCI_Customer_Support_Master');
        recordTypeDevNameSet.add('FCI_Customer_Support_Order_Process');
        recordTypeDevNameSet.add('Order_Process');
                
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
        
        FCI_Customer_Support__c parentRecord = new FCI_Customer_Support__c();
        parentRecord.Name = 'parent Record';
        parentRecord.Name = 'parent rec';
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.RecordTypeId = reccordTypeNameMap.get('FCI_Customer_Support_Master');
        insert parentRecord;
        FCI_Customer_Support__c subParent = new FCI_Customer_Support__c();
        subParent.Name = 'parent Record';
        subParent.Name = 'parent rec';
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('FCI_Customer_Support_Order_Process');
        subParent.Parent_FCI_Customer_Support__c = parentRecord.ID;
        insert subParent;
        List<FCI_Customer_Support__c> childRecordList = new List<FCI_Customer_Support__c>();
        FCI_Customer_Support__c childRecord1 = new FCI_Customer_Support__c();
        childRecord1.Name = 'parent Record';
        childRecord1.Name = 'parent rec';
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Order_Process');
        childRecord1.Order_policy_adherence__c = '>90% orders in line with order policy';
        childRecord1.FCI_Customer_Support_Order_Process__c = subParent.ID;
        FCI_Customer_Support__c childRecord2 = new FCI_Customer_Support__c();
        childRecord2.Name = 'parent Record';
        childRecord2.Name = 'parent rec';
        childRecord2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord2.Period__c = '1st Half Year';
        childRecord2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord2.Distributor_Account__c = customerLocation.Id;
        childRecord2.RecordTypeId = reccordTypeNameMap.get('Order_Process');
        childRecord2.Order_policy_adherence__c = '>80 & <90% orders in line with order policy';
        childRecord2.FCI_Customer_Support_Order_Process__c = subParent.ID;
        childRecordList.add(childRecord1);
        childRecordList.add(childRecord2);
        insert childRecordList;
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
        
        FCI_Customer_Support__c parentRecord = new FCI_Customer_Support__c();
        parentRecord.Name = 'parent Record';
        parentRecord.Name = 'parent rec';
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.RecordTypeId = reccordTypeNameMap.get('FCI_Customer_Support_Master');
        insert parentRecord;
        FCI_Customer_Support__c subParent = new FCI_Customer_Support__c();
        subParent.Name = 'parent Record';
        subParent.Name = 'parent rec';
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('FCI_Customer_Support_Order_Process');
        subParent.Parent_FCI_Customer_Support__c = parentRecord.ID;
        insert subParent;
        List<FCI_Customer_Support__c> childRecordList = new List<FCI_Customer_Support__c>();
        FCI_Customer_Support__c childRecord1 = new FCI_Customer_Support__c();
        childRecord1.Name = 'parent Record';
        childRecord1.Name = 'parent rec';
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Order_Process');
        childRecord1.Order_policy_adherence__c = '>90% orders in line with order policy';
        childRecord1.FCI_Customer_Support_Order_Process__c = subParent.ID;
        FCI_Customer_Support__c childRecord2 = new FCI_Customer_Support__c();
        childRecord2.Name = 'parent Record';
        childRecord2.Name = 'parent rec';
        childRecord2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord2.Period__c = '1st Half Year';
        childRecord2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord2.Distributor_Account__c = customerLocation.Id;
        childRecord2.RecordTypeId = reccordTypeNameMap.get('Order_Process');
        childRecord2.Order_policy_adherence__c = '>80 & <90% orders in line with order policy';
        childRecord2.FCI_Customer_Support_Order_Process__c = subParent.ID;
        childRecordList.add(childRecord1);
        childRecordList.add(childRecord2);
        insert childRecordList;
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'No';
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
        
        FCI_Customer_Support__c parentRecord = new FCI_Customer_Support__c();
        parentRecord.Name = 'parent Record';
        parentRecord.Name = 'parent rec';
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.RecordTypeId = reccordTypeNameMap.get('FCI_Customer_Support_Master');
        insert parentRecord;
        FCI_Customer_Support__c subParent = new FCI_Customer_Support__c();
        subParent.Name = 'parent Record';
        subParent.Name = 'parent rec';
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('FCI_Customer_Support_Order_Process');
        subParent.Parent_FCI_Customer_Support__c = parentRecord.ID;
        insert subParent;
        List<FCI_Customer_Support__c> childRecordList = new List<FCI_Customer_Support__c>();
        FCI_Customer_Support__c childRecord1 = new FCI_Customer_Support__c();
        childRecord1.Name = 'parent Record';
        childRecord1.Name = 'parent rec';
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Order_Process');
        childRecord1.Order_policy_adherence__c = '>90% orders in line with order policy';
        childRecord1.FCI_Customer_Support_Order_Process__c = subParent.ID;
        FCI_Customer_Support__c childRecord2 = new FCI_Customer_Support__c();
        childRecord2.Name = 'parent Record';
        childRecord2.Name = 'parent rec';
        childRecord2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord2.Period__c = '1st Half Year';
        childRecord2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord2.Distributor_Account__c = customerLocation.Id;
        childRecord2.RecordTypeId = reccordTypeNameMap.get('Order_Process');
        childRecord2.Order_policy_adherence__c = '>90% orders in line with order policy';
        childRecord2.FCI_Customer_Support_Order_Process__c = subParent.ID;
        childRecord2.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        childRecordList.add(childRecord1);
        childRecordList.add(childRecord2);
        insert childRecordList;
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update childRecord1;
        subParent.Parent_FCI_Customer_Support__c = null;
        Update subParent;
        Delete subParent;
        
    }
}