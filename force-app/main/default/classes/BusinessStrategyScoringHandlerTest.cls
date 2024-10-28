@isTest
public class BusinessStrategyScoringHandlerTest {
    
    @isTest
    public static void test1(){
        set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Business_Strategy_Master');
        recordTypeDevNameSet.add('Business_Strategy_High_Low_Lights');
        recordTypeDevNameSet.add('High_Low_Lights');
        recordTypeDevNameSet.add('Business_Strategy_Competition');
        recordTypeDevNameSet.add('Competition');
        recordTypeDevNameSet.add('Competition_Account_Plan');
        
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE DeveloperName IN : recordTypeDevNameSet];        
        
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
        Account accountH1 = new Account();
        accountH1.Name = 'test h1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
        Business_Strategy__c parentRecord1 = new Business_Strategy__c();
        parentRecord1.Name = 'testtparen1';
        parentRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord1.Period__c = '1st Half Year';
        parentRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Master');
        parentRecord1.Distributor_Account__c = customerLocation.Id;
        insert parentRecord1;
        Business_Strategy__c subParent1 = new Business_Strategy__c();
        subParent1.Name = 'testtsub1';
        subParent1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent1.Period__c = '1st Half Year';
        subParent1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent1.Parent_Business_Strategy__c = parentRecord1.Id;
        subParent1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_High_Low_Lights');
        insert subParent1;
        List<Business_Strategy__c> childRecords = new List<Business_Strategy__c>();
        Business_Strategy__c child1 = new Business_Strategy__c();
        child1.Name = 'testchild1';
        child1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child1.Period__c = '1st Half Year';
        child1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child1.RecordTypeId = reccordTypeNameMap.get('High_Low_Lights');
        child1.Business_Strategy_High_Low_Lights__c = subParent1.Id;
        child1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        childRecords.add(child1);
        Business_Strategy__c child2 = new Business_Strategy__c();
        child2.Name = 'testchild2';
        child2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child2.Period__c = '1st Half Year';
        child2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child2.RecordTypeId = reccordTypeNameMap.get('High_Low_Lights');
        child2.Business_Strategy_High_Low_Lights__c = subParent1.Id;
        child2.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        childRecords.add(child2);
        Business_Strategy__c child3 = new Business_Strategy__c();
        child3.Name = 'testchild3';
        child3.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child3.Period__c = '1st Half Year';
        child3.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child3.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child3.RecordTypeId = reccordTypeNameMap.get('High_Low_Lights');
        child3.Business_Strategy_High_Low_Lights__c = subParent1.Id;
        child3.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        childRecords.add(child3);
        insert childRecords;
        List<Business_Strategy__c> updateChildList = new List<Business_Strategy__c>();
        child1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        updateChildList.add(child1);
        child3.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        updateChildList.add(child3);
        update updateChildList;
        try{
           delete child1;
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
        accountH1.Name = 'test h1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
        Business_Strategy__c parentRecord1 = new Business_Strategy__c();
        parentRecord1.Name = 'testtparen1';
        parentRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord1.Period__c = '1st Half Year';
        parentRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Master');
        parentRecord1.Distributor_Account__c = customerLocation.Id;
        insert parentRecord1;
        Business_Strategy__c subParent1 = new Business_Strategy__c();
        subParent1.Name = 'testtsub1';
        subParent1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent1.Period__c = '1st Half Year';
        subParent1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent1.Parent_Business_Strategy__c = parentRecord1.Id;
        subParent1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Competition');
        insert subParent1;
        List<Business_Strategy__c> childRecords = new List<Business_Strategy__c>();
        Business_Strategy__c child1 = new Business_Strategy__c();
        child1.Name = 'testchild1';
        child1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child1.Period__c = '1st Half Year';
        child1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child1.RecordTypeId = reccordTypeNameMap.get('Competition');
        child1.Business_Strategy_Competition__c = subParent1.Id;
        child1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        childRecords.add(child1);
        Business_Strategy__c child2 = new Business_Strategy__c();
        child2.Name = 'testchild2';
        child2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child2.Period__c = '1st Half Year';
        child2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child2.RecordTypeId = reccordTypeNameMap.get('Competition');
        child2.Business_Strategy_Competition__c = subParent1.Id;
        child2.Confirmed_by_FCI_Sales_Manager__c = 'No';
        childRecords.add(child2);
        Business_Strategy__c child3 = new Business_Strategy__c();
        child3.Name = 'testchild3';
        child3.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child3.Period__c = '1st Half Year';
        child3.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child3.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child3.RecordTypeId = reccordTypeNameMap.get('Competition');
        child3.Business_Strategy_Competition__c = subParent1.Id;
        child3.Confirmed_by_FCI_Sales_Manager__c = 'No';
        childRecords.add(child3);
        insert childRecords;
        child1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update child1;
        try{
           delete child1;
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('You cannot delete KPI records'));
        }
    }
    
    @isTest
    public static void test3(){
        
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType];
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
        Account accountH1 = new Account();
        accountH1.Name = 'test h1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
        Business_Strategy__c parentRecord1 = new Business_Strategy__c();
        parentRecord1.Name = 'testtparen1';
        parentRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord1.Period__c = '1st Half Year';
        parentRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Master');
        parentRecord1.Distributor_Account__c = customerLocation.Id;
        insert parentRecord1;
        Business_Strategy__c subParent1 = new Business_Strategy__c();
        subParent1.Name = 'testtsub1';
        subParent1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent1.Period__c = '1st Half Year';
        subParent1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent1.Parent_Business_Strategy__c = parentRecord1.Id;
        subParent1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Competition');
        insert subParent1;
        List<Business_Strategy__c> childRecords = new List<Business_Strategy__c>();
        Business_Strategy__c child1 = new Business_Strategy__c();
        child1.Name = 'testchild1';
        child1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child1.Period__c = '1st Half Year';
        child1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child1.RecordTypeId = reccordTypeNameMap.get('Competition_Account_Plan');
        child1.Business_Strategy_Competition__c = subParent1.Id;
        child1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        childRecords.add(child1);
        Business_Strategy__c child2 = new Business_Strategy__c();
        child2.Name = 'testchild2';
        child2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child2.Period__c = '1st Half Year';
        child2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child2.RecordTypeId = reccordTypeNameMap.get('Competition_Account_Plan');
        child2.Business_Strategy_Competition__c = subParent1.Id;
        child2.Confirmed_by_FCI_Sales_Manager__c = 'No';
        childRecords.add(child2);
        Business_Strategy__c child3 = new Business_Strategy__c();
        child3.Name = 'testchild3';
        child3.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        child3.Period__c = '1st Half Year';
        child3.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        child3.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        child3.RecordTypeId = reccordTypeNameMap.get('Competition_Account_Plan');
        child3.Business_Strategy_Competition__c = subParent1.Id;
        child3.Confirmed_by_FCI_Sales_Manager__c = 'No';
        childRecords.add(child3);
        insert childRecords;
        child1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        update child1;
        
        subParent1.Parent_Business_Strategy__c = null;
        update subParent1;
        Delete subParent1;
        
    }
    
    
    
}