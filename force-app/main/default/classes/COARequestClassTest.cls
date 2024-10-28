@isTest
global class COARequestClassTest {
    
    @isTest
    private static void setup(){

        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);
        
        INSERT accsCustomLocToInsert;
        
        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        customerLocItaly.SAP_Number__c = '0000000001';
        accsToInsert.add(customerLocItaly);
        
        INSERT accsToInsert;
       
        Contract cont = new Contract();
        cont.Status='Draft';
        cont.Parent_Account__c = commercialCust.id;
        cont.AccountId = customerLocItaly.id;
        cont.StartDate = system.today();
        cont.EndDate = system.today()+1;
        INSERT cont;
        
        Pricebook2 priceBookObj = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );       
        UPDATE priceBookObj;

        List<Delivery__c> deliveryList = new List<Delivery__c>();
        Delivery__c delivery1  = new Delivery__c();
        delivery1.SAP_Delivery_Number__c='0800000001';
        delivery1.Sold_To__c=customerLocItaly.id;
        delivery1.Ship_To__c = customerLocItaly.id;
        deliveryList.add(delivery1);

        Delivery__c delivery2  = new Delivery__c();
        delivery2.SAP_Delivery_Number__c='0800000002';
        delivery2.Sold_To__c=customerLocItaly.id;
        delivery2.Ship_To__c = customerLocItaly.id;
        deliveryList.add(delivery2);
        INSERT deliveryList;
       

        Order ord = new Order();
        ord.Parent_Account__c = commercialCust.id;
        ord.AccountId =customerLocItaly.id;
        ord.SAP_Sales_Order_Number__c='SO00000001';
        ord.PoNumber ='PO0000001';
        ord.ContractId= cont.id;
        ord.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        ord.EffectiveDate = cont.EndDate;
        INSERT ord;
        
        List<Delivery_Line_Item__c> deliveryLineList = new List<Delivery_Line_Item__c>();
        Delivery_Line_Item__c dlit1 = new Delivery_Line_Item__c();
        dlit1.Delivery__c = delivery1.id;
        dlit1.SAP_Delivery_Item_Number__c = delivery1.SAP_Delivery_Number__c+'000010';
        dlit1.Sales_Order_number__c = ord.id;
        dlit1.Purchase_order_number__c = ord.PoNumber;
        deliveryLineList.add(dlit1);
        
        Delivery_Line_Item__c dlit2 = new Delivery_Line_Item__c();
        dlit2.Delivery__c = delivery1.id;
        dlit2.SAP_Delivery_Item_Number__c = delivery1.SAP_Delivery_Number__c+'000020';
        dlit2.Sales_Order_number__c = ord.id;
        dlit2.Purchase_order_number__c = ord.PoNumber;
        deliveryLineList.add(dlit2);

        Delivery_Line_Item__c dlit3 = new Delivery_Line_Item__c();
        dlit3.Delivery__c = delivery2.id;
        dlit3.SAP_Delivery_Item_Number__c = delivery2.SAP_Delivery_Number__c+'0000109000001';
        dlit3.Sales_Order_number__c = ord.id;
        dlit3.Purchase_order_number__c = ord.PoNumber;
        dlit3.SAP_Batch_Number__c = 'BATCH10-10';
        deliveryLineList.add(dlit3);

        Delivery_Line_Item__c dlit4 = new Delivery_Line_Item__c();
        dlit4.Delivery__c = delivery2.id;
        dlit4.SAP_Delivery_Item_Number__c = delivery2.SAP_Delivery_Number__c+'0000209000001';
        dlit4.Sales_Order_number__c = ord.id;
        dlit4.Purchase_order_number__c = ord.PoNumber;
        dlit4.SAP_Batch_Number__c = 'BATCH10-20';
        deliveryLineList.add(dlit4);
        INSERT deliveryLineList;
        
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';                  
        conVer.PathOnClient = 'testing.pdf';          
        conVer.Title = '1234';      
        conVer.VersionData = EncodingUtil.base64Decode('JVBERi0xLjYNJeLj');
        INSERT conVer;
    }
    
    @isTest
    private static void checkSuccessMockResponseForDelivery(){

        COARequestClass.contentUserInfo sapResponse;
       
 
        Tile__c correctDeliveryRequest1 = new Tile__c();
        correctDeliveryRequest1.Name = 'DELIVERY:0800000001';
        correctDeliveryRequest1.Delivery_Number__c ='0800000001'; //delivery1
        correctDeliveryRequest1.Sales_Order_Number__c ='';
        correctDeliveryRequest1.Purchase_Order_Number__c='';

        Tile__c deliveryNotInSF = new Tile__c();
        deliveryNotInSF.Name = 'DELIVERY:0900000001';
        deliveryNotInSF.Delivery_Number__c ='0900000001';   //delivery not in SF
        deliveryNotInSF.Sales_Order_Number__c ='';
        deliveryNotInSF.Purchase_Order_Number__c='';

        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"0800000001","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"0800000001","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYN","Type":"PDF"}}]}','Success',200));
        sapResponse = COARequestClass.callSAPCOAService(correctDeliveryRequest1, false,'Delivery Number'/*,QueueID*/);
        system.assertEquals('', sapResponse.errorInfo );
        System.assertEquals(1, sapResponse.contentTileMap.keySet().size() );
        System.assertEquals(1, sapResponse.contentTileMap.values().size() );

        Test.startTest();
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"0900000001","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYN","Type":"PDF"}},{"Delivery":"0900000001","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBExLjYNJeLj","Type":"PDF"}}]}','Success',200));
        sapResponse = COARequestClass.callSAPCOAService(deliveryNotInSF, true,'Delivery Number'/*,QueueID*/);
        system.assertEquals('', sapResponse.errorInfo );
        System.assertEquals(1, sapResponse.contentTileMap.keySet().size() );
        System.assertEquals(1, sapResponse.contentTileMap.values().size() );
        System.assertEquals('00000001', sapResponse.ShipToNo );
        
        Test.stopTest();

        
    }
    @isTest
    private static void checkSuccessMockResponseForBatch(){

        COARequestClass.contentUserInfo sapResponse;

        Tile__c entredCorrectMotherBatch = new Tile__c();
        entredCorrectMotherBatch.Name = 'BATCH:BATCH10';
        entredCorrectMotherBatch.Purchase_Order_Number__c ='';
        entredCorrectMotherBatch.Sales_Order_Number__c=''; //
        entredCorrectMotherBatch.Delivery_Number__c=''; 
        entredCorrectMotherBatch.Batch_Number__c = 'BATCH10'; 
        entredCorrectMotherBatch.ShipToParty__c = '0000000001';

        Tile__c entredCorrectChildBatch = new Tile__c();
        entredCorrectChildBatch.Name = 'BATCH:BATCH10-10';
        entredCorrectChildBatch.Purchase_Order_Number__c ='';
        entredCorrectChildBatch.Sales_Order_Number__c=''; //
        entredCorrectChildBatch.Delivery_Number__c=''; 
        entredCorrectChildBatch.Batch_Number__c = 'BATCH10-10'; 
        entredCorrectChildBatch.ShipToParty__c = '0000000002';

        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVjYNJeLj","Type":"PDF"}},{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERieLj","Type":"PDF"}}]}','Success',200));
        sapResponse = COARequestClass.callSAPCOAService(entredCorrectMotherBatch, false,'Batch Number'/*,QueueID*/);
        system.assertEquals('', sapResponse.errorInfo );
        System.assertEquals(1, sapResponse.contentTileMap.keySet().size() );
        System.assertEquals(1, sapResponse.contentTileMap.values().size() );

        Test.startTest();
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"0900000001","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH10-10","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBE0xLjYeLj","Type":"PDF"}},{"Delivery":"0900000001","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH10-20","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVi0xLjYNJ","Type":"PDF"}}]}','Success',200));
        sapResponse = COARequestClass.callSAPCOAService(entredCorrectChildBatch, false,'Child Batch Number');
        system.assertEquals('', sapResponse.errorInfo );
        System.assertEquals(1, sapResponse.contentTileMap.keySet().size() );
        System.assertEquals(1, sapResponse.contentTileMap.values().size() );
        
        Test.stopTest();
    }
    @isTest
    private static void checkFailedMockResponseFromSAP(){

        COARequestClass.contentUserInfo sapResponse;
        
        Tile__c correctDeliveryRequest = new Tile__c();
        correctDeliveryRequest.Name = 'DELIEVRY:0800000001';
        correctDeliveryRequest.Delivery_Number__c ='0800000001'; //delivery1
        correctDeliveryRequest.Sales_Order_Number__c ='';
        correctDeliveryRequest.Purchase_Order_Number__c='';
        
        Tile__c entredCorrectMotherBatch = new Tile__c();
        entredCorrectMotherBatch.Name = 'BATCH:BATCH10';
        entredCorrectMotherBatch.Purchase_Order_Number__c ='';
        entredCorrectMotherBatch.Sales_Order_Number__c=''; //
        entredCorrectMotherBatch.Delivery_Number__c=''; 
        entredCorrectMotherBatch.Batch_Number__c = 'BATCH10';   //batch1
        entredCorrectMotherBatch.ShipToParty__c = '0000000001';

        sapResponse = COARequestClass.callSAPCOAService(correctDeliveryRequest, false,'Delivery  Number'/*,QueueID*/);
        system.assertEquals('An unexpected error occurred. The technical team has been notified.', sapResponse.errorInfo);
        System.assertEquals(true, sapResponse.contentTileMap.isEmpty() );
        system.assertEquals( 'INTERNAL_ERROR', sapResponse.logCustomDebugLog.get(0).TypeName__c);

        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Error_Msg":"Server is Down"}','Failed',500));
        sapResponse = COARequestClass.callSAPCOAService(correctDeliveryRequest, false,'Delivery Number'/*,QueueID*/);
        system.assertEquals('An unexpected error occurred. The technical team has been notified.', sapResponse.errorInfo );
        System.assertEquals(true, sapResponse.contentTileMap.isEmpty() );
        system.assertEquals('INTEGRATION_ERROR'  , sapResponse.logCustomDebugLog.get(0).TypeName__c);

        Test.startTest();
          
            Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Error_Msg":"Server is Down"}','Failed',500));
            sapResponse = COARequestClass.callSAPCOAService(entredCorrectMotherBatch, false,'Batch Number'/*,QueueID*/);
            system.assertEquals('An unexpected error occurred. The technical team has been notified.', sapResponse.errorInfo );
            System.assertEquals(true, sapResponse.contentTileMap.isEmpty() );
            system.assertEquals('INTEGRATION_ERROR'  , sapResponse.logCustomDebugLog.get(0).TypeName__c);
            
        Test.stopTest();
    }
    
}