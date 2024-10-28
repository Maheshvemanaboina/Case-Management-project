public with sharing class KPIsSharingRecalculationHelpDeskCase {
    public static void createHelpDeskCase(List<User> deleteSharedKPIsUserList, Boolean isKpiRecalculationFromContact){
        
        Id CASE_RECORD_TYPE_HELP_DESK_CASE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Helpdesk_Case').getRecordTypeId();
        Id scoreHelpDeskQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Score_Helpdesk_Queue'].Id;
        List<Case> createHelpDeskCases = new List<Case>();
        
        for(User distiUser : deleteSharedKPIsUserList){
            if(
                distiUser.Community_User_Role__c == Constants.COMMUNITY_USER_ROLE_STANDARD_USER ||
                String.isBlank(distiUser.Community_User_Role__c) || isKpiRecalculationFromContact
            ){
                Case helpDeskCase = new Case(
                    RecordTypeId = CASE_RECORD_TYPE_HELP_DESK_CASE_ID,
                    AccountId = distiUser.Contact.AccountId,
                    ContactId = distiUser.ContactId,
                    OwnerId = scoreHelpDeskQueueId,
                    Parent_Account__c = distiUser.Contact.Parent_Account__c,
                    Status = 'New',
                    Subject = 'KPI Sharing Recalculation - '+distiUser.Name,
                    Description = setCaseDescription(distiUser.Id)
                );
                createHelpDeskCases.add(helpDeskCase);
            }
        }
        
        if(!createHelpDeskCases.isEmpty()) DAOUtilityWithoutShar.insertWithoutAccess(createHelpDeskCases);
    }
    
    static String setCaseDescription(Id userId){
        String description = '';
        
        description += 'To recalculate the KPI Sharing for this user, please run the below Apex Script from the Execute Anonymous window in Developer Console:-\n\n';
        
        description += 'Id userIdToRecalculate = \''+userId+'\';\n';
        description += 'String rowCauseMngrUser = \'Manager_User__c\', rowCauseStdUser = \'Standard_User__c\';\n\n';
        
        description += 'delete [SELECT Id FROM Business_Strategy__Share ';
        description += 'WHERE UserOrGroupId =: userIdToRecalculate AND (RowCause =: rowCauseMngrUser OR RowCause =: rowCauseStdUser) ';
        description += 'AND ParentId IN: (new Map<Id,Business_Strategy__c>([SELECT Id FROM BUsiness_Strategy__c])).keySet()];\n\n';
				
		description += 'delete [SELECT Id FROM Forecast_Accuracy__Share ';
        description += 'WHERE UserOrGroupId =: userIdToRecalculate AND (RowCause =: rowCauseMngrUser OR RowCause =: rowCauseStdUser) ';
        description += 'AND ParentId IN: (new Map<Id,Forecast_Accuracy__c>([SELECT Id FROM Forecast_Accuracy__c])).keySet()];\n\n';
				
		description += 'delete [SELECT Id FROM FCI_Customer_Support__Share ';
        description += 'WHERE UserOrGroupId =: userIdToRecalculate AND (RowCause =: rowCauseMngrUser OR RowCause =: rowCauseStdUser) ';
        description += 'AND ParentId IN: (new Map<Id,FCI_Customer_Support__c>([SELECT Id FROM FCI_Customer_Support__c])).keySet()];\n\n';
				
		description += 'delete [SELECT Id FROM Sales_Funnel__Share ';
        description += 'WHERE UserOrGroupId =: userIdToRecalculate AND (RowCause =: rowCauseMngrUser OR RowCause =: rowCauseStdUser) ';
        description += 'AND ParentId IN: (new Map<Id,Sales_Funnel__c>([SELECT Id FROM Sales_Funnel__c])).keySet()];\n\n';
				
		description += 'delete [SELECT Id FROM Field_of_Play__Share ';
        description += 'WHERE UserOrGroupId =: userIdToRecalculate AND (RowCause =: rowCauseMngrUser OR RowCause =: rowCauseStdUser) ';
        description += 'AND ParentId IN: (new Map<Id,Field_of_Play__c>([SELECT Id FROM Field_of_Play__c])).keySet()];\n\n';
				
		description += 'delete [SELECT Id FROM Commercial_Activity__Share ';
        description += 'WHERE UserOrGroupId =: userIdToRecalculate AND (RowCause =: rowCauseMngrUser OR RowCause =: rowCauseStdUser) ';
        description += 'AND ParentId IN: (new Map<Id,Commercial_Activity__c>([SELECT Id FROM Commercial_Activity__c])).keySet()];\n\n';
				
        description += 'BusinessStrategySharingBatch bsSB = new BusinessStrategySharingBatch();\n';
		description += 'Database.executeBatch(bsSB, 50);\n\n';

		description += 'CommercialActivitySharingBatch caSB = new CommercialActivitySharingBatch();\n';
		description += 'Database.executeBatch(caSB, 50);\n\n';

		description += 'SalesFunnelSharingBatch sfSB = new SalesFunnelSharingBatch();\n';
		description += 'Database.executeBatch(sfSB, 50);\n\n';

		description += 'ForecastAccuracySharingBatch faSB = new ForecastAccuracySharingBatch();\n';
		description += 'Database.executeBatch(faSB, 50);\n\n';

		description += 'FCICustomerSupportSharingBatch fcsSB = new FCICustomerSupportSharingBatch();\n';
		description += 'Database.executeBatch(fcsSB, 50);\n\n';

		description += 'AccountPlanSharingBatch apB = new AccountPlanSharingBatch();\n';
		description += 'Database.executeBatch(apB, 50);';
        
        return description;
    }
}