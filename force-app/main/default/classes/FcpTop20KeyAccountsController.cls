/**
 * FcpTop20KeyAccountsController class is created get Account Details and Related ChildAccounts
 * Created By :   Charan K.
 * Crated Date :  20/09/2024.
 */
public without sharing class FcpTop20KeyAccountsController {

    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getTop20KeyAccounts() {
        List<AccountWrapper> accountList = new List<AccountWrapper>();
        Date firstDayOfYear = Date.newInstance(Date.today().year(), 1, 1);
        //Date lastDayOfYear = Date.newInstance(Date.today().year(), 12, 31);
        List<Account> accounts = [
            SELECT Id, Name, FCP_Top_20_KA__c, Account_Plan_for_FCP_T20_KA__c, 
                (SELECT Id, Volume_MT__c, StageName FROM Opportunities),
                (SELECT Id, Status__c FROM Visit_Reports__r  WHERE Visit_Date__c >= :firstDayOfYear),
                (SELECT Id, SBQQ__Primary__c, SBQQ__Status__c FROM SBQQ__Quotes__r WHERE SBQQ__StartDate__c >= :firstDayOfYear),
                (SELECT Id FROM Call_Notes__r WHERE Call_Date__c >= :firstDayOfYear),
                (SELECT Id, Gross_Price__c, Status FROM Contracts WHERE StartDate >= :firstDayOfYear),
                (SELECT Id FROM Field_of_Play__r),
                (SELECT Id FROM Contacts),
                (SELECT Id, Status FROM Cases),
                (SELECT Id FROM Tasks),
                (SELECT Id FROM Activities__r)
            FROM Account 
            WHERE FCP_Top_20_KA__c = true 
            LIMIT 20
        ];

        for (Account acc : accounts) {
            Decimal totalOpportunityVolume = 0;
            for (Opportunity opp : acc.Opportunities) {
                if(opp.Volume_MT__c !=null && opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' && opp.StageName != 'On Hold'){
                    totalOpportunityVolume += opp.Volume_MT__c;
                }
            }

            Integer preVisitReportCount = 0;
            Integer finalVisitReportCount = 0;
            for (Visit_Report__c report : acc.Visit_Reports__r) {
                if (report.Status__c == 'Pre-Visit Report') {
                    preVisitReportCount++;
                }else if ( report.Status__c == 'Final Report') {
                    finalVisitReportCount++;
                }
            }

            Integer quotesCount = 0;
            for (SBQQ__Quote__c quote : acc.SBQQ__Quotes__r) {
                if(quote.SBQQ__Primary__c == true && quote.SBQQ__Status__c =='Accepted by customer' ){
                    quotesCount++;
                }
            }

            totalOpportunityVolume = Math.floor(totalOpportunityVolume);
            Integer casesCount = 0;
            for (Case cas : acc.Cases) {
                if (cas.Status != 'Closed'){
                    casesCount++;
                }
            }

            Decimal totalContractPrice = 0;
            for (Contract contr : acc.Contracts) {
                if(contr.Gross_Price__c !=null && contr.Status != 'Closed' && contr.Status != 'Expired(Partially Referenced)'){
                    totalContractPrice += contr.Gross_Price__c;
                }
            }
            totalContractPrice = Math.floor(totalContractPrice);

            Boolean hasAccountPlans = acc.Account_Plan_for_FCP_T20_KA__c != null;
            Integer contactsCount = acc.Contacts.size();
            Integer callNotesCount = acc.Call_Notes__r.size();           
            Integer tasksCount = acc.Tasks.size();
            Integer activityCount = acc.Activities__r.size();
            accountList.add(new AccountWrapper(acc, contactsCount, totalOpportunityVolume, quotesCount, preVisitReportCount, finalVisitReportCount, hasAccountPlans, casesCount, callNotesCount, totalContractPrice, tasksCount, activityCount));
        }
        return accountList;
    }

    // Wrapper class to return both Account and Visit Report Count
    public class AccountWrapper {
        @AuraEnabled public Account account { get; set; }
        @AuraEnabled public Integer contactsCount { get; set; }
        @AuraEnabled public Decimal totalOpportunityVolume { get; set; }
        @AuraEnabled public Integer quotesCount { get; set; }
        @AuraEnabled public Integer preVisitReportCount { get; set; }
        @AuraEnabled public Integer finalVisitReportCount { get; set; }
        @AuraEnabled public Boolean hasAccountPlans { get; set; }
        @AuraEnabled public Integer casesCount { get; set; }
        @AuraEnabled public Integer callNotesCount { get; set; }
        @AuraEnabled public Decimal totalContractPrice { get; set; }
        @AuraEnabled public Integer tasksCount { get; set; }
        @AuraEnabled public Integer activityCount { get; set; }

        //public AccountWrapper(Account account, Integer visitReportCount, Integer accountPlanCount) {
        public AccountWrapper(Account account, Integer contactsCount, Decimal totalOpportunityVolume, Integer quotesCount, Integer preVisitReportCount, Integer finalVisitReportCount, Boolean hasAccountPlans, Integer casesCount, Integer callNotesCount, Decimal totalContractPrice, Integer tasksCount, Integer activityCount) {
            this.account = account;
            this.contactsCount = contactsCount;
            this.totalOpportunityVolume = totalOpportunityVolume;
            this.quotesCount = quotesCount;
            this.preVisitReportCount = preVisitReportCount;
            this.finalVisitReportCount = finalVisitReportCount;
            this.hasAccountPlans = hasAccountPlans;
            this.casesCount = casesCount;
            this.callNotesCount = callNotesCount;
            this.totalContractPrice = totalContractPrice;
            this.tasksCount = tasksCount;
            this.activityCount = activityCount;
        }
    }

    // Fetch related Opportunities for a specific Account 
    @AuraEnabled
    public static List<Opportunity> getOpportunitiesByAccountId(String accountId) {
        Date firstDayOfYear = Date.newInstance(Date.today().year(), 1, 1);
        return [
            SELECT Id, Name, Amount, Volume_MT__c, StageName, CloseDate, Probability, AccountId   
            FROM Opportunity 
            WHERE AccountId = :accountId AND StageName != 'Closed Won' AND StageName != 'Closed Lost' AND StageName != 'On Hold'
        ];
    }

    // Fetch related Quotes for a specific Account 
    @AuraEnabled
    public static List<SBQQ__Quote__c> getQuotesByAccountId(String accountId) {
        Date firstDayOfYear = Date.newInstance(Date.today().year(), 1, 1);
        return [
            SELECT Id, Name, SBQQ__Opportunity2__r.Name, SBQQ__Status__c, SBQQ__NetAmount__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Account__c   
            FROM SBQQ__Quote__c  
            WHERE SBQQ__Account__c = :accountId AND SBQQ__Primary__c =true AND SBQQ__Status__c ='Accepted by customer' 
            AND SBQQ__StartDate__c >= :firstDayOfYear
        ];
    }

    // Fetch related Visit Reports for a specific Account
    @AuraEnabled
    public static List<Visit_Report__c> getPreVisitReportsByAccountId(String accountId) {
        Date firstDayOfYear = Date.newInstance(Date.today().year(), 1, 1);
        return [
            SELECT Id, Name, Purpose_of_the_Visit__c, Status__c, Customer_Name__c, Visit_Type__c, Visit_Date__c  
            FROM Visit_Report__c
            WHERE Customer_Name__c = :accountId AND Status__c= 'Pre-Visit Report' 
            AND Visit_Date__c >= :firstDayOfYear
        ];
    }

    @AuraEnabled
    public static List<Visit_Report__c> getFinalVisitReportsByAccountId(String accountId) {
        Date firstDayOfYear = Date.newInstance(Date.today().year(), 1, 1);
        return [
            SELECT Id, Name, Purpose_of_the_Visit__c, Status__c, Customer_Name__c, Visit_Type__c, Visit_Date__c  
            FROM Visit_Report__c
            WHERE Customer_Name__c = :accountId AND Status__c ='Final Report' AND Visit_Date__c >= :firstDayOfYear
        ];
    }

    // Fetch related Contracts for a specific Account 
    @AuraEnabled
    public static List<Contract> getContractsByAccountId(String accountId) {
        Date firstDayOfYear = Date.newInstance(Date.today().year(), 1, 1);
        return [
            SELECT Id, ContractNumber, SAP_Contract_Number__c, Gross_Price__c, StartDate, EndDate, Status, AccountId  
            FROM Contract
            WHERE AccountId = :accountId AND Status != 'Closed' AND Status != 'Expired(Partially Referenced)' AND StartDate >= :firstDayOfYear
        ];
    }

    // Fetch related Call Notes for a specific Account 
    @AuraEnabled
    public static List<Call_Notes__c> getCallNotesByAccountId(String accountId) {
        Date firstDayOfYear = Date.newInstance(Date.today().year(), 1, 1);
        return [
            SELECT Id, Name, Call_Date__c, Type__c, Conclusion__c, Customer_Name__c  
            FROM Call_Notes__c
            WHERE Customer_Name__c = :accountId AND Call_Date__c >= :firstDayOfYear
        ];
    }

     // Fetch related Field of Play Account Plans for a specific Account
    @AuraEnabled
    public static List<Account> getAccountPlansByAccountId(String accountId) {
        return [ SELECT Account_Plan_for_FCP_T20_KA_Name__c, Account_Plan_for_FCP_T20_KA__c FROM Account WHERE Id = :accountId LIMIT 1 ];
    }

    // Fetch related Contacts for a specific Account 
    @AuraEnabled
    public static List<Contact> getContactsByAccountId(String accountId) {
        return [
            SELECT Id, Name, Department__c, Job_Title__c, Email, AccountId  
            FROM Contact
            WHERE AccountId = :accountId
        ];
    }

    // Fetch related Cases for a specific Account 
    @AuraEnabled
    public static List<Case> getCasesByAccountId(String accountId) {
        return [
            SELECT Id, CaseNumber, Subject, Status, Customer_Type__c, AccountId  
            FROM Case
            WHERE AccountId = :accountId AND Status != 'Closed'
        ];
    }

    // Fetch related Tasks for a specific Account 
    @AuraEnabled
    public static List<Task> getTasksByAccountId(String accountId) {
        return [
            SELECT Id, SF_Task_Number__c, Subject, Status, Priority, Account_Name__c 
            FROM Task
            WHERE Account_Name__c = :accountId
        ];
    }

    // Fetch related Activity for a specific Account 
    @AuraEnabled
    public static List<Task> getActivitiesByAccountId(String accountId) {
        return [
            SELECT Id, SF_Task_Number__c, ActivityDate, Subject, Status, Priority, AccountId 
            FROM Task
            WHERE AccountId = :accountId
        ];
    }

    // Upload file
    @AuraEnabled
    public static Id saveFile(String fileName, String base64Data, String contentType, Id recordId) {
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            contentVersion.FirstPublishLocationId = recordId; // Link to a record
            contentVersion.ContentLocation = 'S';
            insert contentVersion;
            return contentVersion.Id;
    }

    // Fetch file associated with a record
    @AuraEnabled
    public static List<ContentVersion> getFiles() {
        return [
            SELECT Id ,ContentDocumentId, FileExtension, VersionDataUrl 
            FROM ContentVersion 
            WHERE Title LIKE '%Top 20 Key Accounts%'
            AND IsLatest = true
            LIMIT 1
        ];
    }
    
    // Delete file by ContentDocumentId
    @AuraEnabled
    public static void deleteFile(Id contentDocumentId) {
        contentDocument cdl = [
            SELECT Id 
            FROM contentDocument 
            WHERE Id = :contentDocumentId 
            LIMIT 1
        ];
        delete cdl;
    }
    
    @AuraEnabled
    public static String getCurrentUserProfileName() {
        User user = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        return user.Profile.Name;
    }
}