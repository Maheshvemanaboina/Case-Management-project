/*
* @Author : Mohan 
* @Date : 31th Aug 2021
* @Desc : Test class for BOMDeleteFlagSetBatch
* @Jira : SCPQ-1111
*/
@isTest
public class BOMDeleteFlagSetBatchTest {
    
    public static testMethod void test(){
        
        GeneralBatchSetting__c batchSetting = new GeneralBatchSetting__c();
        batchSetting.name = 'BOMDeleteFlagSetBatch';
        batchSetting.Batch_Size__c = 200;
        batchSetting.Batch_Email_Notifiers__c = 'test@gmail.com,test1@gmail.com';
        batchSetting.Batch_Query__c = 'SELECT Id, Delete__c,External_Key__c FROM CPQ_Bill_Of_Material_SAP__C';
        batchSetting.Days__c = 2;
        insert batchSetting;    
        
        CPQ_Bill_Of_Material_SAP__c bom = new CPQ_Bill_Of_Material_SAP__c();
     
        bom.Delete__c = true;
        bom.Component__c ='000000000000000000';
        bom.Material__c  ='000000000000000000';
        bom.External_Key__c ='000000000000000000-000000000000000000';
        insert bom;
        
        CPQ_Bill_Of_Material_SAP__c bom1 = new CPQ_Bill_Of_Material_SAP__c();
     
        bom1.Delete__c = true;
        bom1.Component__c ='000000000000000001';
        bom1.Material__c  ='000000000000000001';
        bom1.External_Key__c ='000000000000000001-000000000000000001';
        insert bom1;
        
        test.startTest();
        BOMDeleteFlagSetBatchHelper.throwException = true;
        BOMDeleteFlagSetBatch e = new BOMDeleteFlagSetBatch();
        
        database.executeBatch(e, 200);
        test.stopTest();
        
        
        system.assertEquals(true, bom.Delete__c);
        
    }

}