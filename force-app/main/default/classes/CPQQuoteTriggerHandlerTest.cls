@IsTest
private class CPQQuoteTriggerHandlerTest {
    @TestSetup
    private static void testSetup() {
        Account accobj = TestUtility.createAccount('FCI Test 1');
        insert accobj; 
        Account accobj2 = TestUtility.createAccount('Test 2');
        accobj2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId();
        insert accobj2;

        Contact ct = TestUtility.createContact(accobj, accobj2);
        ct.Business_Segment__c = 'Adult Nutrition';
        insert ct;
        
        Opportunity opp = TestUtility.createOpportunity('testOppname', Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID, accobj, accobj2);
        opp.Name = 'Clone Test Opp';
        opp.OwnerId = UserInfo.getUserId();
        opp.CloseDate = System.today();
        opp.Business_Segment__c = 'Adult Nutrition';
        insert opp;

        // Create a test product //
        List<Product2> testProducts = DataFactoryTest.getProductSKUs(2);

        Database.insert(testProducts);

        Pricebook2 priceBookObj = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        Database.update(priceBookObj);

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProducts) {
            pricebookEntries.add(new PricebookEntry(UnitPrice = 0.01, Product2Id = prod.Id, Pricebook2Id = priceBookObj.Id,
                    IsActive = true, UseStandardPrice = false));
        }
        Database.insert(pricebookEntries);

