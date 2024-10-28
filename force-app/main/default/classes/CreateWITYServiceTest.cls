@isTest
public class CreateWITYServiceTest {
    
    @testSetup
    static void setup(){
        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);
        insert accsCustomLocToInsert;
        
        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        accsToInsert.add(customerLocItaly);
        insert accsToInsert;
        
        Visit_report__c visitRec = TestUtility.getVisitReportInstance(commercialCust,customerLocItaly);
        visitRec.Business_Segment__c = 'Adult Nutrition';
        insert visitRec;
        
        Key_Buying_factors__c keyBuy = TestUtility.getWITYKeyBuyingInstance(visitRec);
        insert keyBuy;
        
        List<WITY_Scoring__c> WityScoringList = new List<WITY_Scoring__c>();
        WITY_Scoring__c wityscor1 = TestUtility.getWITYScoringInstance(keyBuy,'WITYTest',1,2);
        WityScoringList.add(wityscor1);
        
        WITY_Scoring__c wityscor2 = TestUtility.getWITYScoringInstance(keyBuy,'Friesland test',2,3);
        WityScoringList.add(wityscor2);
        
        WITY_Scoring__c wityscor3 = TestUtility.getWITYScoringInstance(keyBuy,'VIsit Test',3,4);
        WityScoringList.add(wityscor3);
        
        WITY_Scoring__c wityscor4 = TestUtility.getWITYScoringInstance(keyBuy,'Key Buying Test',4,4);
        WityScoringList.add(wityscor4);
        
