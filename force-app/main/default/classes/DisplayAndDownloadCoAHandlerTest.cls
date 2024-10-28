@isTest
global class DisplayAndDownloadCoAHandlerTest {
    
    
    @testSetup
    Private static void setup() {
        /**************Community User Creation**********************************/
        
        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);
        
        Account commercialCust1 = TestUtility.createAccount('Danone SA');
        accsCustomLocToInsert.add(commercialCust1);
        
        INSERT accsCustomLocToInsert;
        
        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        customerLocItaly.SAP_Number_PE1__c = '00000001';
        customerLocItaly.SAP_Number__c = '00000001';
        accsToInsert.add(customerLocItaly);
        
        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
        customerLocFrance.SAP_Number_PE1__c = '00000002';
        customerLocFrance.SAP_Number__c = '00000002';
        accsToInsert.add(customerLocFrance);
        
        Account customerLocdanone = TestUtility.createCustomerLocation('Danone Blendina', commercialCust1);
        customerLocdanone.SAP_Number_PE1__c = '00000003';
        customerLocdanone.SAP_Number__c = '00000003';
        accsToInsert.add(customerLocdanone);
        
        Account customerLocdanoneNutricia = TestUtility.createCustomerLocation('Danone Nutricia', commercialCust1);
        customerLocdanoneNutricia.SAP_Number_PE1__c = '00000004';
        customerLocdanoneNutricia.SAP_Number__c = '00000004';
        accsToInsert.add(customerLocdanoneNutricia);
        
        INSERT accsToInsert;
        
        List<Contact> contactsToInsert = new List<Contact>();
        Contact conItalyStandard = TestUtility.createContact('Test' , 'IMCD Italy', commercialCust, customerLocItaly);
        contactsToInsert.add(conItalyStandard);
        
        Contact conIMCDItalyManager = TestUtility.createContact('Test', 'IMCD Italy Manager', commercialCust, customerLocItaly);
        contactsToInsert.add(conIMCDItalyManager);
        
        Contact standardConDanoneBlendina = TestUtility.createContact('Test', 'Danone Blendina', commercialCust1, customerLocdanone);
        contactsToInsert.add(standardConDanoneBlendina);
        
        Contact standardConDanoneNutricia = TestUtility.createContact('Test', 'Danone Nutricia', commercialCust1, customerLocdanoneNutricia);
        contactsToInsert.add(standardConDanoneNutricia);
        
        Contact managerConDanoneBlendina = TestUtility.createContact('Test', 'Danone Blendina Manager', commercialCust1, customerLocdanone);
        contactsToInsert.add(managerConDanoneBlendina);
        
        Contact managerConDanoneNutricia = TestUtility.createContact('Test', 'Danone Nutricia Manager', commercialCust1, customerLocdanoneNutricia);
        contactsToInsert.add(managerConDanoneNutricia);
        
        INSERT contactsToInsert;
        
        List<User> usersToInsert = new List<User>();
        User usrIMCDItalyManager = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDItalyManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrIMCDItalyManager.ContactId = conIMCDItalyManager.Id;
        usersToInsert.add(usrIMCDItalyManager);
        
        User usrItalyStandard = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItalyStandard', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrItalyStandard.ContactId = conItalyStandard.Id;
        usersToInsert.add(usrItalyStandard);
        
        User standardUserDanoneBlendina = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanoneBlendinaStandard', Constants.TEST_FCI_CUSTOMER_PROFILE);
        standardUserDanoneBlendina.ContactId = standardConDanoneBlendina.Id;
        usersToInsert.add(standardUserDanoneBlendina);
        
        User standardUserDanoneNutricia = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanoneNutriciaStandard', Constants.TEST_FCI_CUSTOMER_PROFILE);
        standardUserDanoneNutricia.ContactId = standardConDanoneNutricia.Id;
        usersToInsert.add(standardUserDanoneNutricia);
        
        User managerUserDanoneBlendina = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneBlendinaManager', Constants.TEST_FCI_CUSTOMER_PROFILE);
        managerUserDanoneBlendina.ContactId = managerConDanoneBlendina.Id;
        usersToInsert.add(managerUserDanoneBlendina);
        
        User managerUserDanoneNutricia = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneNutriciaManager', Constants.TEST_FCI_CUSTOMER_PROFILE);
        managerUserDanoneNutricia.ContactId = managerConDanoneNutricia.Id;
        usersToInsert.add(managerUserDanoneNutricia);
        INSERT usersToInsert;
        
        List<Contract> contractToInsert = new List<Contract>();
        Contract cont1 = new Contract();
        cont1.Status ='Draft';
        cont1.Parent_Account__c = commercialCust1.id;
        cont1.AccountId = customerLocdanone.id;
        cont1.StartDate = system.today();
        cont1.EndDate = system.today()+1;
        contractToInsert.add(cont1);
        
        Contract cont2 = new Contract();
        cont2.Status ='Draft';
        cont2.Parent_Account__c = commercialCust1.id;
        cont2.AccountId = customerLocdanoneNutricia.id;
        cont2.StartDate = system.today();
        cont2.EndDate = system.today()+1;
        contractToInsert.add(cont2);
        
        Contract cont3 = new Contract();
        cont3.Status ='Draft';
        cont3.Parent_Account__c = commercialCust.id;
        cont3.AccountId = customerLocItaly.id;
        cont3.StartDate = system.today();
        cont3.EndDate = system.today()+1;
        contractToInsert.add(cont3);
        
        Contract cont4 = new Contract();
        cont4.Status ='Draft';
        cont4.Parent_Account__c = commercialCust.id;
        cont4.AccountId = customerLocFrance.id;
        cont4.StartDate = system.today();
        cont4.EndDate = system.today()+1;
        contractToInsert.add(cont4);
        
        INSERT contractToInsert;
        
        Pricebook2 priceBookObj = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );       
        UPDATE priceBookObj;
        Id priceBookId = [select id from Pricebook2 where id=:priceBookObj.id].id;
        
        Sales_Area__c salesArea = TestUtility.createSalesArea('SA', customerLocItaly, '', '', '', '');
        INSERT salesArea;
        
        List<Partner_Role__c> partnerRoleToInsert = new List<Partner_Role__c>();
        Partner_Role__c partnerRole1 = TestUtility.createPartnerRole('PR1',customerLocItaly , customerLocItaly, salesArea, '', '');
        partnerRole1.Relation_Name__c = 'Ship To';
        partnerRoleToInsert.add(partnerRole1);
        
        Partner_Role__c partnerRole2 = TestUtility.createPartnerRole('PR2',customerLocdanone , customerLocdanone, salesArea, '', '');
        partnerRole2.Relation_Name__c = 'Ship To';
        partnerRoleToInsert.add(partnerRole2);
        INSERT partnerRoleToInsert;
        
        List<Delivery__c> deliveryToInsert = new List<Delivery__c>();
        Delivery__c delivery1 = new Delivery__c();
        delivery1.SAP_Delivery_Number__c='080000001';
        delivery1.Sold_To__c=customerLocdanone.Id;
        delivery1.Ship_To__c = customerLocdanone.id;
        deliveryToInsert.add(delivery1);
        
        Delivery__c delivery2  = new Delivery__c();
        delivery2.SAP_Delivery_Number__c='080000002';
        delivery2.Sold_To__c=customerLocdanone.Id;
        delivery2.Ship_To__c = customerLocdanone.id;
        deliveryToInsert.add(delivery2);
        
        Delivery__c delivery3  = new Delivery__c();
        delivery3.SAP_Delivery_Number__c='080000003';
        delivery3.Sold_To__c=customerLocdanoneNutricia.Id;
        delivery3.Ship_To__c = customerLocdanone.id;
        deliveryToInsert.add(delivery3);
        
        Delivery__c delivery4  = new Delivery__c();
        delivery4.SAP_Delivery_Number__c='080000004';
        delivery4.Sold_To__c=customerLocdanoneNutricia.Id;
        delivery4.Ship_To__c = customerLocdanoneNutricia.id;
        deliveryToInsert.add(delivery4);
        
        Delivery__c delivery5  = new Delivery__c();
        delivery5.SAP_Delivery_Number__c='080000005';
        delivery5.Sold_To__c=customerLocItaly.Id;
        delivery5.Ship_To__c = customerLocItaly.id;
        deliveryToInsert.add(delivery5);
        
        Delivery__c delivery6  = new Delivery__c();
        delivery6.SAP_Delivery_Number__c='080000006';
        delivery6.Sold_To__c=customerLocItaly.Id;
        delivery6.Ship_To__c = customerLocItaly.id;
        deliveryToInsert.add(delivery6);
        
        Delivery__c delivery7  = new Delivery__c();
        delivery7.SAP_Delivery_Number__c='080000007';
        delivery7.Sold_To__c=customerLocFrance.Id;
        delivery7.Ship_To__c = customerLocFrance.id;
        deliveryToInsert.add(delivery7);
        
        Delivery__c delivery8  = new Delivery__c();
        delivery8.SAP_Delivery_Number__c='080000008';
        delivery8.Sold_To__c=customerLocFrance.Id;
        delivery8.Ship_To__c = customerLocItaly.id;
        deliveryToInsert.add(delivery8);
        
        INSERT deliveryToInsert;
        
        
        List<Order> orderToInsert = new List<Order>();
        Order ord1 = new Order();
        ord1.Parent_Account__c = commercialCust1.id;
        ord1.AccountId =customerLocdanone.id;
        ord1.SAP_Sales_Order_Number__c='SO0000001';
        ord1.PoNumber ='PO000001';
        ord1.ContractId= cont1.id;
        ord1.Pricebook2Id = priceBookId;
        ord1.EffectiveDate = cont1.EndDate;
        orderToInsert.add(ord1);
        
        Order ord2= new Order();
        ord2.Parent_Account__c = commercialCust1.id;
        ord2.AccountId =customerLocdanone.id;
        ord2.SAP_Sales_Order_Number__c='SO0000002';
        ord2.PoNumber ='PO000001';
        ord2.ContractId= cont1.id;
        ord2.Pricebook2Id = priceBookId;
        ord2.EffectiveDate = cont1.EndDate;
        orderToInsert.add(ord2);
        
        Order ord3= new Order();
        ord3.Parent_Account__c = commercialCust1.id;
        ord3.AccountId =customerLocdanoneNutricia.id;
        ord3.SAP_Sales_Order_Number__c='SO0000003';
        ord3.PoNumber ='PO000002';
        ord3.ContractId= cont2.id;
        ord3.Pricebook2Id = priceBookId;
        ord3.EffectiveDate = cont2.EndDate;
        orderToInsert.add(ord3);
        
        Order ord4= new Order();
        ord4.Parent_Account__c = commercialCust1.id;
        ord4.AccountId =customerLocdanoneNutricia.id;
        ord4.SAP_Sales_Order_Number__c='SO0000004';
        ord4.PoNumber ='PO000003';
        ord4.ContractId= cont2.id;
        ord4.Pricebook2Id = priceBookId;
        ord4.EffectiveDate = cont2.EndDate;
        orderToInsert.add(ord4);
        
        Order ord5= new Order();
        ord5.Parent_Account__c = commercialCust.id;
        ord5.AccountId =customerLocItaly.id;
        ord5.SAP_Sales_Order_Number__c='SO0000005';
        ord5.PoNumber ='PO000004';
        ord5.ContractId= cont3.id;
        ord5.Pricebook2Id = priceBookId;
        ord5.EffectiveDate = cont2.EndDate;
        orderToInsert.add(ord5);
        
        Order ord6= new Order();
        ord6.Parent_Account__c = commercialCust.id;
        ord6.AccountId =customerLocFrance.id;
        ord6.SAP_Sales_Order_Number__c='SO0000006';
        ord6.PoNumber ='PO000005';
        ord6.ContractId= cont4.id;
        ord6.Pricebook2Id = priceBookId;
        ord6.EffectiveDate = cont4.EndDate;
        orderToInsert.add(ord6);
        
        INSERT orderToInsert;
        
        List<Delivery_Line_Item__c> deliveryLineToInsert = new List<Delivery_Line_Item__c>();
        Delivery_Line_Item__c dlit1 = new Delivery_Line_Item__c();
        dlit1.Delivery__c = delivery1.id;
        dlit1.Sales_Order_number__c = ord1.id;
        dlit1.Purchase_order_number__c = ord1.PoNumber;
        dlit1.SAP_Delivery_Item_Number__c = delivery1.SAP_Delivery_Number__c+'000010';
        deliveryLineToInsert.add(dlit1);
        
        Delivery_Line_Item__c dlit2 = new Delivery_Line_Item__c();
        dlit2.Delivery__c = delivery2.id;
        dlit2.Sales_Order_number__c = ord2.id;
        dlit2.Purchase_order_number__c = ord2.PoNumber;
        dlit2.SAP_Delivery_Item_Number__c = delivery2.SAP_Delivery_Number__c+'000010900001';
        dlit2.SAP_Batch_Number__c = 'BATCH10-10';
        deliveryLineToInsert.add(dlit2);
        
        Delivery_Line_Item__c dlit3 = new Delivery_Line_Item__c();
        dlit3.Delivery__c = delivery2.id;
        dlit3.Sales_Order_number__c = ord2.id;
        dlit3.Purchase_order_number__c = ord2.PoNumber;
        dlit3.SAP_Delivery_Item_Number__c = delivery2.SAP_Delivery_Number__c+'000010900002';
        dlit3.SAP_Batch_Number__c = 'BATCH10-20';
        deliveryLineToInsert.add(dlit3);
        
        Delivery_Line_Item__c dlit4 = new Delivery_Line_Item__c();
        dlit4.Delivery__c = delivery3.id;
        dlit4.Sales_Order_number__c = ord3.id;
        dlit4.Purchase_order_number__c = ord3.PoNumber;
        dlit4.SAP_Delivery_Item_Number__c = delivery3.SAP_Delivery_Number__c+'000010';
        deliveryLineToInsert.add(dlit4);
        
        Delivery_Line_Item__c dlit5 = new Delivery_Line_Item__c();
        dlit5.Delivery__c = delivery3.id;
        dlit5.Sales_Order_number__c = ord3.id;
        dlit5.Purchase_order_number__c = ord3.PoNumber;
        dlit5.SAP_Delivery_Item_Number__c = delivery3.SAP_Delivery_Number__c+'000010900001';
        dlit5.SAP_Batch_Number__c = 'BATCH20-10';
        deliveryLineToInsert.add(dlit5);
        
        Delivery_Line_Item__c dlit6 = new Delivery_Line_Item__c();
        dlit6.Delivery__c = delivery4.id;
        dlit6.Sales_Order_number__c = ord3.id;
        dlit6.Purchase_order_number__c = ord3.PoNumber;
        dlit6.SAP_Delivery_Item_Number__c = delivery4.SAP_Delivery_Number__c+'000010900001';
        dlit6.SAP_Batch_Number__c = 'BATCH20-20';
        deliveryLineToInsert.add(dlit6);
        
        Delivery_Line_Item__c dlit7 = new Delivery_Line_Item__c();
        dlit7.Delivery__c = delivery5.id;
        dlit7.Sales_Order_number__c = ord5.id;
        dlit7.Purchase_order_number__c = ord5.PoNumber;
        dlit7.SAP_Delivery_Item_Number__c = delivery5.SAP_Delivery_Number__c+'000010';
        deliveryLineToInsert.add(dlit7);
        
        Delivery_Line_Item__c dlit8 = new Delivery_Line_Item__c();
        dlit8.Delivery__c = delivery6.id;
        dlit8.Sales_Order_number__c = ord5.id;
        dlit8.Purchase_order_number__c = ord5.PoNumber;
        dlit8.SAP_Delivery_Item_Number__c = delivery6.SAP_Delivery_Number__c+'000010';
        deliveryLineToInsert.add(dlit8);
        
        Delivery_Line_Item__c dlit9 = new Delivery_Line_Item__c();
        dlit9.Delivery__c = delivery7.id;
        dlit9.Sales_Order_number__c = ord6.id;
        dlit9.Purchase_order_number__c = ord6.PoNumber;
        dlit9.SAP_Delivery_Item_Number__c = delivery7.SAP_Delivery_Number__c+'000010900001';
        dlit9.SAP_Batch_Number__c = 'BATCH30-10';
        deliveryLineToInsert.add(dlit9);
        
        Delivery_Line_Item__c dlit10 = new Delivery_Line_Item__c();
        dlit10.Delivery__c = delivery8.id;
        dlit10.Sales_Order_number__c = ord6.id;
        dlit10.Purchase_order_number__c = ord6.PoNumber;
        dlit10.SAP_Delivery_Item_Number__c = delivery8.SAP_Delivery_Number__c+'000010900001';
        dlit10.SAP_Batch_Number__c = 'BATCH30-20';
        deliveryLineToInsert.add(dlit10);
        
        Test.startTest();
        INSERT deliveryLineToInsert;
        Test.stopTest();
    }
    
    @isTest
    public static void fetchCoABasedOnDeliveryByInternalUser(){
        
        string baseURLSFDC ='www.salesforce.com';
        DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs listOfCoAReceived;
        DisplayCoAsAtRecordPageHandler.ShowCoAAtRecordDetailPage listOfCoARetrive;
        
        Tile__c entredCorrectDelivery = new Tile__c();
        entredCorrectDelivery.Purchase_Order_Number__c ='';
        entredCorrectDelivery.Sales_Order_Number__c='';
        entredCorrectDelivery.Delivery_Number__c= '080000001';  //delivery1
        
        
        Tile__c entredWrongDelivery = new Tile__c();
        entredWrongDelivery.Purchase_Order_Number__c ='';
        entredWrongDelivery.Sales_Order_Number__c='';
        entredWrongDelivery.Delivery_Number__c='DELIVERY01';  // entred wrong SAP Delivery Number
        
        Tile__c entredCorrectDeliveryButNotInSf = new Tile__c();
        entredCorrectDeliveryButNotInSf.Purchase_Order_Number__c ='';
        entredCorrectDeliveryButNotInSf.Sales_Order_Number__c='';
        entredCorrectDeliveryButNotInSf.Delivery_Number__c='090000001';  //  SAP Delivery Number is not in SF but format is correct
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"080000001","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000000","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"080000001","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredCorrectDelivery, baseURLSFDC, 'Delivery Number', false);
        System.assertEquals('', listOfCoAReceived.errorsInfo);
        System.assertEquals(2, listOfCoAReceived.fileRecord.size());
        
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredWrongDelivery, baseURLSFDC, 'Delivery Number', false);
        System.assertEquals('This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.',listOfCoAReceived.errorsInfo );
        System.assertEquals(0,listOfCoAReceived.fileRecord.size());
        
        
        Test.startTest();
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"090000001","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000000","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"090000001","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000000","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredCorrectDeliveryButNotInSf, baseURLSFDC, 'Delivery Number', false);
        System.assertEquals('',listOfCoAReceived.errorsInfo);
        System.assertEquals(2,listOfCoAReceived.fileRecord.size());
        
        String userType = DisplayAndDownloadCoAHandler.IsCommunityUserCheck();
        System.assertEquals('INTERNAL_USER', userType);
        
        Test.stopTest();       
    }
    
    @isTest
    public static void fetchCoABasedOnDeliveryByCommunityUser(){
        
        string baseURLSFDC ='WWW.abc.com';
        DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs listOfCoAReceived;
        
        User DanoneBlendinaStandardUser = [SELECT id,ContactId,Community_User_Role__c,
                                           Contact.Additional_Country_Responsibility__c,
                                           Contact.AccountId,Contact.Parent_Account__c FROM User WHERE UserName LIKE '%TestDanoneBlendinaStandard'];
        User DanoneBlendinaManagerUser  = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneBlendinaManager'];
        
        User DanoneNutriciaStandardUSER = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneNutriciaStandard'];
        User DanoneNutriciaManagerUser  = [SELECT id,ContactId,Community_User_Role__c,
                                           Contact.Additional_Country_Responsibility__c,
                                           Contact.AccountId,Contact.Parent_Account__c FROM User WHERE UserName LIKE '%TestDanoneNutriciaManager'];
        
        User IMCDItalyStandardUser      = [SELECT id FROM User WHERE UserName LIKE '%TestIMCDItalyStandard'];
        User IMCDItalyManagerUser      = [SELECT id FROM User WHERE UserName LIKE '%TestIMCDItalyManager'];
        
        Tile__c enteredCorrectDelivery1 = new Tile__c();
        enteredCorrectDelivery1.Purchase_Order_Number__c ='';
        enteredCorrectDelivery1.Sales_Order_Number__c='';
        enteredCorrectDelivery1.Delivery_Number__c='080000001';  //delivery1
        
        Tile__c enteredCorrectDelivery2 = new Tile__c();
        enteredCorrectDelivery2.Purchase_Order_Number__c ='';
        enteredCorrectDelivery2.Sales_Order_Number__c='';
        enteredCorrectDelivery2.Delivery_Number__c='080000002';  //delivery2
        
        Tile__c enteredWrongDelivery = new Tile__c();
        enteredWrongDelivery.Purchase_Order_Number__c ='';
        enteredWrongDelivery.Sales_Order_Number__c='';
        enteredWrongDelivery.Delivery_Number__c='DELIVERY01';  // entred wrong SAP Delivery Number
        
        Tile__c enteredDeliveryNotInSF = new Tile__c();
        enteredDeliveryNotInSF.Purchase_Order_Number__c ='';
        enteredDeliveryNotInSF.Sales_Order_Number__c='';
        enteredDeliveryNotInSF.Delivery_Number__c='1000000000'; 
        
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredWrongDelivery, baseURLSFDC, 'Delivery Number', false);
        System.assertEquals('This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.',listOfCoAReceived.errorsInfo);
        System.assertEquals(0, listOfCoAReceived.fileRecord.size());
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"080000002","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000010","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"080000002","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000010","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectDelivery2, baseURLSFDC, 'Delivery Number', true);
        System.assertEquals('',listOfCoAReceived.errorsInfo);
        System.assertEquals(2,listOfCoAReceived.fileRecord.size());
        
        System.runAs(IMCDItalyStandardUser){
            String userType = DisplayAndDownloadCoAHandler.IsCommunityUserCheck();
            System.assertEquals('DISTRIBUTOR_STANDARD', userType);
            
            listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectDelivery2, baseURLSFDC, 'Delivery Number', false);
            System.assertEquals('This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.',listOfCoAReceived.errorsInfo);
            System.assertEquals(0,listOfCoAReceived.fileRecord.size());
        }
        System.runAs(IMCDItalyManagerUser){
            String userType = DisplayAndDownloadCoAHandler.IsCommunityUserCheck();
            System.assertEquals('DISTRIBUTOR_MANAGER', userType);
            
            listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectDelivery1, baseURLSFDC, 'Delivery Number', false);
            System.assertEquals('This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.',listOfCoAReceived.errorsInfo);
            System.assertEquals(0,listOfCoAReceived.fileRecord.size());
        }
        
        
        Test.startTest();
        
        DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs listOfCoAReceivedIfDeliveryNotInSF;
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"1000000000","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"1000000000","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        listOfCoAReceivedIfDeliveryNotInSF = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredDeliveryNotInSF, baseURLSFDC, 'Delivery Number', false);
        
        System.runAs(DanoneBlendinaStandardUser){
            /*listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredDeliveryNotInSF, baseURLSFDC, 'Delivery Number', false);
            System.assertEquals('This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.',listOfCoAReceived.errorsInfo);
            System.assertEquals(0,listOfCoAReceived.fileRecord.size());*/
            DisplayAndDownloadCoAHelper.checkCoAVisiblityForDeliveryNotPresentInSF('00000003', DanoneBlendinaStandardUser);
            DisplayAndDownloadCoAHandler.getRecordTypeAndCurrentUserDetails();
            String userType = DisplayAndDownloadCoAHandler.IsCommunityUserCheck();
            System.assertEquals('CUSTOMER_STANDARD', userType);
        }
        System.runAs(DanoneNutriciaStandardUSER){
            listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectDelivery1, baseURLSFDC, 'Delivery Number', false);
            System.assertEquals('This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.',listOfCoAReceived.errorsInfo);
            System.assertEquals(0,listOfCoAReceived.fileRecord.size());
        }
        System.runAs(DanoneNutriciaManagerUser){
            /*listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectDelivery2, baseURLSFDC, 'Delivery Number', true);
            System.assertEquals('',listOfCoAReceived.errorsInfo);
            System.assertEquals(2,listOfCoAReceived.fileRecord.size());*/
            DisplayAndDownloadCoAHelper.checkCoAVisiblityForDeliveryNotPresentInSF('00000004', DanoneNutriciaManagerUser);
            String userType  = DisplayAndDownloadCoAHandler.IsCommunityUserCheck();
            System.assertEquals('CUSTOMER_MANAGER', userType);
        }
        System.runAs(IMCDItalyStandardUser){
           /* listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredDeliveryNotInSF, baseURLSFDC, 'Delivery Number', false);
            System.assertEquals('',listOfCoAReceived.errorsInfo);
            System.assertEquals(2,listOfCoAReceived.fileRecord.size());*/
        }
        
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void fetchCoABasedOnSalesOrder(){
        
        DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs coaRetrive1;
        DisplayCoAsAtRecordPageHandler.ShowCoAAtRecordDetailPage coaRetriveFromRecordPage;
        id recordTypeId = schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        string baseURLSFDC ='WWW.abc.com';
        
        User DanoneBlendinaStandardUser = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneBlendinaStandard'];
        User DanoneNutriciaStandardUSER = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneNutriciaStandard'];
        User DanoneManagerUser  = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneBlendinaManager'];
        User IMCDItalyManagerUser      = [SELECT id FROM User WHERE UserName LIKE '%TestIMCDItalyManager'];
        
        Tile__c enteredCorrectSalesOrder = new Tile__c();
        enteredCorrectSalesOrder.Purchase_Order_Number__c ='';
        enteredCorrectSalesOrder.Sales_Order_Number__c='SO0000003'; //order3
        enteredCorrectSalesOrder.Delivery_Number__c=''; 
        
        Tile__c userSearchSalesOrderNumber = new Tile__c();
        userSearchSalesOrderNumber.Purchase_Order_Number__c ='';
        userSearchSalesOrderNumber.Sales_Order_Number__c='SO0000001'; //order1
        userSearchSalesOrderNumber.Delivery_Number__c=''; 
        
        Tile__c enetredWrongSalesOrder = new Tile__c();
        enetredWrongSalesOrder.Purchase_Order_Number__c ='';
        enetredWrongSalesOrder.Sales_Order_Number__c='S010000001';
        enetredWrongSalesOrder.Delivery_Number__c='';  // entred wrong SAP Sale Order Number
        
        
        coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enetredWrongSalesOrder, baseURLSFDC, 'Sales Order Number', false);
        System.assertEquals('This Sales Order Number is either incorrect or does not exist. Please verify and try again.\n If this error persists, please retry with the Delivery Number.',coaRetrive1.errorsInfo);
        System.assertEquals(0, coaRetrive1.fileRecord.size());
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"080000003","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"080000003","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectSalesOrder, baseURLSFDC, 'Sales Order Number', false);
        System.assertEquals('',coaRetrive1.errorsInfo);
        System.assertEquals(4, coaRetrive1.fileRecord.size());
        
        System.runAs(DanoneBlendinaStandardUser){
            coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectSalesOrder, baseURLSFDC, 'Sales Order Number', false);
            System.assertEquals('This Sales Order Number is either incorrect or does not exist. Please verify and try again.\n If this error persists, please retry with the Delivery Number.',coaRetrive1.errorsInfo);
            System.assertEquals(0, coaRetrive1.fileRecord.size());
        }
        System.runAs(DanoneManagerUser){
           /* coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectSalesOrder, baseURLSFDC, 'Sales Order Number', false);
            System.assertEquals('',coaRetrive1.errorsInfo);
            System.assertEquals(4, coaRetrive1.fileRecord.size());*/
        }
        System.runAs(DanoneNutriciaStandardUSER){
           /* coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectSalesOrder, baseURLSFDC, 'Sales Order Number', false);
            System.assertEquals('',coaRetrive1.errorsInfo);
            System.assertEquals(4, coaRetrive1.fileRecord.size());*/
        }
        
        
        Test.startTest();
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"080000001","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(userSearchSalesOrderNumber, baseURLSFDC, 'Sales Order Number', true);
        System.assertEquals('',coaRetrive1.errorsInfo);
        System.assertEquals(1, coaRetrive1.fileRecord.size());
        
        System.runAs(DanoneBlendinaStandardUser){
           /* coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(userSearchSalesOrderNumber, baseURLSFDC, 'Sales Order Number', true);
            System.assertEquals('',coaRetrive1.errorsInfo);
            System.assertEquals(1, coaRetrive1.fileRecord.size());*/
        }
        System.runAs(IMCDItalyManagerUser){
            coaRetrive1 = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(userSearchSalesOrderNumber, baseURLSFDC, 'Sales Order Number', false);
            System.assertEquals('This Sales Order Number is either incorrect or does not exist. Please verify and try again.\n If this error persists, please retry with the Delivery Number.',coaRetrive1.errorsInfo);
            System.assertEquals(0, coaRetrive1.fileRecord.size());
        }
        
        Test.stopTest();       
    }
    @isTest
    public static void fetchCoABasedOnPurchaseOrder(){
        
        id recordTypeId = schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        string baseURLSFDC ='WWW.abc.com';
        DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs coARetrived;
        
        User DanoneBlendinaStandardUser = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneBlendinaStandard'];
        User DanoneNutriciaStandardUSER = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneNutriciaStandard'];
        User DanoneManagerUser  = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneBlendinaManager'];
        User IMCDItalyManagerUser      = [SELECT id FROM User WHERE UserName LIKE '%TestIMCDItalyManager'];
        
        Tile__c entredCorrectPurchaseOrder = new Tile__c();
        entredCorrectPurchaseOrder.Purchase_Order_Number__c ='PO000001'; //order1,order2
        entredCorrectPurchaseOrder.Sales_Order_Number__c=''; 
        entredCorrectPurchaseOrder.Delivery_Number__c='';  
        
        Tile__c userSearchPurchaseOrderNumber = new Tile__c();
        userSearchPurchaseOrderNumber.Purchase_Order_Number__c ='PO000005'; //Order3
        userSearchPurchaseOrderNumber.Sales_Order_Number__c=''; 
        userSearchPurchaseOrderNumber.Delivery_Number__c='';  
        
        Tile__c entredWrongPurchasesOrder = new Tile__c();
        entredWrongPurchasesOrder.Purchase_Order_Number__c ='WrongPO'; // entred wrong PO Number
        entredWrongPurchasesOrder.Sales_Order_Number__c='';
        entredWrongPurchasesOrder.Delivery_Number__c='';  
        
        
        coARetrived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredWrongPurchasesOrder, baseURLSFDC, 'Purchase Order Number', false);
        System.assertEquals('This Purchase Order Number is either incorrect or does not exist. Please verify and try again.\n If this error persists, please retry with the Delivery Number.',coARetrived.errorsInfo );
        System.assertEquals(0, coARetrived.fileRecord.size());
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        coARetrived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredCorrectPurchaseOrder, baseURLSFDC, 'Purchase Order Number', false);
        System.assertEquals('',coARetrived.errorsInfo );
        System.assertEquals(4, coARetrived.fileRecord.size());
        
        System.runAs(DanoneBlendinaStandardUser){
           /* coARetrived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredCorrectPurchaseOrder, baseURLSFDC, 'Purchase Order Number', true);
            System.assertEquals('',coARetrived.errorsInfo );
            System.assertEquals(4, coARetrived.fileRecord.size());*/
        }
        System.runAs(IMCDItalyManagerUser){
            coARetrived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredCorrectPurchaseOrder, baseURLSFDC, 'Purchase Order Number', false);
            System.assertEquals('This Purchase Order Number is either incorrect or does not exist. Please verify and try again.\n If this error persists, please retry with the Delivery Number.',coARetrived.errorsInfo );
            System.assertEquals(0, coARetrived.fileRecord.size());
        }
        
        Test.startTest();
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        coARetrived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(userSearchPurchaseOrderNumber, baseURLSFDC, 'Purchase Order Number', true);
        System.assertEquals('',coARetrived.errorsInfo );
        System.assertEquals(4, coARetrived.fileRecord.size());
        
        System.runAs(DanoneNutriciaStandardUSER){
            coARetrived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(entredCorrectPurchaseOrder, baseURLSFDC, 'Purchase Order Number', false);
            System.assertEquals('This Purchase Order Number is either incorrect or does not exist. Please verify and try again.\n If this error persists, please retry with the Delivery Number.',coARetrived.errorsInfo );
            System.assertEquals(0, coARetrived.fileRecord.size());
        }
        Test.stopTest();     
    }
    @isTest
    public static void fetchCoABasedOnBatch(){
        
        DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs listOfCoAReceived;
        id recordTypeId = schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        string baseURLSFDC ='WWW.abc.com';
        
        User DanoneBlendinaStandardUser = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneBlendinaStandard'];
        User DanoneNutriciaStandardUSER = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneNutriciaStandard'];
        User DanoneManagerUser  = [SELECT id FROM User WHERE UserName LIKE '%TestDanoneBlendinaManager'];
        User IMCDItalyManagerUser      = [SELECT id FROM User WHERE UserName LIKE '%TestIMCDItalyManager'];
        
        Tile__c enteredCorrectBatch1 = new Tile__c();
        enteredCorrectBatch1.Purchase_Order_Number__c ='';
        enteredCorrectBatch1.Sales_Order_Number__c=''; //
        enteredCorrectBatch1.Delivery_Number__c=''; 
        enteredCorrectBatch1.Batch_Number__c = 'BATCH10'; 
        enteredCorrectBatch1.ShipToParty__c = '';
        
        Tile__c enteredCorrectBatch2 = new Tile__c();
        enteredCorrectBatch2.Purchase_Order_Number__c ='';
        enteredCorrectBatch2.Sales_Order_Number__c=''; //
        enteredCorrectBatch2.Delivery_Number__c=''; 
        enteredCorrectBatch2.Batch_Number__c = 'BATCH20-10'; 
        enteredCorrectBatch2.ShipToParty__c = '';
        
        Tile__c enteredCorrectBatch3 = new Tile__c();
        enteredCorrectBatch3.Purchase_Order_Number__c ='';
        enteredCorrectBatch3.Sales_Order_Number__c=''; //
        enteredCorrectBatch3.Delivery_Number__c=''; 
        enteredCorrectBatch3.Batch_Number__c = 'BATCH30'; 
        enteredCorrectBatch3.ShipToParty__c = '';
        
        Tile__c enteredCorrectBatchWithoutShipTo = new Tile__c();
        enteredCorrectBatchWithoutShipTo.Purchase_Order_Number__c ='';
        enteredCorrectBatchWithoutShipTo.Sales_Order_Number__c='';
        enteredCorrectBatchWithoutShipTo.Delivery_Number__c=''; 
        enteredCorrectBatchWithoutShipTo.Batch_Number__c = 'BATCH SHIP'; // Batch Number not present in SF without ship to
        enteredCorrectBatchWithoutShipTo.ShipToParty__c = '';
        
        
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectBatchWithoutShipTo, baseURLSFDC, 'Batch Number', false);
        System.assertEquals( 'Entered Batch Details not Found in SF, please enter ship to number also if you think Entered batch number is correct and has CoA',listOfCoAReceived.errorsInfo );
        System.assertEquals(0,listOfCoAReceived.fileRecord.size() );
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectBatch1, baseURLSFDC, 'Batch Number', false);
        System.assertEquals('', listOfCoAReceived.errorsInfo);
        System.assertEquals(2, listOfCoAReceived.fileRecord.size());
        
        System.runAs(DanoneBlendinaStandardUser){
           /* listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectBatch1, baseURLSFDC, 'Batch Number', true);
            System.assertEquals('', listOfCoAReceived.errorsInfo);
            System.assertEquals(2, listOfCoAReceived.fileRecord.size());*/
        }
        System.runAs(DanoneNutriciaStandardUSER){
            listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectBatch1, baseURLSFDC, 'Batch Number', false);
            System.assertEquals('Entered Batch Details not Found', listOfCoAReceived.errorsInfo);
            System.assertEquals(0, listOfCoAReceived.fileRecord.size());
        }
        
        Test.startTest();
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectBatch3, baseURLSFDC, 'Batch Number', true);
        System.assertEquals('', listOfCoAReceived.errorsInfo);
        System.assertEquals(4, listOfCoAReceived.fileRecord.size());
        
        System.runAs(DanoneManagerUser){
            listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectBatch3, baseURLSFDC, 'Batch Number', false);
            System.assertEquals('Entered Batch Details not Found', listOfCoAReceived.errorsInfo);
            System.assertEquals(0, listOfCoAReceived.fileRecord.size());
        }
        System.runAs(IMCDItalyManagerUser){
           /* listOfCoAReceived = DisplayAndDownloadCoAHandler.validateAndFetchCertificateofAnalysis(enteredCorrectBatch3, baseURLSFDC, 'Batch Number', false);
            System.assertEquals('', listOfCoAReceived.errorsInfo);
            System.assertEquals(4, listOfCoAReceived.fileRecord.size());*/
        }
        
        Test.stopTest();       
    }
    @isTest
    private static void fetchCoAOnRecordPageOfOrderAndDelivery(){
        
        DisplayCoAsAtRecordPageHandler.ShowCoAAtRecordDetailPage coaRetriveFromRecordPage;
        String baseURLSFDC = 'www.salesforce.com';
        
        Tile__c entredCorrectDelivery = new Tile__c();
        entredCorrectDelivery.Purchase_Order_Number__c ='';
        entredCorrectDelivery.Sales_Order_Number__c='';
        entredCorrectDelivery.Delivery_Number__c= '080000008';  //delivery8
        
        Tile__c enteredCorrectSalesOrder = new Tile__c();
        enteredCorrectSalesOrder.Purchase_Order_Number__c ='';
        enteredCorrectSalesOrder.Sales_Order_Number__c='SO0000006'; //order3
        enteredCorrectSalesOrder.Delivery_Number__c=''; 
        
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"080000008","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"080000008","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        coaRetriveFromRecordPage = DisplayCoAsAtRecordPageHandler.fetchCertificateOfAnalysis([SELECT id FROM Delivery__c WHERE SAP_Delivery_Number__c =:entredCorrectDelivery.Delivery_Number__c].id, baseURLSFDC);
        System.assertEquals('', coaRetriveFromRecordPage.errorsMessage);
        System.assertEquals(2, coaRetriveFromRecordPage.coaRecord.size());
        
       /* coaRetriveFromRecordPage = DisplayCoAsAtRecordPageHandler.fetchCertificateOfAnalysis([SELECT id FROM Delivery__c WHERE SAP_Delivery_Number__c =:entredCorrectDelivery.Delivery_Number__c].id, baseURLSFDC);
        System.assertEquals('', coaRetriveFromRecordPage.errorsMessage);
        System.assertEquals(2, coaRetriveFromRecordPage.coaRecord.size());*/
        
        Test.startTest();
        Test.setMock(HttpCallOutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"Record":[{"Delivery":"080000008","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000010","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att1","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}},{"Delivery":"080000008","Mother_Batch_No":"BATCH10","Child_Batch_No":"BATCH20-10","Delivery_Item_No":"000020","Distribution_Channel":"01","Material_No":"000000000000492607","Referenced_Doc_No":"0010000755","Ship_To_Party":"00000001","Attachment":{"Name":"Att2","Content":"JVBERi0xLjYNJeLj","Type":"PDF"}}]}','Success',200));
        coaRetriveFromRecordPage = DisplayCoAsAtRecordPageHandler.fetchCertificateOfAnalysis([SELECT id FROM Order WHERE SAP_Sales_Order_Number__c =:enteredCorrectSalesOrder.Sales_Order_Number__c].id, baseURLSFDC);
        System.assertEquals('',coaRetriveFromRecordPage.errorsMessage );
        System.assertEquals(4,coaRetriveFromRecordPage.coaRecord.size() );
        Test.stopTest();
        
    }
    
}