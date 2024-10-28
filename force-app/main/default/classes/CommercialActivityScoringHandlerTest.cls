@isTest
public class CommercialActivityScoringHandlerTest {

    @isTest
    public static void test1(){
        set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Commercial_Activity_Master');
        recordTypeDevNameSet.add('Commercial_Activity_Promotion_Activities');
        recordTypeDevNameSet.add('Promotion_Activity');
        recordTypeDevNameSet.add('Commercial_Activity_Customer_Visits');
        recordTypeDevNameSet.add('Customer_Visit');
        recordTypeDevNameSet.add('Commercial_Activity_Samples');
        recordTypeDevNameSet.add('Samples');
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
        Commercial_Activity__c comActParent = new Commercial_Activity__c();
        comActParent.Name = 'testing';
        comActParent.Fiscal_Year_FY__c = '2020';
        comActParent.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        comActParent.Period_End_Date__c = date.newInstance(2020, 12, 31);
        comActParent.Distributor_Account__c = customerLocation.Id;
        comActParent.Period__c = '1st Half Year';
        comActParent.RecordTypeId = reccordTypeNameMap.get('Commercial_Activity_Master');
        insert comActParent;
        Commercial_Activity__c childCommAct = new Commercial_Activity__c(); 
        childCommAct.Name = 'testing';
        childCommAct.Fiscal_Year_FY__c = '2020';
        childCommAct.Period__c = '1st Half Year';
        childCommAct.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        childCommAct.Period_End_Date__c = date.newInstance(2020, 12, 31);
        childCommAct.RecordTypeId = reccordTypeNameMap.get('Commercial_Activity_Promotion_Activities');
        childCommAct.Parent_Commercial_Activity__c = comActParent.Id;
        insert childCommAct;
        List<Commercial_Activity__c> grandChildList = new List<Commercial_Activity__c>();
        List<Commercial_Activity__c> grandChildListUpdate = new List<Commercial_Activity__c>();
        Commercial_Activity__c grandChildCommAct = new Commercial_Activity__c();
        grandChildCommAct.Name = 'testing grandchild';
        grandChildCommAct.Fiscal_Year_FY__c = '2020';
        grandChildCommAct.Period__c = '1st Half Year';
        grandChildCommAct.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct.RecordTypeId = reccordTypeNameMap.get('Promotion_Activity');
        grandChildCommAct.Commercial_Activity_Promotion_Activity__c = childCommAct.Id;
        grandChildList.add(grandChildCommAct);
         Commercial_Activity__c grandChildCommAct2 = new Commercial_Activity__c();
        grandChildCommAct2.Name = 'testing grandchild';
        grandChildCommAct2.Fiscal_Year_FY__c = '2020';
        grandChildCommAct2.Period__c = '1st Half Year';
        grandChildCommAct2.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct2.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct2.RecordTypeId = reccordTypeNameMap.get('Promotion_Activity');
        grandChildCommAct2.Commercial_Activity_Promotion_Activity__c = childCommAct.Id;
        grandChildCommAct2.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        grandChildList.add(grandChildCommAct2);
        Commercial_Activity__c grandChildCommAct3 = new Commercial_Activity__c();
        grandChildCommAct3.Name = 'testing grandchild';
        grandChildCommAct3.Fiscal_Year_FY__c = '2020';
        grandChildCommAct3.Period__c = '1st Half Year';
        grandChildCommAct3.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct3.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct3.RecordTypeId = reccordTypeNameMap.get('Promotion_Activity');
        grandChildCommAct3.Commercial_Activity_Promotion_Activity__c = childCommAct.Id;
        grandChildCommAct3.Confirmed_by_FCI_Sales_Manager__c = 'No';
        grandChildList.add(grandChildCommAct3);
        insert grandChildList;
        grandChildCommAct.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        grandChildCommAct2.Confirmed_by_FCI_Sales_Manager__c = 'No';
        grandChildListUpdate.add(grandChildCommAct);
        grandChildListUpdate.add(grandChildCommAct2);
        Test.startTest();
        update grandChildListUpdate;
        try{
           delete grandChildCommAct2;
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('You cannot delete KPI records'));
        }
        Test.stopTest();
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
        Commercial_Activity__c comActParent = new Commercial_Activity__c();
        comActParent.Name = 'testing';
        comActParent.Fiscal_Year_FY__c = '2020';
        comActParent.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        comActParent.Period_End_Date__c = date.newInstance(2020, 12, 31);
        comActParent.Distributor_Account__c = customerLocation.Id;
        comActParent.Period__c = '1st Half Year';
        comActParent.RecordTypeId = reccordTypeNameMap.get('Commercial_Activity_Master');
        insert comActParent;
        Commercial_Activity__c childCommAct = new Commercial_Activity__c(); 
        childCommAct.Name = 'testing';
        childCommAct.Fiscal_Year_FY__c = '2020';
        childCommAct.Period__c = '1st Half Year';
        childCommAct.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        childCommAct.Period_End_Date__c = date.newInstance(2020, 12, 31);
        childCommAct.RecordTypeId = reccordTypeNameMap.get('Commercial_Activity_Customer_Visits');
        childCommAct.Parent_Commercial_Activity__c = comActParent.Id;
        insert childCommAct;
        List<Commercial_Activity__c> grandChildList = new List<Commercial_Activity__c>();
        List<Commercial_Activity__c> grandChildListUpdate = new List<Commercial_Activity__c>();
        Commercial_Activity__c grandChildCommAct = new Commercial_Activity__c();
        grandChildCommAct.Name = 'testing grandchild';
        grandChildCommAct.Fiscal_Year_FY__c = '2020';
        grandChildCommAct.Period__c = '1st Half Year';
        grandChildCommAct.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct.RecordTypeId = reccordTypeNameMap.get('Customer_Visit');
        grandChildCommAct.Commercial_Activity_Customer_Visit__c = childCommAct.Id;
        grandChildList.add(grandChildCommAct);
         Commercial_Activity__c grandChildCommAct2 = new Commercial_Activity__c();
        grandChildCommAct2.Name = 'testing grandchild';
        grandChildCommAct2.Fiscal_Year_FY__c = '2020';
        grandChildCommAct2.Period__c = '1st Half Year';
        grandChildCommAct2.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct2.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct2.RecordTypeId = reccordTypeNameMap.get('Customer_Visit');
        grandChildCommAct2.Commercial_Activity_Customer_Visit__c = childCommAct.Id;
        grandChildCommAct2.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        grandChildList.add(grandChildCommAct2);
        Commercial_Activity__c grandChildCommAct3 = new Commercial_Activity__c();
        grandChildCommAct3.Name = 'testing grandchild';
        grandChildCommAct3.Fiscal_Year_FY__c = '2020';
        grandChildCommAct3.Period__c = '1st Half Year';
        grandChildCommAct3.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct3.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct3.RecordTypeId = reccordTypeNameMap.get('Customer_Visit');
        grandChildCommAct3.Commercial_Activity_Customer_Visit__c = childCommAct.Id;
        grandChildCommAct3.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        grandChildList.add(grandChildCommAct3);
        insert grandChildList;
        grandChildCommAct.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        grandChildCommAct2.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        grandChildListUpdate.add(grandChildCommAct);
        grandChildListUpdate.add(grandChildCommAct2);
        Test.startTest();
        update grandChildListUpdate;
        try{
           delete grandChildCommAct2;
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('You cannot delete KPI records'));
        }
        Test.stopTest();
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
        Commercial_Activity__c comActParent = new Commercial_Activity__c();
        comActParent.Name = 'testing';
        comActParent.Fiscal_Year_FY__c = '2020';
        comActParent.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        comActParent.Period_End_Date__c = date.newInstance(2020, 12, 31);
        comActParent.Distributor_Account__c = customerLocation.Id;
        comActParent.Period__c = '1st Half Year';
        comActParent.RecordTypeId = reccordTypeNameMap.get('Commercial_Activity_Master');
        insert comActParent;
        Commercial_Activity__c childCommAct = new Commercial_Activity__c(); 
        childCommAct.Name = 'testing';
        childCommAct.Fiscal_Year_FY__c = '2020';
        childCommAct.Period__c = '1st Half Year';
        childCommAct.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        childCommAct.Period_End_Date__c = date.newInstance(2020, 12, 31);
        childCommAct.RecordTypeId = reccordTypeNameMap.get('Commercial_Activity_Samples');
        childCommAct.Parent_Commercial_Activity__c = comActParent.Id;
        insert childCommAct;
        List<Commercial_Activity__c> grandChildList = new List<Commercial_Activity__c>();
        List<Commercial_Activity__c> grandChildListUpdate = new List<Commercial_Activity__c>();
        Commercial_Activity__c grandChildCommAct = new Commercial_Activity__c();
        grandChildCommAct.Name = 'testing grandchild';
        grandChildCommAct.Fiscal_Year_FY__c = '2020';
        grandChildCommAct.Period__c = '1st Half Year';
        grandChildCommAct.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct.RecordTypeId = reccordTypeNameMap.get('Samples');
        grandChildCommAct.Commercial_Activity_Sample__c = childCommAct.Id;
        grandChildList.add(grandChildCommAct);
         Commercial_Activity__c grandChildCommAct2 = new Commercial_Activity__c();
        grandChildCommAct2.Name = 'testing grandchild';
        grandChildCommAct2.Fiscal_Year_FY__c = '2020';
        grandChildCommAct2.Period__c = '1st Half Year';
        grandChildCommAct2.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct2.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct2.RecordTypeId = reccordTypeNameMap.get('Samples');
        grandChildCommAct2.Commercial_Activity_Sample__c = childCommAct.Id;
        grandChildCommAct2.Confirmed_by_FCI_Sales_Manager__c = 'No';
        grandChildList.add(grandChildCommAct2);
        Commercial_Activity__c grandChildCommAct3 = new Commercial_Activity__c();
        grandChildCommAct3.Name = 'testing grandchild';
        grandChildCommAct3.Fiscal_Year_FY__c = '2020';
        grandChildCommAct3.Period__c = '1st Half Year';
        grandChildCommAct3.Period_Start_Date__c = date.newInstance(2020, 1, 1);
        grandChildCommAct3.Period_End_Date__c = date.newInstance(2020, 12, 31);
        grandChildCommAct3.RecordTypeId = reccordTypeNameMap.get('Samples');
        grandChildCommAct3.Commercial_Activity_Sample__c = childCommAct.Id;
        grandChildCommAct3.Confirmed_by_FCI_Sales_Manager__c = 'No';
        grandChildList.add(grandChildCommAct3);
        insert grandChildList;
        grandChildCommAct.Confirmed_by_FCI_Sales_Manager__c = 'No';
        grandChildCommAct2.Confirmed_by_FCI_Sales_Manager__c = 'No';
        grandChildListUpdate.add(grandChildCommAct);
        grandChildListUpdate.add(grandChildCommAct2);
        Test.startTest();
        update grandChildListUpdate;
        childCommAct.Parent_Commercial_Activity__c  = null;
        Update childCommAct;
        delete childCommAct;
        try{
           delete grandChildCommAct2;
        }
        catch (Exception e){           
        }
        Test.stopTest();
    }
}