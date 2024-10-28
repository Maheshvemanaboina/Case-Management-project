/*
@Author     : Rohit Kumar
@CreatedDate: 
@UsedBy     : 
@Description: 
              Methods : 
@History
              Rohit Kumar : Created
*/
@isTest
public class CoASObjectLookUpControllerTest {
    
    @isTest
    public static void createSObjectsRecordForSearchNumberInCoAUI(){
        
        List<Account> commercialCustomerList = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        commercialCustomerList.add(commercialCust);
        
        INSERT commercialCustomerList;
        
        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        accsToInsert.add(customerLocItaly);
        
        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
        customerLocFrance.SAP_Number__c ='0000000001';
        accsToInsert.add(customerLocFrance);
      
        INSERT accsToInsert;
        
        List<Contact> contactsToInsert = new List<Contact>();
        Contact cItaly = TestUtility.createContact('italyCont' , 'italyCont', commercialCust, customerLocItaly);
        contactsToInsert.add(cItaly);
        
        Contact cManager = TestUtility.createContact('managerCont', 'managerCont', commercialCust, customerLocFrance);
        contactsToInsert.add(cManager);
        INSERT contactsToInsert;
        
        Sales_Area__c salesArea = TestUtility.createSalesArea('SA', customerLocFrance, '', '', '', '');
        INSERT salesArea;
        
        Partner_Role__c partnerRole1 = TestUtility.createPartnerRole('Partner Role1',customerLocFrance , customerLocFrance, salesArea, '', '');
        partnerRole1.Relation_Name__c = 'Ship To';
        INSERT partnerRole1;
        
        List<User> usersToInsert = new List<User>();
        User usrManager = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrManager.ContactId = cManager.Id;
        usersToInsert.add(usrManager);
        
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrItaly.ContactId = cItaly.Id;
        usersToInsert.add(usrItaly);
        INSERT usersToInsert;
                
        List<Contract> contractList = new List<Contract>();
        Contract cont = new Contract();
        cont.Status ='Draft';
        cont.Parent_Account__c = commercialCust.id;
        cont.AccountId = customerLocItaly.id;
        cont.StartDate = system.today();
        cont.EndDate = system.today()+1;
        contractList.add(cont);
        
        Contract cont2 = new Contract();
        cont2.Status ='Draft';
        cont2.Parent_Account__c = commercialCust.id;
        cont2.AccountId = customerLocFrance.id;
        cont2.StartDate = system.today();
        cont2.EndDate = system.today()+1;
        contractList.add(cont2);
        INSERT contractList;
        
        Pricebook2 priceBookObj = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );       
        UPDATE priceBookObj;
        
        List<Order> orderList = new List<Order>();
        Order ord = new Order();
        ord.Parent_Account__c = commercialCust.id;
        ord.AccountId =customerLocItaly.id;
        ord.SAP_Sales_Order_Number__c='SO141002';
        ord.PoNumber ='PO0191002';
        ord.ContractId= cont.id;
        ord.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        ord.EffectiveDate = cont.EndDate;
        orderList.add(ord);
        
        Order ord1 = new Order();
        ord1.Parent_Account__c = commercialCust.id;
        ord1.AccountId =customerLocFrance.id;
        ord1.SAP_Sales_Order_Number__c='SO141003';
        ord1.PoNumber ='PO0191003';
        ord1.ContractId= cont2.id;
        ord1.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        ord1.EffectiveDate = cont.EndDate;
        orderList.add(ord1);
        
        Order ord2 = new Order();
        ord2.Parent_Account__c = commercialCust.id;
        ord2.AccountId =customerLocFrance.id;
        ord2.SAP_Sales_Order_Number__c='SO241004';
        ord2.PoNumber ='PO0191003';
        ord2.ContractId= cont2.id;
        ord2.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        ord2.EffectiveDate = cont.EndDate;
        orderList.add(ord2);
        INSERT orderList;

        List<Delivery__c> deliveryList = new List<Delivery__c>();
        Delivery__c delivery1  = new Delivery__c();
        delivery1.SAP_Delivery_Number__c='080000056';
        delivery1.Sold_To__c=customerLocItaly.Id;
        deliveryList.add(delivery1);
        
        Delivery__c delivery2  = new Delivery__c();
        delivery2.SAP_Delivery_Number__c='080000057';
        delivery2.Sold_To__c=customerLocFrance.Id;
        deliveryList.add(delivery2);
        INSERT deliveryList;

        List<Delivery_Line_Item__c> deliveryLineItemsList = new List<Delivery_Line_Item__c>();

        Delivery_Line_Item__c dlit1 = new Delivery_Line_Item__c();
        dlit1.Delivery__c = delivery1.id;
        dlit1.Sales_Order_number__c = ord.id;
        dlit1.Purchase_order_number__c = ord.PoNumber;
        dlit1.SAP_Delivery_Item_Number__c = 'DL1000'+delivery1.SAP_Delivery_Number__c;
        dlit1.SAP_Batch_Number__c = 'BATCH1-10';
        deliveryLineItemsList.add(dlit1);