        insert WityScoringList;
    }
    
    @isTest
    static void getInitTest(){
        List<CreateWITYService.VisitReportWrapper> wraplist = CreateWITYService.getDataOnInit();
        //System.assertEquals(25, wraplist.size());
    }
    
    @isTest
    static void getEditInitTest(){
        Key_Buying_factors__c keyBuy = [SELECT Id FROM Key_Buying_factors__c];
        List<CreateWITYService.VisitReportWrapper> wityScorList = CreateWITYService.getEditDataOnInit(keyBuy.Id);
        System.assertEquals(4, wityScorList.size());
    }
    
    @isTest
    static void getVisitDataTest(){
        Key_Buying_factors__c keyBuy = [SELECT Id FROM Key_Buying_factors__c];
        
        Visit_report__c visitRep = [SELECT Id,Name,Visit_Date__c FROM Visit_report__c];
        
        CreateWITYService.VisitDataWrapper vWrapper = CreateWITYService.getVisitDataWrapper(keyBuy.Id);
        System.assertEquals(visitRep.Name, vWrapper.visitName);
        System.assertEquals(visitRep.Visit_Date__c, vWrapper.visitDate);
        System.assertEquals(visitRep.Id, vWrapper.visitId);
    }
    
    @isTest 
    static void getWityDetailsTest(){
        Key_Buying_factors__c keyBuy = [SELECT Id FROM Key_Buying_factors__c];
        List<WITY_Scoring__c> wityList = CreateWITYService.getWityDetails(keyBuy.Id);
        System.assertEquals(4, wityList.size());
    }
    
    @isTest
    static void getVisitReportWityRelatedDataTest(){
        Visit_Report__c visitReportRecord = [SELECT Id FROM Visit_Report__c];
        List<CreateWITYService.VisitReportWrapper> wityScorList = CreateWITYService.getVisitReportWityRelatedData(visitReportRecord.Id);
        System.assertEquals(4, wityScorList.size());
    }
    
    @isTest
    static void saveRecordsTest(){
        String recordList = '[';
        recordList = recordList + '{"checkbox":true,"quesName":"Innovation/NPD Support","recId":"m040E000000DN40QAG","index":"0","readOnly":false,"quesReadOnly":true,"ratingone":"4","ratingtwo":"3","comments":"Test 1"},';
        recordList = recordList + '{"checkbox":true,"quesName":"Volume Flexibility","recId":"m040E000000DN5IQAW","index":"1","readOnly":false,"quesReadOnly":true,"ratingone":"1","ratingtwo":"1","comments":"Test 2"},';
        recordList = recordList + '{"checkbox":false,"quesName":"Payment Conditions","recId":"m040E000000DN5SQAW","index":"2","readOnly":true,"quesReadOnly":true}';
        recordList = recordList + ']';
        Visit_report__c visitRep = [SELECT Id,Name,Visit_Date__c FROM Visit_report__c];
        
        CreateWITYService.saveRecords(recordList,visitRep.Id);
        System.assertEquals(6, [SELECT Id FROM WITY_Scoring__c].size());
    }

    @isTest
    static void upsertRecordsTest(){
        //B2B144
        Account acc = New Account();
        acc.Name = 'Test FCP';
        acc.BillingCity = 'SHANNON AIRPORT';
        acc.BillingCountry ='Ireland';
        Insert acc;
        Field_of_Play__c accPlan = New Field_of_Play__c();
        Insert accPlan;
        Visit_Report__c visitReport = New Visit_Report__c();
        visitReport.Customer_Name__c = acc.id;
        visitReport.Purpose_of_the_Visit__c  ='Other';
        visitReport.Business_Segment__c ='Industry';
        String recordList = '[';
        recordList = recordList + '{"checkbox":true,"quesName":"Innovation/NPD Support","recId":"","index":"0","readOnly":false,"quesReadOnly":true,"ratingone":"4","ratingtwo":"3","comments":"Test 1"},';
        recordList = recordList + '{"checkbox":true,"quesName":"Volume Flexibility","recId":"","index":"1","readOnly":false,"quesReadOnly":true,"ratingone":"1","ratingtwo":"1","comments":"Test 2"},';
        recordList = recordList + '{"checkbox":false,"quesName":"Payment Conditions","recId":"","index":"2","readOnly":true,"quesReadOnly":true}';
        recordList = recordList + ']';
        Visit_report__c visitRep = [SELECT Id,Name,Visit_Date__c FROM Visit_report__c];
        String curOppStage = 'Development';//B2B173
        CreateWITYService.upsertRecords(recordList,visitRep.Id, accPlan.id,curOppStage);
        CreateWITYService.getRecordTypeName(accPlan.id);
        //B2B144
        System.assertEquals(7, [SELECT Id FROM WITY_Scoring__c].size());
    }
    
    @isTest
    static void saveEditRecordsTest(){
        List<WITY_Scoring__c> wityList = [SELECT Id,Question_Name__c,Rating_One__c,Rating_Two__c,comments__c FROM WITY_Scoring__c];
        WITY_Scoring__c wScr = [SELECT Id,Question_Name__c,Rating_One__c,Rating_Two__c,comments__c from WITY_Scoring__C where question_Name__c = 'WITYTest'];
        
        String recordList = '[';
        recordList = recordList + '{"checkbox":true,"quesName":"Innovation/NPD Support","recId":"'+ wScr.Id +'","index":"0","readOnly":false,"quesReadOnly":true,"ratingone":"4","ratingtwo":"3","comments":"Test 1"},';
        recordList = recordList + '{"checkbox":false,"quesName":"Volume Flexibility","recId":null,"index":"1","readOnly":false,"quesReadOnly":true,"ratingone":"1","ratingtwo":"1","comments":"Test 2"},';
        recordList = recordList + '{"readOnly":false,"quesReadOnly":false,"index":7,"quesName":"hello","ratingone":"1","ratingtwo":"2","checkbox":true,"comments":"test"}';
        recordList = recordList + ']';
        
        Key_Buying_factors__c keyBuy = [Select Id from Key_Buying_factors__c];
        
        Test.startTest();
        CreateWITYService.saveEditRecord(keyBuy.Id, recordList);
        Test.stopTest();

        WITY_Scoring__c wScr1 = [SELECT Id,Question_Name__c,Rating_One__c,Rating_Two__c,comments__c from WITY_Scoring__C where Id =: wScr.Id];

        System.assertEquals('Innovation/NPD Support', wScr1.question_name__c);
        System.assertEquals(4, wScr1.Rating_One__c);
        System.assertEquals(3, wScr1.Rating_Two__c);
        System.assertEquals('Test 1', wScr1.comments__c);
        System.assertEquals(5, [SELECT Id FROM WITY_Scoring__c].size());
    }

    @isTest
    static void deleteWityScoringRecordTest(){
		Field_of_Play__c accPlan = New Field_of_Play__c();
        Insert accPlan;//B2B144
        String recordList = '[';
        recordList = recordList + '{"checkbox":true,"quesName":"Innovation/NPD Support","recId":"","index":"0","readOnly":false,"quesReadOnly":true,"ratingone":"4","ratingtwo":"3","comments":"Test 1"},';
        recordList = recordList + '{"checkbox":true,"quesName":"Volume Flexibility","recId":"","index":"1","readOnly":false,"quesReadOnly":true,"ratingone":"1","ratingtwo":"1","comments":"Test 2"},';
        recordList = recordList + '{"checkbox":false,"quesName":"Payment Conditions","recId":"","index":"2","readOnly":true,"quesReadOnly":true}';
        recordList = recordList + ']';
        Visit_report__c visitRep = [SELECT Id,Name,Visit_Date__c FROM Visit_report__c];
        String curOppStage = 'Development';//B2B173
        CreateWITYService.upsertRecords(recordList,visitRep.Id, accPlan.id,curOppStage);//B2B144//B2B173
        List<CreateWITYService.VisitReportWrapper> wityScorList = CreateWITYService.getVisitReportWityRelatedData(visitRep.Id);
        CreateWITYService.deleteWityScoringRecord(wityScorList[0].recId);
        System.assertEquals(6, [SELECT Id FROM WITY_Scoring__c].size());
    }

    @isTest
    static void deleteWityScoringRecordsTest(){
		Field_of_Play__c accPlan = New Field_of_Play__c();
        Insert accPlan;//B2B144
        String recordList = '[';
        recordList = recordList + '{"checkbox":true,"quesName":"Innovation/NPD Support","recId":"","index":"0","readOnly":false,"quesReadOnly":true,"ratingone":"4","ratingtwo":"3","comments":"Test 1"},';
        recordList = recordList + '{"checkbox":true,"quesName":"Volume Flexibility","recId":"","index":"1","readOnly":false,"quesReadOnly":true,"ratingone":"1","ratingtwo":"1","comments":"Test 2"},';
        recordList = recordList + '{"checkbox":false,"quesName":"Payment Conditions","recId":"","index":"2","readOnly":true,"quesReadOnly":true}';
        recordList = recordList + ']';
        Visit_report__c visitRep = [SELECT Id,Name,Visit_Date__c FROM Visit_report__c];
        String curOppStage = 'Development';//B2B173
        CreateWITYService.upsertRecords(recordList,visitRep.Id, accPlan.id,curOppStage);//B2B144//B2B173
        List<CreateWITYService.VisitReportWrapper> wityScorList = CreateWITYService.getVisitReportWityRelatedData(visitRep.Id);
        List<String> wityScoringIds = new List<String>();
        for (CreateWITYService.VisitReportWrapper wityScor : wityScorList) {
            wityScoringIds.add(wityScor.recId);
        }
        CreateWITYService.deleteWityScoringRecords(wityScoringIds);
        System.assertEquals(0, [SELECT Id FROM WITY_Scoring__c].size());
        System.assertEquals(0, [SELECT Id FROM Key_Buying_Factors__c].size());
    }
    
    //B2B144
    @isTest
    static void WITYRecordsTest(){
        Account acc = New Account();
        acc.Name = 'Test FCP';
        acc.BillingCity = 'SHANNON AIRPORT';
        acc.BillingCountry ='Ireland';
        Insert acc; 
        Field_of_Play__c accPlan = New Field_of_Play__c();
        Insert accPlan;
        Visit_Report__c visitReport = New Visit_Report__c();
        visitReport.Customer_Name__c = acc.id;
        visitReport.Purpose_of_the_Visit__c  ='Other';
        visitReport.Business_Segment__c ='Industry';
        String searchTerm = 'a';
        String recordList = '[';
        recordList = recordList + '{"checkbox":true,"quesName":"Innovation/NPD Support","recId":"","index":"0","readOnly":false,"quesReadOnly":true,"ratingone":"4","ratingtwo":"3","comments":"Test 1"},';
        recordList = recordList + '{"checkbox":true,"quesName":"Volume Flexibility","recId":"","index":"1","readOnly":false,"quesReadOnly":true,"ratingone":"1","ratingtwo":"1","comments":"Test 2"},';
        recordList = recordList + '{"checkbox":false,"quesName":"Payment Conditions","recId":"","index":"2","readOnly":true,"quesReadOnly":true}';
        recordList = recordList + ']';
        Visit_report__c visitRep = [SELECT Id,Name,Visit_Date__c FROM Visit_report__c];
        String curOppStage = 'Development';//B2B173
        CreateWITYService.upsertRecords(recordList,visitRep.Id, accPlan.id,curOppStage);//B2B144//B2B173
        CreateWITYService.getWityAccPlanWityRelatedData(visitReport.id);
        CreateWITYService.getRecordTypeName(visitRep.id);
        CreateWITYService.getAccountPlans(searchTerm,visitRep.id);
        CreateWITYService.getVisitReportWityRelatedData(visitRep.id);
        System.assertEquals(7, [SELECT Id FROM WITY_Scoring__c].size());
    }
    //B2B144
    
    //B2B173
    @isTest
    static void WITYRecordsTest1(){
        Account acc = New Account();
        acc.Name = 'Test FCP';
        acc.BillingCity = 'SHANNON AIRPORT';
        acc.BillingCountry ='Ireland';
        Insert acc;
        Opportunity opp = New Opportunity();
        opp.Name = 'Test CK';
        opp.AccountId = acc.id;
        //opp.Business_Segment__c = 'Industry';
        opp.CloseDate = Date.today();
        opp.StageName ='Prospecting';
        opp.Probability = 10;
        Insert opp;
        Field_of_Play__c accPlan = New Field_of_Play__c();
        Insert accPlan;
        Visit_Report__c visitReport = New Visit_Report__c();
        visitReport.Customer_Name__c = acc.id;
        visitReport.Purpose_of_the_Visit__c  ='Other';
        visitReport.Business_Segment__c ='Industry';
        String searchTerm = 'a';
        String recordList = '[';
        recordList = recordList + '{"checkbox":true,"quesName":"Innovation/NPD Support","recId":"","index":"0","readOnly":false,"quesReadOnly":true,"ratingone":"4","ratingtwo":"3","comments":"Test 1"},';
        recordList = recordList + '{"checkbox":true,"quesName":"Volume Flexibility","recId":"","index":"1","readOnly":false,"quesReadOnly":true,"ratingone":"1","ratingtwo":"1","comments":"Test 2"},';
        recordList = recordList + '{"checkbox":false,"quesName":"Payment Conditions","recId":"","index":"2","readOnly":true,"quesReadOnly":true}';
        recordList = recordList + ']';
        Visit_report__c visitRep = [SELECT Id,Name,Visit_Date__c FROM Visit_report__c];
        String curOppStage = 'Development';
        CreateWITYService.upsertRecords(recordList,opp.Id, accPlan.id,curOppStage);
        CreateWITYService.getWityAccPlanWityRelatedData(opp.id);
        CreateWITYService.getRecordTypeName(opp.id);
        CreateWITYService.getVisitReportWityRelatedData(opp.id);
        CreateWITYService.getOpportunityStage(opp.id);
        CreateWITYService.getOppStageWITYData(opp.id);
        System.assertEquals(7, [SELECT Id FROM WITY_Scoring__c].size());
    }
    //B2B173

}