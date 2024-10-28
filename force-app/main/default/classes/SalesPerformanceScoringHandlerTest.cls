@isTest
public class SalesPerformanceScoringHandlerTest {

    @isTest
    public static void test1(){
        set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Partner_Opportunity');
        recordTypeDevNameSet.add('Sales_Funnel_Master');
        recordTypeDevNameSet.add('Sales_Funnel_Distributor_Sales_To_End_Customer');
        recordTypeDevNameSet.add('Distributor_Sales_To_End_Customer');
       recordTypeDevNameSet.add('Sales_Funnel_Distributor_New_Business');
        
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE DeveloperName IN : recordTypeDevNameSet]; 
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
       
        Test.startTest();
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        customerLocation.Active__c=true;
        customerLocation.Partner_Role__c='Sold-to';
        insert customerLocation;
        Field_of_Play__c accountPlan = new Field_of_Play__c();
        accountPlan.Account__c = customerLocation.Id;
        accountPlan.Distributor_Location__c = customerLocation.Name;
        insert accountPlan;
        Share_of_Wallet__c shareWallet = new Share_of_Wallet__c();
        shareWallet.Distributor_Volume_in_mT__c = 2000;
        shareWallet.FCI_Budget_Volume_in_mT__c = 100;
        shareWallet.Field_of_Play__c = accountPlan.Id;
        insert shareWallet;
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'testopp1';
        opp1.StageName = 'Closed Won';
        opp1.TotalOpportunityQuantity = 100;
        opp1.AccountId = customerLocation.Id;
        opp1.Parent_Account__c = accountH1.Id;
        //opp1.Location__c = customerLocation.Id;
        opp1.Details_Reason_Won_Lost__c = 'test';
        opp1.Reason_Won_Lost__c = 'Best price offer';
        opp1.CloseDate = date.newInstance(system.today().year(), 2, 1);
        opp1.RecordTypeId = reccordTypeNameMap.get('Partner_Opportunity');
        insert opp1;
        Sales_Funnel__c parentRecord = new Sales_Funnel__c();
        parentRecord.Name = 'test parent';
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Master');
        insert parentRecord;
        Sales_Funnel__c subParent = new Sales_Funnel__c();
        subParent.Name = 'test parent';
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Parent_Sales_Funnel__c = parentRecord.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Distributor_New_Business');
        insert subParent;        
        update subParent;
        Test.stopTest();
    }
    
    @isTest
    public static void test22(){
        set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Partner_Opportunity');
        recordTypeDevNameSet.add('Sales_Funnel_Master');
        recordTypeDevNameSet.add('Sales_Funnel_Distributor_Sales_To_End_Customer');
        recordTypeDevNameSet.add('Distributor_Sales_To_End_Customer');
       recordTypeDevNameSet.add('Sales_Funnel_Distributor_New_Business');
        
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE DeveloperName IN : recordTypeDevNameSet]; 
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
       
        Test.startTest();
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        accountH1.Active__c=true;
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        customerLocation.Active__c=true;
        customerLocation.Partner_Role__c='Sold-to';
        insert customerLocation;
        Field_of_Play__c accountPlan = new Field_of_Play__c();
        accountPlan.Account__c = customerLocation.Id;
        accountPlan.Distributor_Location__c = customerLocation.Name;
        insert accountPlan;
        Share_of_Wallet__c shareWallet = new Share_of_Wallet__c();
        shareWallet.Distributor_Volume_in_mT__c = 2000;
        shareWallet.FCI_Budget_Volume_in_mT__c = 727100;
        shareWallet.Field_of_Play__c = accountPlan.Id;
        insert shareWallet;
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'testopp1';
        opp1.StageName = 'Closed Won';
        opp1.TotalOpportunityQuantity = 100;
        opp1.AccountId = customerLocation.Id;
        opp1.Parent_Account__c = accountH1.Id;
        //opp1.Location__c = customerLocation.Id;
        opp1.Details_Reason_Won_Lost__c = 'test';
        opp1.Reason_Won_Lost__c = 'Best price offer';
        opp1.CloseDate = date.newInstance(system.today().year(), 2, 1);
        opp1.RecordTypeId = reccordTypeNameMap.get('Partner_Opportunity');
        insert opp1;
        Sales_Funnel__c parentRecord = new Sales_Funnel__c();
        parentRecord.Name = 'test parent';
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Master');
        insert parentRecord;
        Sales_Funnel__c subParent = new Sales_Funnel__c();
        subParent.Name = 'test parent';
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Parent_Sales_Funnel__c = parentRecord.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Distributor_New_Business');
        insert subParent;
        
        update subParent;
        Test.stopTest();
    }
    
     @isTest
    public static void test23(){
        set<String> recordTypeDevNameSet = new set<String>();
        recordTypeDevNameSet.add('BGI_Commercial_Customer');
        recordTypeDevNameSet.add('BGI_Customer_Location');
        recordTypeDevNameSet.add('Partner_Opportunity');
        recordTypeDevNameSet.add('Sales_Funnel_Master');
        recordTypeDevNameSet.add('Sales_Funnel_Distributor_Sales_To_End_Customer');
        recordTypeDevNameSet.add('Distributor_Sales_To_End_Customer');
       recordTypeDevNameSet.add('Sales_Funnel_Distributor_New_Business');
        
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE DeveloperName IN : recordTypeDevNameSet]; 
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
       
        Test.startTest();
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        accountH1.Active__c=true;
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        customerLocation.Active__c=true;
        customerLocation.Partner_Role__c='Sold-to';
        insert customerLocation;
        Field_of_Play__c accountPlan = new Field_of_Play__c();
        accountPlan.Account__c = customerLocation.Id;
        accountPlan.Distributor_Location__c = customerLocation.Name;
        insert accountPlan;
        Share_of_Wallet__c shareWallet = new Share_of_Wallet__c();
        shareWallet.Distributor_Volume_in_mT__c = 2000;
        shareWallet.FCI_Budget_Volume_in_mT__c = 5000;
        shareWallet.Field_of_Play__c = accountPlan.Id;
        insert shareWallet;
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'testopp1';
        opp1.StageName = 'Closed Won';
        opp1.TotalOpportunityQuantity = 100;
        opp1.AccountId = customerLocation.Id;
        opp1.Parent_Account__c = accountH1.Id;
        //opp1.Location__c = customerLocation.Id;
        opp1.Details_Reason_Won_Lost__c = 'test';
        opp1.Reason_Won_Lost__c = 'Best price offer';
        opp1.CloseDate = date.newInstance(system.today().year(), 2, 1);
        opp1.RecordTypeId = reccordTypeNameMap.get('Partner_Opportunity');
        insert opp1;
        Sales_Funnel__c parentRecord = new Sales_Funnel__c();
        parentRecord.Name = 'test parent';
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Master');
        insert parentRecord;
        Sales_Funnel__c subParent = new Sales_Funnel__c();
        subParent.Name = 'test parent';
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Parent_Sales_Funnel__c = parentRecord.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Distributor_New_Business');
        insert subParent;
        
        update subParent;
        Test.stopTest();
    }

    
    @isTest
    public static void test2(){
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType];
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
       
        Test.startTest();
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        accountH1.Active__c=true;
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
        customerLocation.Active__c=true;
        customerLocation.Partner_Role__c='Sold-to';
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
   
        Sales_Funnel__c parentRecord = new Sales_Funnel__c();
        parentRecord.Name = 'test parent';
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Master');
        insert parentRecord;
        Sales_Funnel__c subParent = new Sales_Funnel__c();
        subParent.Name = 'test parent';
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Parent_Sales_Funnel__c = parentRecord.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Distributor_Sales_To_End_Customer');
        insert subParent;
        
         Sales_Funnel__c childRecord1 = new Sales_Funnel__c();
        childRecord1.Name = 'test child1';
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Sales_Funnel_Sales_To_End_Customer__c = subParent.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Distributor_Sales_To_End_Customer');
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        insert childRecord1;
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update childRecord1;
        try{
           delete childRecord1; 
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('You cannot delete KPI records'));
        }
        test.stopTest();
    }
    
    @isTest
    public static void test3(){
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType];
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
       
        Test.startTest();
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
          accountH1.Active__c=true;
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
          customerLocation.Active__c=true;
        customerLocation.Partner_Role__c='Sold-to';
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
   
        Sales_Funnel__c parentRecord = new Sales_Funnel__c();
        parentRecord.Name = 'test parent';
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Master');
        insert parentRecord;
        Sales_Funnel__c subParent = new Sales_Funnel__c();
        subParent.Name = 'test parent';
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Parent_Sales_Funnel__c = parentRecord.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Distributor_Sales_To_End_Customer');
        insert subParent;
        
         List<Sales_Funnel__c> chidlRecordList = new List<Sales_Funnel__c>();
          Sales_Funnel__c childRecord1 = new Sales_Funnel__c();
        childRecord1.Name = 'test child1';
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Sales_Funnel_Sales_To_End_Customer__c = subParent.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Distributor_Sales_To_End_Customer');
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        Sales_Funnel__c childRecord2 = new Sales_Funnel__c();
        childRecord2.Name = 'test child2';
        childRecord2.Distributor_Account__c = customerLocation.Id;
        childRecord2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord2.Period__c = '1st Half Year';
        childRecord2.Sales_Funnel_Sales_To_End_Customer__c = subParent.Id;
        childRecord2.RecordTypeId = reccordTypeNameMap.get('Distributor_Sales_To_End_Customer');
        childRecord2.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
       chidlRecordList.add(childRecord1);
        chidlRecordList.add(childRecord2);
        insert chidlRecordList;
      childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        update childRecord1;
        test.stopTest();        
    }
    
     @isTest
    public static void test4(){
        List<RecordType> recordTypeList = [SELECT Id,Name,DeveloperName FROM RecordType];
        Map<String,Id> reccordTypeNameMap = new Map<String,Id>();
        for(RecordType recType : recordTypeList){
            reccordTypeNameMap.put(recType.DeveloperName,recType.Id);
        }
       
        Test.startTest();
        Account accountH1 = new Account();
        accountH1.Name = 'testh1 account';
         accountH1.Active__c=true;
     
        accountH1.RecordTypeId = reccordTypeNameMap.get('BGI_Commercial_Customer');
        insert accountH1;
        Account customerLocation = new Account();
        customerLocation.Name = 'test location';
        customerLocation.ParentId = accountH1.ID;
         customerLocation.Active__c=true;
        customerLocation.Partner_Role__c='Sold-to';
        customerLocation.RecordTypeId = reccordTypeNameMap.get('BGI_Customer_Location');
        insert customerLocation;
   
        Sales_Funnel__c parentRecord = new Sales_Funnel__c();
        parentRecord.Name = 'test parent';
        parentRecord.Distributor_Account__c = customerLocation.Id;
        parentRecord.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        parentRecord.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        parentRecord.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        parentRecord.Period__c = '1st Half Year';
        parentRecord.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Master');
        insert parentRecord;
        Sales_Funnel__c subParent = new Sales_Funnel__c();
        subParent.Name = 'test parent';
        subParent.Distributor_Account__c = customerLocation.Id;
        subParent.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        subParent.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        subParent.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        subParent.Period__c = '1st Half Year';
        subParent.Parent_Sales_Funnel__c = parentRecord.Id;
        subParent.RecordTypeId = reccordTypeNameMap.get('Sales_Funnel_Distributor_Sales_To_End_Customer');
        insert subParent;
        
         List<Sales_Funnel__c> chidlRecordList = new List<Sales_Funnel__c>();
          Sales_Funnel__c childRecord1 = new Sales_Funnel__c();
        childRecord1.Name = 'test child1';
        childRecord1.Distributor_Account__c = customerLocation.Id;
        childRecord1.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord1.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord1.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord1.Period__c = '1st Half Year';
        childRecord1.Sales_Funnel_Sales_To_End_Customer__c = subParent.Id;
        childRecord1.RecordTypeId = reccordTypeNameMap.get('Distributor_Sales_To_End_Customer');
        childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        Sales_Funnel__c childRecord2 = new Sales_Funnel__c();
        childRecord2.Name = 'test child2';
        childRecord2.Distributor_Account__c = customerLocation.Id;
        childRecord2.Period_Start_Date__c = date.newInstance(system.today().year(), 1, 1);
        childRecord2.Period_End_Date__c = date.newInstance(system.today().year(), 12, 31);
        childRecord2.Fiscal_Year_FY__c = String.valueOf(system.today().year());
        childRecord2.Period__c = '1st Half Year';
        childRecord2.Sales_Funnel_Sales_To_End_Customer__c = subParent.Id;
        childRecord2.RecordTypeId = reccordTypeNameMap.get('Distributor_Sales_To_End_Customer');
        childRecord2.Confirmed_by_FCI_Sales_Manager__c = 'No';
       chidlRecordList.add(childRecord1);
        chidlRecordList.add(childRecord2);
        insert chidlRecordList;
      childRecord1.Confirmed_by_FCI_Sales_Manager__c = 'No';
        update childRecord1;
        subParent.Parent_Sales_Funnel__c = null;
        Update subParent;
        Delete subParent;
        test.stopTest();        
    }
}