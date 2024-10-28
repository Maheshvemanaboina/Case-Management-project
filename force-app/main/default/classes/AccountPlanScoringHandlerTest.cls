@isTest
public class AccountPlanScoringHandlerTest {

    @isTest
    public static void test1(){
         set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Business_Strategy_Master');
        recordTypeDevNameSet.add('Business_Strategy_Account_Plan');
       
        
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
        parentRecord1.Fiscal_Year_FY__c = '2021';
        parentRecord1.Period__c = '1st Half Year';
        parentRecord1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        parentRecord1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        parentRecord1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Master');
        parentRecord1.Distributor_Account__c = customerLocation.Id;
        insert parentRecord1;
        Business_Strategy__c subParent1 = new Business_Strategy__c();
        subParent1.Name = 'testtsub1';
        subParent1.Fiscal_Year_FY__c = '2021';
        subParent1.Period__c = '1st Half Year';
        subParent1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        subParent1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        subParent1.Parent_Business_Strategy__c = parentRecord1.Id;
        subParent1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Account_Plan');
        insert subParent1;
        Field_of_Play__c childRec1 = new Field_of_Play__c();
        childRec1.Customer_location__c = customerLocation.ID;
        childRec1.Distributor_Business_Strategy__c = subParent1.Id;
         childRec1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        insert childRec1;
        test.setCreatedDate(childRec1.Id,date.newInstance(2020, 11, 1));
       childRec1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update childRec1;
        
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
        parentRecord1.Fiscal_Year_FY__c = '2021';
        parentRecord1.Period__c = '1st Half Year';
        parentRecord1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        parentRecord1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        parentRecord1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Master');
        parentRecord1.Distributor_Account__c = customerLocation.Id;
        insert parentRecord1;
        Business_Strategy__c subParent1 = new Business_Strategy__c();
        subParent1.Name = 'testtsub1';
        subParent1.Fiscal_Year_FY__c = '2021';
        subParent1.Period__c = '1st Half Year';
        subParent1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        subParent1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        subParent1.Parent_Business_Strategy__c = parentRecord1.Id;
        subParent1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Account_Plan');
        insert subParent1;
        Field_of_Play__c childRec1 = new Field_of_Play__c();
        childRec1.Customer_location__c = customerLocation.ID;
        childRec1.Distributor_Business_Strategy__c = subParent1.Id;
         childRec1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        insert childRec1;
        Field_of_Play__c childRec2 = new Field_of_Play__c();
        childRec2.Customer_location__c = customerLocation.ID;
        childRec2.Distributor_Business_Strategy__c = subParent1.Id;
         childRec2.Confirmed_by_FCI_Sales_Manager__c = 'No';
        insert childRec2;
       childRec1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        //test.setCreatedDate(childRec1.Id, date.newInstance(2020, 11, 1));
        update childRec1;
        
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
        parentRecord1.Fiscal_Year_FY__c = '2021';
        parentRecord1.Period__c = '1st Half Year';
        parentRecord1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        parentRecord1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        parentRecord1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Master');
        parentRecord1.Distributor_Account__c = customerLocation.Id;
        insert parentRecord1;
        Business_Strategy__c subParent1 = new Business_Strategy__c();
        subParent1.Name = 'testtsub1';
        subParent1.Fiscal_Year_FY__c = '2021';
        subParent1.Period__c = '1st Half Year';
        subParent1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        subParent1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        subParent1.Parent_Business_Strategy__c = parentRecord1.Id;
        subParent1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Account_Plan');
        insert subParent1;
        Field_of_Play__c childRec1 = new Field_of_Play__c();
        childRec1.Customer_location__c = customerLocation.ID;
        childRec1.Distributor_Business_Strategy__c = subParent1.Id;
         childRec1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        insert childRec1;
        test.setCreatedDate(childRec1.Id,date.newInstance(2020, 10, 1));
       childRec1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update childRec1;
        
    }
    
     @isTest
    public static void test4(){
         set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Business_Strategy_Master');
        recordTypeDevNameSet.add('Business_Strategy_Account_Plan');
       
        
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
        parentRecord1.Fiscal_Year_FY__c = '2021';
        parentRecord1.Weight__c = 1;
        parentRecord1.Score__c = 1;
        parentRecord1.Period__c = '1st Half Year';
        parentRecord1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        parentRecord1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        parentRecord1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Master');
        parentRecord1.Distributor_Account__c = customerLocation.Id;
        insert parentRecord1;
        Business_Strategy__c subParent1 = new Business_Strategy__c();
        subParent1.Name = 'testtsub1';
        subParent1.Fiscal_Year_FY__c = '2021';
        subParent1.Weight__c = 3;
        subParent1.Score__c = 3;
        subParent1.Period__c = '1st Half Year';
        subParent1.Period_Start_Date__c = date.newInstance(2021, 1, 1);
        subParent1.Period_End_Date__c = date.newInstance(2021, 12, 31);
        subParent1.Parent_Business_Strategy__c = parentRecord1.Id;
        subParent1.RecordTypeId = reccordTypeNameMap.get('Business_Strategy_Account_Plan');
        insert subParent1;
        Field_of_Play__c childRec1 = new Field_of_Play__c();
        childRec1.Customer_location__c = customerLocation.ID;
        childRec1.Distributor_Business_Strategy__c = subParent1.Id;
         childRec1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        insert childRec1;
        test.setCreatedDate(childRec1.Id,date.newInstance(2020, 11, 1));
       childRec1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update childRec1;
        
    }
    
    
}