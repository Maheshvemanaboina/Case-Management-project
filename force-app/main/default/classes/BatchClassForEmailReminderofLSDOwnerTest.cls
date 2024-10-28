@isTest
public class BatchClassForEmailReminderofLSDOwnerTest {

    @testSetup
    static void setup(){
       RecordType recrdType  = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName  = 'BGI_Commercial_Customer'];
        RecordType recrdType2  = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName  = 'BGI_Customer_Location'];
       Account acc = new Account();
        acc.Name = 'testAcc';
        acc.RecordTypeId =  recrdType.Id;    
        insert acc;
         Account acc2 = new Account();
        acc2.ParentId = acc.Id;
        acc2.Name = 'childAcc';
        acc2.RecordTypeId =  recrdType2.Id;     
        insert acc2;
         
       Profile prof = [SELECT Id, Name FROM Profile WHERE Name = 'B2C Sales Platform User'];
       UserRole role = [SELECT Id, Name FROM UserRole WHERE Name = 'CD'];
       
        Legal_Sales_Document__c lsd = new Legal_Sales_Document__c();
        lsd.Status_of_LSD__c = 'No LSD';
        lsd.Total_Net_Sales_Value__c = 24324324;
        lsd.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd.Leading_Business_Segment__c = 'Africa';
        lsd.Business_Group__c = 'CD';
        lsd.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd.Parent_Account__c = acc.Id;
        lsd.Account_Name__c = acc2.Id;
        lsd.Next_Reminder_Date_For_MD_Approval__c = null;
        
         Legal_Sales_Document__c lsd2 = new Legal_Sales_Document__c();
        lsd2.Status_of_LSD__c = 'No LSD';
        lsd2.Total_Net_Sales_Value__c = 24324324;
        lsd2.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd2.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd2.Leading_Business_Segment__c = 'China';
        lsd2.Business_Group__c = 'SN';
        lsd2.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd2.Parent_Account__c = acc.Id;
        lsd2.Account_Name__c = acc2.Id;
        lsd2.Next_Reminder_Date_For_MD_Approval__c = null;
        
         Legal_Sales_Document__c lsd3 = new Legal_Sales_Document__c();
        lsd3.Status_of_LSD__c = 'No LSD';
        lsd3.Total_Net_Sales_Value__c = 24324324;
        lsd3.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd3.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd3.Leading_Business_Segment__c = 'China';
        lsd3.Business_Group__c = 'CD & SN';
        lsd3.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd3.Parent_Account__c = acc.Id;
        lsd3.Account_Name__c = acc2.Id;
        lsd3.Next_Reminder_Date_For_MD_Approval__c = null;
        
        //-------------------------- FCI -----------------------------
        Legal_Sales_Document__c lsd4 = new Legal_Sales_Document__c();
        lsd4.Status_of_LSD__c = 'No LSD';
        lsd4.Total_Net_Sales_Value__c = 24324324;
        lsd4.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd4.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd4.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd4.Business_Group__c = 'FCI';
        lsd4.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd4.Account_Name__c = acc2.Id;
        lsd4.Parent_Account__c = acc.Id;
        lsd4.Next_Reminder_Date_For_MD_Approval__c = null;
        
         Legal_Sales_Document__c lsd5 = new Legal_Sales_Document__c();
        lsd5.Status_of_LSD__c = 'No LSD';
        lsd5.Total_Net_Sales_Value__c = 24324324;
        lsd5.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd5.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd5.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd5.Business_Group__c = 'FCI & FCP';
        lsd5.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd5.Account_Name__c = acc2.Id;
        lsd5.Parent_Account__c = acc.Id;
        lsd5.Next_Reminder_Date_For_MD_Approval__c = null;
        
         
        
         Legal_Sales_Document__c lsd8 = new Legal_Sales_Document__c();
        lsd8.Status_of_LSD__c = 'No LSD';
        lsd8.Total_Net_Sales_Value__c = 24324324;
        lsd8.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd8.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd8.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd8.Business_Group__c = 'FCI';
        lsd8.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd8.Account_Name__c = acc2.Id;
        lsd8.Parent_Account__c = acc.Id;
        lsd8.Next_Reminder_Date_For_MD_Approval__c = null;
        
        Legal_Sales_Document__c lsd9 = new Legal_Sales_Document__c();
        lsd9.Status_of_LSD__c = 'No LSD';
        lsd9.Total_Net_Sales_Value__c = 24324324;
        lsd9.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd9.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd9.Leading_Business_Segment__c = 'Africa';
        lsd9.Business_Group__c = 'CD';
        lsd9.FC_Legal_Entity__c = 'Alaska Milk Corporation';
        lsd9.Parent_Account__c = acc.Id;
        lsd9.Account_Name__c = acc2.Id;
        lsd9.Next_Reminder_Date_For_MD_Approval__c = null;
        
         Legal_Sales_Document__c lsd10 = new Legal_Sales_Document__c();
        lsd10.Status_of_LSD__c = 'No LSD';
        lsd10.Total_Net_Sales_Value__c = 24324324;
        lsd10.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd10.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd10.Leading_Business_Segment__c = 'Africa';
        lsd10.Business_Group__c = 'CD & SN';
        lsd10.FC_Legal_Entity__c = 'Alaska Milk Corporation';
        lsd10.Parent_Account__c = acc.Id;
        lsd10.Account_Name__c = acc2.Id;
        lsd10.Next_Reminder_Date_For_MD_Approval__c = null;
        
        
        
         Legal_Sales_Document__c lsd12 = new Legal_Sales_Document__c();
        lsd12.Status_of_LSD__c = 'No LSD';
        lsd12.Total_Net_Sales_Value__c = 24324324;
        lsd12.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd12.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd12.Leading_Business_Segment__c = 'China';
        lsd12.Business_Group__c = 'SN';
        lsd12.FC_Legal_Entity__c = 'Campina LLC';
        lsd12.Parent_Account__c = acc.Id;
        lsd12.Account_Name__c = acc2.Id;
        lsd12.Next_Reminder_Date_For_MD_Approval__c = null;
        
         Legal_Sales_Document__c lsd13 = new Legal_Sales_Document__c();
        lsd13.Status_of_LSD__c = 'No LSD';
        lsd13.Total_Net_Sales_Value__c = 24324324;
        lsd13.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd13.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd13.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd13.Business_Group__c = 'FCI & FCP';
        lsd13.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd13.Account_Name__c = acc2.Id;
        lsd13.Parent_Account__c = acc.Id;
        lsd13.Next_Reminder_Date_For_MD_Approval__c = null;
 //----------------------------------------------------------------------------------------------------------------------
 
 Legal_Sales_Document__c lsd14 = new Legal_Sales_Document__c();
        lsd14.Status_of_LSD__c = 'No LSD';
        lsd14.Total_Net_Sales_Value__c = 24324324;
        lsd14.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd14.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd14.Leading_Business_Segment__c = 'Africa';
        lsd14.Business_Group__c = 'CD';
        lsd14.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd14.Parent_Account__c = acc.Id;
        lsd14.Account_Name__c = acc2.Id;
        lsd14.Next_Reminder_Date_For_MD_Approval__c = system.today();
        
         Legal_Sales_Document__c lsd15 = new Legal_Sales_Document__c();
        lsd15.Status_of_LSD__c = 'No LSD';
        lsd15.Total_Net_Sales_Value__c = 24324324;
        lsd15.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd15.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd15.Leading_Business_Segment__c = 'China';
        lsd15.Business_Group__c = 'SN';
        lsd15.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd15.Parent_Account__c = acc.Id;
        lsd15.Account_Name__c = acc2.Id;
        lsd15.Next_Reminder_Date_For_MD_Approval__c = system.today();
        
         Legal_Sales_Document__c lsd16 = new Legal_Sales_Document__c();
        lsd16.Status_of_LSD__c = 'No LSD';
        lsd16.Total_Net_Sales_Value__c = 24324324;
        lsd16.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd16.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd16.Leading_Business_Segment__c = 'China';
        lsd16.Business_Group__c = 'CD & SN';
        lsd16.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd16.Parent_Account__c = acc.Id;
        lsd16.Account_Name__c = acc2.Id;
        lsd16.Next_Reminder_Date_For_MD_Approval__c = system.today();
        
        //-------------------------- FCI -----------------------------
        Legal_Sales_Document__c lsd17 = new Legal_Sales_Document__c();
        lsd17.Status_of_LSD__c = 'No LSD';
        lsd17.Total_Net_Sales_Value__c = 24324324;
        lsd17.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd17.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd17.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd17.Business_Group__c = 'FCI';
        lsd17.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd17.Account_Name__c = acc2.Id;
        lsd17.Parent_Account__c = acc.Id;
        lsd17.Next_Reminder_Date_For_MD_Approval__c = system.today();
        
         Legal_Sales_Document__c lsd18 = new Legal_Sales_Document__c();
        lsd18.Status_of_LSD__c = 'No LSD';
        lsd18.Total_Net_Sales_Value__c = 24324324;
        lsd18.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd18.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd18.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd18.Business_Group__c = 'FCI & FCP';
        lsd18.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd18.Account_Name__c = acc2.Id;
        lsd18.Parent_Account__c = acc.Id;
        lsd18.Next_Reminder_Date_For_MD_Approval__c = system.today();        
        
        
         Legal_Sales_Document__c lsd21 = new Legal_Sales_Document__c();
        lsd21.Status_of_LSD__c = 'No LSD';
        lsd21.Total_Net_Sales_Value__c = 24324324;
        lsd21.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd21.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd21.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd21.Business_Group__c = 'FCI';
        lsd21.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd21.Account_Name__c = acc2.Id;
        lsd21.Parent_Account__c = acc.Id;
        lsd21.Next_Reminder_Date_For_MD_Approval__c = system.today();
        
        Legal_Sales_Document__c lsd22 = new Legal_Sales_Document__c();
        lsd22.Status_of_LSD__c = 'No LSD';
        lsd22.Total_Net_Sales_Value__c = 24324324;
        lsd22.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd22.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd22.Leading_Business_Segment__c = 'Africa';
        lsd22.Business_Group__c = 'CD';
        lsd22.FC_Legal_Entity__c = 'Alaska Milk Corporation';
        lsd22.Parent_Account__c = acc.Id;
        lsd22.Account_Name__c = acc2.Id;
        lsd22.Next_Reminder_Date_For_MD_Approval__c = system.today();
        
         Legal_Sales_Document__c lsd23 = new Legal_Sales_Document__c();
        lsd23.Status_of_LSD__c = 'No LSD';
        lsd23.Total_Net_Sales_Value__c = 24324324;
        lsd23.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd23.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd23.Leading_Business_Segment__c = 'Africa';
        lsd23.Business_Group__c = 'CD & SN';
        lsd23.FC_Legal_Entity__c = 'Alaska Milk Corporation';
        lsd23.Parent_Account__c = acc.Id;
        lsd23.Account_Name__c = acc2.Id;
        lsd23.Next_Reminder_Date_For_MD_Approval__c = system.today();        
       
        
         Legal_Sales_Document__c lsd25 = new Legal_Sales_Document__c();
        lsd25.Status_of_LSD__c = 'No LSD';
        lsd25.Total_Net_Sales_Value__c = 24324324;
        lsd25.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd25.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd25.Leading_Business_Segment__c = 'China';
        lsd25.Business_Group__c = 'SN';
        lsd25.FC_Legal_Entity__c = 'Campina LLC';
        lsd25.Parent_Account__c = acc.Id;
        lsd25.Account_Name__c = acc2.Id;
        lsd25.Next_Reminder_Date_For_MD_Approval__c = system.today();
        
         Legal_Sales_Document__c lsd26 = new Legal_Sales_Document__c();
        lsd26.Status_of_LSD__c = 'No LSD';
        lsd26.Total_Net_Sales_Value__c = 24324324;
        lsd26.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd26.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd26.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd26.Business_Group__c = 'FCI & FCP';
        lsd26.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd26.Account_Name__c = acc2.Id;
        lsd26.Parent_Account__c = acc.Id;
        lsd26.Next_Reminder_Date_For_MD_Approval__c = system.today();        
 
        
        
        
       List<Legal_Sales_Document__c> lsdList = new List<Legal_Sales_Document__c>();
        
        
        lsdList.add(lsd14);
        lsdList.add(lsd15);
        lsdList.add(lsd16);
        lsdList.add(lsd17);
         lsdList.add(lsd18);
         lsdList.add(lsd21);
        lsdList.add(lsd22);
         lsdList.add(lsd23);
        lsdList.add(lsd25);
         lsdList.add(lsd26);
        
         lsdList.add(lsd13);
        lsdList.add(lsd12);
        lsdList.add(lsd10);
         lsdList.add(lsd9);
        lsdList.add(lsd8);
        lsdList.add(lsd5);
         lsdList.add(lsd4);
        lsdList.add(lsd);
        lsdList.add(lsd3);
         lsdList.add(lsd2);
       
        insert lsdList;
        
       test.setCreatedDate(lsd.id, system.today().addMonths(-3));
        test.setCreatedDate(lsd2.id, system.today().addMonths(-3));
       test.setCreatedDate(lsd3.id, system.today().addMonths(-3));
         test.setCreatedDate(lsd4.id, system.today().addMonths(-3));
         test.setCreatedDate(lsd5.id, system.today().addMonths(-3));
         test.setCreatedDate(lsd8.id, system.today().addMonths(-3));
        test.setCreatedDate(lsd9.id, system.today().addMonths(-3));
        test.setCreatedDate(lsd10.id, system.today().addMonths(-3));
         test.setCreatedDate(lsd12.id, system.today().addMonths(-3));
         test.setCreatedDate(lsd13.id, system.today().addMonths(-3));
    
        test.setCreatedDate(lsd14.id, date.newInstance(2015, 3, 1));
         test.setCreatedDate(lsd15.id, date.newInstance(2015, 3, 1));
        test.setCreatedDate(lsd16.id, date.newInstance(2015, 3, 1));
        test.setCreatedDate(lsd17.id, date.newInstance(2015, 3, 1));
         test.setCreatedDate(lsd18.id, date.newInstance(2015, 3, 1));
         test.setCreatedDate(lsd21.id, date.newInstance(2015, 3, 1));
        test.setCreatedDate(lsd22.id, date.newInstance(2015, 3, 1));
        test.setCreatedDate(lsd23.id, date.newInstance(2015, 3, 1));
        test.setCreatedDate(lsd25.id, date.newInstance(2015, 3, 1));
        test.setCreatedDate(lsd26.id, date.newInstance(2015, 3, 1));
        
        update lsdList;
    }
    static testmethod void checkBatchClassForEmailReminderofLSDOwner() {
       Test.startTest();
        LSDEmailNotificationScheduler sh = new LSDEmailNotificationScheduler();
         String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh);
        Test.stopTest();
    }
    static testmethod void checkBatchForSendingReminderForExistingLsd() {
        test.startTest();
        BatchForSendingReminderForExistingLsd b = new BatchForSendingReminderForExistingLsd();
          database.executeBatch(b,200);
        test.stopTest();
    }
}