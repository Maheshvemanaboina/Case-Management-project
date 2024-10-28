@isTest
public class UploadFileCtlrTest {

    Public Static testmethod void insertUser(){
          User sampleUser = DataFactoryTest.getCPQstdUser();
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
            insert sampleUser;
            PermissionSetAssignment[] assignments = new PermissionSetAssignment[]{};
            for ( PermissionSet permissionSet : DataFactoryTest.getCPQpermissions() ) {
                assignments.add(new PermissionSetAssignment(
                    PermissionSetId = permissionSet.Id,
                    AssigneeId      = sampleUser.Id
                ));
            }
            insert assignments;
        }
        EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId=UserInfo.getUserId(),   TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
           insert e;
    } 

    Public static testMethod Void test(){
         TriggerHandler.skipTrigger = True;
         final String PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME          = 'BGI_Product_SKU';
        
        Account sampleAccount = DataFactoryTest.getAccountCommercialCustomers( 1 )[ 0 ];
        sampleAccount.OwnerId       = userInfo.getUserId();
        sampleAccount.SAP_Number__c = '0000100655';
        sampleAccount.SAP_Number_PE1__c = '0000100655';
        Database.insert( sampleAccount );
        set<string> accSap = new set<string>();
        accSap.add(sampleAccount.SAP_Number_PE1__c);
        
        Contact sampleContact = DataFactoryTest.getContacts( 1 )[ 0 ];
        sampleContact.OwnerId   = userInfo.getUserId();
        sampleContact.AccountId = sampleAccount.Id;
        sampleContact.Active__c=true;
        sampleContact.Email='test@gmail.com';
        Database.insert( sampleContact );
        
       Opportunity sampleOpportunity = DataFactoryTest.getOpportunityNewBusinesses( 1 )[ 0 ];
        sampleOpportunity.OwnerId   =userInfo.getUserId();
        sampleOpportunity.AccountId = sampleAccount.Id;
        sampleOpportunity.ContactId = sampleContact.Id;
       // sampleOpportunity.Business_Segment__c = 'Industry';
        //sampleOpportunity.Sub_Segment__c = 'Beverages';
        //sampleOpportunity.Opportunity_Application__c = 'Instant Mixes - Chocolate';
        //sampleOpportunity.Business_Segment__c = 'Cheese';
        //sampleOpportunity.Sub_Segment__c = 'Repackers';
        //sampleOpportunity.Opportunity_Application__c = 'Grated Cheese';
        sampleOpportunity.StageName = 'Prospecting';
        sampleOpportunity.Reason_Won_Lost__c = '';
        Database.insert( sampleOpportunity );
        
        Sales_Area__c salesArea = new Sales_Area__c(
            /*SALES_ORG__c          = '5953',*/
            Sales_Organization__c = '5953',
            Customer_Name__c = sampleOpportunity.AccountId,
            Active__c        = true,
            External_Key__c  ='0000100655-5953-01-10'
        );
        Database.insert( salesArea );
        set<string> salesId = new set<string>();
        salesId.add(salesArea.External_Key__c);
        
        Partner_Role__c p = new Partner_Role__c();
        p.Target_Account__c = sampleAccount.id;
        p.Source_Account__c = sampleAccount.id;
        p.Relation_Name__c = 'Ship To';
        p.External_Key__c = '0000100655-5953-01-10-WE-0000100655';
        p.Name ='ХХ OOO Optima';

        Database.insert(p);
        set<string> insertPartnerRole = new set<string>();
        insertPartnerRole.add(p.External_Key__c);
        
        List<Id> quoteIds = new List<Id>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            OwnerId                 = sampleOpportunity.OwnerId,
            SBQQ__Account__c        = sampleOpportunity.AccountId,
            SBQQ__Opportunity2__c   = sampleOpportunity.Id,
            SBQQ__PriceBook__c      = Test.getStandardPricebookId(),
            SBQQ__Primary__c        = true,
            SBQQ__PrimaryContact__c = sampleOpportunity.ContactId,
            Sales_Area__c           = salesArea.Id,
            SBQQ__Status__c 		= 'Accepted by customer',
            Reason_Opportunity_Won_Loss__c = 'Strong Relationship',
            EffectiveDate__c        = System.today(),
            SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
            SBQQ__StartDate__c      = System.today().addMonths( 2 ),
            SBQQ__EndDate__c        = System.today().addMonths( 3 )
        );
        Database.insert( quote );
         List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>{
            new SBQQ__QuoteLineGroup__c(
                Name                    = 'Group 1',
                SBQQ__Quote__c          = quote.Id,
                SBQQ__Account__c        = sampleOpportunity.AccountId,
                Sales_Area__c           = salesArea.Id,
                Mode_of_Transport__c    = 'Sea',
                IncoTerms__c            = 'CIP',
                IncoTermsDestination__c = 'Amsterdam Schiphol'
                
                
            )
        };
          Database.insert( groups ); 
        List<Product2> records = new List<Product2>();
        records.add( new Product2(
                Name               = 'Sample Product ',
                RecordTypeId       = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId(),
                ProductCode        = 'Pro-00000000',
                IsActive           = true
            ));
        Database.insert(records);
        
         List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        lines.add( new SBQQ__QuoteLine__c(
                SBQQ__Quote__c     = quote.Id,
                SBQQ__Group__c     = groups[ 0 ].Id,
                SBQQ__Product__c   = records[0].Id,
                Product_RecordType_DeveloperName__c='BGI_Product_SKU',
                SBQQ__Quantity__c  = 5,
                Unit_of_measure__c = 'KG',
                SBQQ__ListPrice__c = 1
            ));
        Database.insert(lines);
        
        
        quoteIds.add(quote.Id);
        
        PGMEmailSetting__c cusSet = new PGMEmailSetting__c();
        cusSet.Name='Other';
        cusSet.PGM_1__c ='mohan.g@kvpcorp.com';
        cusSet.PGM_2__c  ='mohan.g@kvpcorp.com';
        cusSet.PGM_3__c  = 'mohan.g@kvpcorp.com';
        insert cusSet;
        TriggerHandler.skipTrigger = false;
        string fname = 'InsertQLGS';
        string insertQuote = quote.Id;
        set<string> userEmail = new set<string>();
        userEmail.add(userInfo.getUserEmail());
        test.startTest();
     	String fileName = 'file_4,file_5,Test_1,Test_1,file_1,file_2,file_3,file_4,5,1,4,5,11,1,1,2,3,4,5,1,1,1,1,2,3,4,5,1'+'\n'+'file_4,file_5,Test_1,Test_1,file_1,file_2,file_3,file_4,5,1,4,5,11,1,1,2,3,4,5,1,1,1,1,2,3,4,5,1';
        UploadFileCtlr.getCSVObject(fileName,insertQuote , fname);
        UploadFileCtlr.getSalesAreas(salesId, true);
        UploadFileCtlr.getAccounts(accSap, true);
        UploadFileCtlr.getPartnerRoles(insertPartnerRole,true); 
        UploadFileCtlr.getUsers(userEmail);
        UploadFileCtlr.removeLeadingzeros('1');
        UploadFileCtlr.saveFile(insertQuote,fileName,'insertfname');
        test.stopTest();

        
        
        
    }
    
}