        Delivery_Line_Item__c dlit2 = new Delivery_Line_Item__c();
        dlit2.Delivery__c = delivery2.id;
        dlit2.Sales_Order_number__c = ord1.id;
        dlit2.Purchase_order_number__c = ord1.PoNumber;
        dlit2.SAP_Delivery_Item_Number__c = 'DL1000'+delivery2.SAP_Delivery_Number__c;
        dlit2.SAP_Batch_Number__c = 'BATCH1-20';
        deliveryLineItemsList.add(dlit2);
        INSERT deliveryLineItemsList;
        
        List<SObject> forInternalUserOrder1 = CoASObjectLookUpController.getRecords('Order','SAP_Sales_Order_Number__c','SAP_Sales_Order_Number__c',new List<String>{'SAP_Sales_Order_Number__c'},'SO1',5,true,'Sales Order Number');
        system.assertEquals(2, forInternalUserOrder1.size());
       
        List<SObject> forInternalUserPONumber = CoASObjectLookUpController.getRecords('Order','PoNumber','PoNumber',new List<String>{'PoDate'},'PO',5,false,'Purchase Order Number');
        system.assertEquals(2, forInternalUserPONumber.size());
        
        List<SObject> forInternalUserDelivery1 = CoASObjectLookUpController.getRecords('Delivery__c','SAP_Delivery_Number__c','SAP_Delivery_Number__c',new List<String>{'SAP_Delivery_Number__c'},'080',5,true,'Delivery Number');
        system.assertEquals(2, forInternalUserDelivery1.size());
        
        List<SObject> forInternalUserShipTo1 =CoASObjectLookUpController.getRecords('Partner_Role__c','Target_Account__r.SAP_Number__c','Target_Account__r.SAP_Number__c',new List<String>{'Target_Account__r.Name'},'000',5,false,'SHIPTO_NUMBER');
        system.assertEquals(1, forInternalUserShipTo1.size());

        List<SObject> forInternalUserBatch1 =CoASObjectLookUpController.getRecords('Delivery_Line_Item__c','SAP_Batch_Number__c','SAP_Batch_Number__c',new List<String>{'Delivery__r.SAP_Delivery_Number__c'},'BAT',5,false,'Batch Number');
        system.assertEquals(2, forInternalUserBatch1.size());

        system.runAs(usersToInsert[0]){
            
          List<SObject> forManagerUserOrder2 = CoASObjectLookUpController.getRecords('Order','SAP_Sales_Order_Number__c','SAP_Sales_Order_Number__c',new List<String>{'SAP_Sales_Order_Number__c'},'SO1',5,true,'Sales Order Number');
          system.assertEquals(2, forManagerUserOrder2.size());
            
          List<SObject> forManagerUserDelivery2 = CoASObjectLookUpController.getRecords('Delivery__c','SAP_Delivery_Number__c','SAP_Delivery_Number__c',new List<String>{'SAP_Delivery_Number__c'},'080',5,true,'Delivery Number');
          system.assertEquals(2, forManagerUserDelivery2.size()); 

          List<SObject> forManagerUserBatch1 =CoASObjectLookUpController.getRecords('Delivery_Line_Item__c','SAP_Batch_Number__c','SAP_Batch_Number__c',new List<String>{'Delivery__r.SAP_Delivery_Number__c'},'BAT',5,false,'Batch Number');
          system.assertEquals(2, forManagerUserBatch1.size());
           
        }
        Test.startTest();
        system.runAs(usersToInsert[1]){
            
          List<SObject> forStandardUserOrder3 = CoASObjectLookUpController.getRecords('Order','SAP_Sales_Order_Number__c','SAP_Sales_Order_Number__c',new List<String>{'SAP_Sales_Order_Number__c'},'SO1',5,true,'Sales Order Number');
          system.assertEquals(1, forStandardUserOrder3.size());
            
          List<SObject> forStandardUserDelivery3 = CoASObjectLookUpController.getRecords('Delivery__c','SAP_Delivery_Number__c','SAP_Delivery_Number__c',new List<String>{'SAP_Delivery_Number__c'},'080',5,true,'Delivery Number');
          system.assertEquals(1, forStandardUserDelivery3.size());   
          
          List<SObject> forStandardUserBatch1 =CoASObjectLookUpController.getRecords('Delivery_Line_Item__c','SAP_Batch_Number__c','SAP_Batch_Number__c',new List<String>{'Delivery__r.SAP_Delivery_Number__c'},'BAT',5,false,'Batch Number');
          system.assertEquals(1, forStandardUserBatch1.size());
            
        }
        Test.stopTest();
    }
    

}