        Sales_Area__c salesArea = new Sales_Area__c(
                Sales_Organization__c = '5953',
                Customer_Name__c = opp.AccountId,
                Active__c        = true
        );
        Database.insert(salesArea);
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
                OwnerId                 = opp.OwnerId,
                SBQQ__Account__c        = opp.AccountId,
                SBQQ__Opportunity2__c   = opp.Id,
                SBQQ__PricebookId__c    = priceBookObj.Id,
                SBQQ__Primary__c        = true,
                SBQQ__Status__c         = 'Draft',
                SBQQ__PrimaryContact__c = ct.Id,
                Sales_Area__c           = salesArea.Id,
                EffectiveDate__c        = System.today(),
                SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
                SBQQ__StartDate__c      = System.today().addMonths( 2 ),
                SBQQ__EndDate__c        = System.today().addMonths( 3 ),
                CMO__c                  = UserInfo.getUserId(),
                Payment_Terms__c        = 'Z012'
        );
        Database.insert(testQuote);
        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>{
                new SBQQ__QuoteLineGroup__c(
                        Name                    = 'Test Group 1',
                        SBQQ__Quote__c          = testQuote.Id,
                        SBQQ__Account__c        = opp.AccountId,
                        Mode_of_Transport__c    = 'Sea',
                        IncoTerms__c            = 'CIP',
                        IncoTermsDestination__c = 'Amsterdam Schiphol',
                        SBQQ__StartDate__c      = System.today().addMonths(2),
                        SBQQ__EndDate__c        = System.today().addMonths(3),
                        Type__c                 = 'ZQTC',
                        Ship_To_Customer__c     = accobj.Id
                ),
                new SBQQ__QuoteLineGroup__c(
                        Name                    = 'Test Group 2',
                        SBQQ__Quote__c          = testQuote.Id,
                        SBQQ__Account__c        = opp.AccountId,
                        Mode_of_Transport__c    = 'Sea',
                        IncoTerms__c            = 'CIP',
                        IncoTermsDestination__c = 'Amsterdam Schiphol',
                        SBQQ__StartDate__c      = System.today().addMonths(2),
                        SBQQ__EndDate__c        = System.today().addMonths(3),
                        Type__c                 = 'ZQTC',
                        Ship_To_Customer__c     = accobj.Id
                )
        };
        Database.insert(groups);

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            SBQQ__QuoteLine__c newLine = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = testQuote.Id,
                SBQQ__Group__c              = groups[0].Id,
                SBQQ__Product__c            = pricebookEntry.Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntry.Id,
                SBQQ__Quantity__c           = 5,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 1,
                ZVA0__c                     = -0.17,
                SBQQ__NetPrice__c           = 100.00,
                Within_Validity_Period__c   = true
            );
            lines.add(newLine);
        }

        Database.insert(lines);

        // this is to remove wrong test data from flow
        delete [SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE Name = 'Group 1'];
    }

    @IsTest
    private static void testBeforeUpdateInvalidQLG() {
        SBQQ__Quote__c currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, CMO_Validation_Completed__c, Reason_Opportunity_Won_Loss__c FROM SBQQ__Quote__c];
        SBQQ__QuoteLineGroup__c qlg = [SELECT IncoTermsDestination__c FROM SBQQ__QuoteLineGroup__c LIMIT 1];
        Boolean mandatoryExceptionHappened = false;

        Test.startTest();
        SBQQ.TriggerControl.disable();
        try {

            qlg.IncoTermsDestination__c = null;
            update qlg;

            currentQuote.SBQQ__Status__c = 'Commercial Approval';
            update currentQuote;
        }
        catch(Exception ex) {
            System.debug('testBeforeUpdate exception message: ' + ex.getMessage());
            if (ex.getMessage().contains('It is mandatory to fill in the fields \'IncoTerms Destination\' on the')) {
                mandatoryExceptionHappened = true;
            }
        }
        SBQQ.TriggerControl.enable();
        Test.stopTest();
        System.assertEquals(true, mandatoryExceptionHappened, 'mandatory fields exception happened assertion');
    }

    @IsTest
    private static void testBeforeUpdateInvalidQL() {
        SBQQ__Quote__c currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, CMO_Validation_Completed__c, Reason_Opportunity_Won_Loss__c FROM SBQQ__Quote__c];
        Boolean mandatoryExceptionHappened = false;
        List<PricebookEntry> pricebookEntries = [SELECT Id,Product2Id FROM PricebookEntry];
        SBQQ__QuoteLineGroup__c firstLineGroup = [SELECT Id, Name, SBQQ__Quote__c, Mode_of_Transport__c, IncoTerms__c, IncoTermsDestination__c, SBQQ__StartDate__c, SBQQ__EndDate__c FROM SBQQ__QuoteLineGroup__c WHERE Name='Test Group 1'];
        firstLineGroup.Mode_of_Transport__c    = 'Sea';
        firstLineGroup.IncoTerms__c            = 'CIP';
        firstLineGroup.IncoTermsDestination__c = 'Amsterdam Schiphol';
        firstLineGroup.SBQQ__StartDate__c      = System.today().addMonths(2);
        firstLineGroup.SBQQ__EndDate__c        = System.today().addMonths(3);
        update firstLineGroup;

        Test.startTest();
        SBQQ.TriggerControl.disable();

        SBQQ__QuoteLine__c newLine = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = firstLineGroup.SBQQ__Quote__c,
                SBQQ__Group__c              = firstLineGroup.Id,
                SBQQ__Product__c            = pricebookEntries[0].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[0].Id,
                SBQQ__Quantity__c           = 5,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 1
            );
        insert newLine;
        try {
            currentQuote.SBQQ__Status__c = 'Commercial Approval';
            update currentQuote;
        }
        catch(Exception ex) {
            System.debug('testBeforeUpdate exception message: ' + ex.getMessage());
            if (ex.getMessage().contains('It is mandatory to fill in the fields \'Offered Customer Price (Unit)\',\'ZVA0\' on the')) {
                mandatoryExceptionHappened = true;
            }
        }
        SBQQ.TriggerControl.enable();
        Test.stopTest();
        System.assertEquals(true, mandatoryExceptionHappened, 'mandatory fields exception happened assertion');
    }

    @IsTest
    private static void testBeforeUpdateInvalidQuote() {
        SBQQ__Quote__c currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, CMO_Validation_Completed__c, Reason_Opportunity_Won_Loss__c, Payment_Terms__c, SBQQ__SalesRep__c FROM SBQQ__Quote__c];
        Boolean mandatoryExceptionHappened = false;
        List<PricebookEntry> pricebookEntries = [SELECT Id,Product2Id FROM PricebookEntry];
        SBQQ__QuoteLineGroup__c firstLineGroup = [SELECT Id, Name, SBQQ__Quote__c, Mode_of_Transport__c, IncoTerms__c, IncoTermsDestination__c, SBQQ__StartDate__c, SBQQ__EndDate__c FROM SBQQ__QuoteLineGroup__c WHERE Name='Test Group 1'];
        firstLineGroup.Mode_of_Transport__c    = 'Sea';
        firstLineGroup.IncoTerms__c            = 'CIP';
        firstLineGroup.IncoTermsDestination__c = 'Amsterdam Schiphol';
        firstLineGroup.SBQQ__StartDate__c      = System.today().addMonths(2);
        firstLineGroup.SBQQ__EndDate__c        = System.today().addMonths(3);
        firstLineGroup.Type__c                 = 'ZQTC';
        update firstLineGroup;

        Test.startTest();
        SBQQ.TriggerControl.disable();

        try {
            // set mandatory fields as empty
            currentQuote.CMO__c = null;
            currentQuote.SBQQ__PrimaryContact__c = null;
            currentQuote.Payment_Terms__c = '';
            currentQuote.SBQQ__Status__c = 'Commercial Approval';
            update currentQuote;
        }
        catch(Exception ex) {
            System.debug('testBeforeUpdate exception message: ' + ex.getMessage());
            if (ex.getMessage().contains('It is mandatory to fill in the fields \'CMO\',\'Primary Contact\',\'Payment Terms\' on the Quote.')) {
                mandatoryExceptionHappened = true;
            }
        }
        SBQQ.TriggerControl.enable();
        Test.stopTest();
        System.assertEquals(true, mandatoryExceptionHappened, 'mandatory fields exception happened assertion');
    }

    @IsTest
    private static void testSmartApprovalLines() {
        SBQQ__Quote__c currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, CMO_Validation_Completed__c, Reason_Opportunity_Won_Loss__c, Payment_Terms__c, SBQQ__SalesRep__c FROM SBQQ__Quote__c];
        Boolean exceptionHappened = false;
        Test.startTest();
        SBQQ.TriggerControl.disable();
        try {
            currentQuote.SBQQ__Status__c = 'Commercial Approval';
            update currentQuote;
        }
        catch(Exception ex) {
            System.debug('testSmartApprovalLines exception message: ' + ex.getMessage());
            exceptionHappened = true;
        }
        SBQQ.TriggerControl.enable();
        Test.stopTest();
        System.assertEquals(false, exceptionHappened, 'testSmartApprovalLines exception didnt happened assertion');
        SBQQ__Quote__c currentUpdatedQuote = [SELECT Id, Approved_Delta_Price__c, Approved_Delta_Quantity__c, Approved_Incoterms__c FROM SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, ICF_Approved_FCA_Price__c, SBQQ__ListPrice__c, ICF_Approved_Quantity__c, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:currentUpdatedQuote.Id];
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = [SELECT Id, ICF_Approved_IncoTerms__c, IncoTerms__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c =:currentUpdatedQuote.Id];
        
        System.assertEquals(2, currentUpdatedQuote.Approved_Delta_Price__c, 'testSmartApprovalLines Approved_Delta_Price__c assertion');
        System.assertEquals(2, currentUpdatedQuote.Approved_Delta_Quantity__c, 'testSmartApprovalLines Approved_Delta_Quantity__c assertion');
        System.assertEquals(2, currentUpdatedQuote.Approved_Incoterms__c, 'testSmartApprovalLines Approved_Incoterms__c assertion');
        for (SBQQ__QuoteLine__c quoteline : quoteLines) {
            System.assertEquals(null, quoteline.ICF_Approved_FCA_Price__c, 'testSmartApprovalLines ICF_Approved_FCA_Price__c assertion');
            System.assertEquals(null, quoteline.ICF_Approved_Quantity__c, 'testSmartApprovalLines ICF_Approved_Quantity__c assertion');
        }
        for (SBQQ__QuoteLineGroup__c quotelineGroup : quoteLineGroups) {
            System.assertEquals(null, quotelineGroup.ICF_Approved_IncoTerms__c, 'testSmartApprovalLines ICF_Approved_IncoTerms__c assertion');
        }
    }

    @IsTest
    private static void testSmartApprovalLinesSentToCustomer() {
        SBQQ__Quote__c currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, CMO_Validation_Completed__c, Reason_Opportunity_Won_Loss__c, Payment_Terms__c, CMO__c, SBQQ__PrimaryContact__c, SBQQ__SalesRep__c FROM SBQQ__Quote__c];
        Boolean exceptionHappened = false;
        SBQQ__QuoteLineGroup__c firstLineGroup = [SELECT Id, Name, SBQQ__Quote__c, Mode_of_Transport__c, IncoTerms__c, IncoTermsDestination__c, SBQQ__StartDate__c, SBQQ__EndDate__c FROM SBQQ__QuoteLineGroup__c WHERE Name='Test Group 1'];
        firstLineGroup.Mode_of_Transport__c    = 'Sea';
        firstLineGroup.IncoTerms__c            = 'CIP';
        firstLineGroup.IncoTermsDestination__c = 'Amsterdam Schiphol';
        firstLineGroup.SBQQ__StartDate__c      = System.today().addMonths(2);
        firstLineGroup.SBQQ__EndDate__c        = System.today().addMonths(3);
        firstLineGroup.Type__c                 = 'ZQTC';
        update firstLineGroup;

        List<Account> accsToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsToInsert.add(commercialCust);

        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCust);
        customerLocDanone.BillingCountry = 'Poland';
        customerLocDanone.BillingCountryCode = 'PL';
        customerLocDanone.Business_Segment__c = 'Adult Nutrition';
        accsToInsert.add(customerLocDanone);
        insert accsToInsert;

        Contact danoneContact = TestUtility.createContact('John', 'Doe', commercialCust, customerLocDanone);
        danoneContact.Business_Segment__c = 'Adult Nutrition';
        insert danoneContact;

        List<User> usersToInsert = new List<User>();
        User usr = new User (
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard CPQ User Profile'].Id,
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                FirstName = 'first',
                LastName = 'last',
                Username = TestUtility.generateRandomUserName() + 'TestIMCDPoland',
                Country = 'Italy',
                Alias = 't1',
                Email = 'no@email.com',
                IsActive = true,
                Friesland_Campina_Role__c = 'CMO'
        );
        usersToInsert.add(usr);
        insert usersToInsert;

        Test.startTest();
        SBQQ.TriggerControl.disable();
        try {
            currentQuote.Payment_Terms__c = 'Z012';
            currentQuote.CMO__c = usr.Id;
            currentQuote.SBQQ__PrimaryContact__c = danoneContact.Id;
            currentQuote.SBQQ__Status__c = 'Commercial Approval';
            update currentQuote;
            currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, Payment_Terms__c FROM SBQQ__Quote__c WHERE Id = :currentQuote.Id];
            currentQuote.ApprovalStatus__c = 'Approved';
            update currentQuote;
            currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, Payment_Terms__c FROM SBQQ__Quote__c WHERE Id = :currentQuote.Id];
            currentQuote.CMO_Validation_Completed__c = true;
            update currentQuote;
            currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, Payment_Terms__c FROM SBQQ__Quote__c WHERE Id = :currentQuote.Id];
            currentQuote.ApprovalStatus__c = 'Approved';
            update currentQuote;
            currentQuote = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, Payment_Terms__c FROM SBQQ__Quote__c WHERE Id = :currentQuote.Id];
        }
        catch(Exception ex) {
            System.debug('testSmartApprovalLinesSentToCustomer exception message: ' + ex.getMessage());
            exceptionHappened = true;
        }
        SBQQ.TriggerControl.enable();
        Test.stopTest();
        System.assertEquals(false, exceptionHappened, 'testSmartApprovalLinesSentToCustomer exception didnt happened assertion');
        SBQQ__Quote__c currentUpdatedQuote = [SELECT Id, ICF_Approved_Payment_Terms__c, Payment_Terms__c, ICF_Approved_Contract_End_Date__c, SBQQ__EndDate__c, No_Approved_Quote_Lines__c, SBQQ__Status__c FROM SBQQ__Quote__c];
        System.assertEquals('Z012', currentUpdatedQuote.Payment_Terms__c, 'testSmartApprovalLinesSentToCustomer ICF_Approved_Payment_Terms__c assertion');
    }

    /**
     * on this test, no validation should run upon the change of quote status that happens on the flow 'Update Quote status as rejected by customer when opportunity is closed lost'
     */
    @IsTest
    private static void testOpportunityCloseLost() {
        Opportunity currentOppty = [SELECT Id, StageName FROM Opportunity];
        Boolean mandatoryExceptionHappened = false;

        Test.startTest();
        currentOppty.Reason_Won_Lost__c = 'Cancelled';
        currentOppty.StageName = 'Closed Lost';
        update currentOppty;
        Test.stopTest();
        Opportunity updatedOppty = [SELECT Id, StageName FROM Opportunity];
        SBQQ__Quote__c currentQuote = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c];
        System.assertEquals(true, updatedOppty.StageName.contains('Closed Lost'), 'opportunity stagename assertion');
        System.assertEquals('Rejected by customer', currentQuote.SBQQ__Status__c, 'quote status assertion');
    }
}