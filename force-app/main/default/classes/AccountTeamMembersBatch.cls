public with sharing class AccountTeamMembersBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        String stdAccTeamMembersQuery = 'select Id, UserId, AccountId, AccountAccessLevel, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel, TeamMemberRole, User.IsActive,User.Business_Segment__c, Business_Segment__c, Primary__c from AccountTeamMember where CreatedDate <= 2023-12-30T09:29:03Z and CreatedDate >= 2016-01-01T01:02:03Z';
        return Database.getQueryLocator(stdAccTeamMembersQuery);
    }

    public void execute(Database.BatchableContext batchContext, List<AccountTeamMember> stdAccTeamMembers) {
        List<AccountTeamMember> toUpdate = new List<AccountTeamMember>();
        list<Account_Team__c> newCustomAccTeamMemberList = new list<Account_Team__c>();
        List<String> primaryRoles = new List<String>{'Sales Manager','CMO','OFO'};
        List<String> customTeamRoles = new List<String>{'Sales Manager','CMO','OFO','CFO','Commercial Controller','Commercial Director','Demand Manager','Demand Planner','Manager S&OP','Marketing Director','Plan & Deliver Director','Pricing Manager','Product Developer','Product Group Manager','Product Manager','Project Principal','Quality Associate','Quality Manager','	R&D Associate','R&D Manager','Technical Sales Support','Logistic Account manager','QA Sales'};
            
        for (AccountTeamMember stdAccTeamMember : stdAccTeamMembers) {
            String businessSegment = '';
            if (String.isBlank(stdAccTeamMember.Business_Segment__c) && stdAccTeamMember.User != null && String.isNotBlank(stdAccTeamMember.User.Business_Segment__c)) {
                businessSegment = stdAccTeamMember.User.Business_Segment__c;
                AccountTeamMember accTeamToUpdate = new AccountTeamMember();
                accTeamToUpdate.Id = stdAccTeamMember.Id;
                accTeamToUpdate.Business_Segment__c = stdAccTeamMember.User.Business_Segment__c;
                toUpdate.add(accTeamToUpdate);
            }
            else {
                businessSegment = stdAccTeamMember.Business_Segment__c;
            }
            if (String.isNotBlank(businessSegment)) {
                Account_Team__c newCustomAccTeamMember = new Account_Team__c();
                newCustomAccTeamMember.Team_Member__c = stdAccTeamMember.UserId;
                newCustomAccTeamMember.Source_Account__c = stdAccTeamMember.AccountId;
                newCustomAccTeamMember.Business_Segment__c = stdAccTeamMember.User.Business_Segment__c == 'Animal Nutrition' ? 'Industry' : stdAccTeamMember.User.Business_Segment__c;
                newCustomAccTeamMember.Primary__c = primaryRoles.contains(stdAccTeamMember.TeamMemberRole) ? stdAccTeamMember.Primary__c : false;
                newCustomAccTeamMember.Team_Role__c = customTeamRoles.contains(stdAccTeamMember.TeamMemberRole) ? stdAccTeamMember.TeamMemberRole : 'Technical Sales Support';
                newCustomAccTeamMember.Account_Access__c = stdAccTeamMember.AccountAccessLevel == 'Read' ? 'Read' : 'Edit';
                newCustomAccTeamMember.Case_Access__c = stdAccTeamMember.CaseAccessLevel == 'Read' ? 'Read' : 'Edit';
                newCustomAccTeamMember.Contact_Access__c = stdAccTeamMember.ContactAccessLevel == 'Read' ? 'Read' : 'Edit';
                newCustomAccTeamMember.Opportunity_Access__c = stdAccTeamMember.OpportunityAccessLevel == 'Read' ? 'Read' : 'Edit';
                newCustomAccTeamMemberList.add(newCustomAccTeamMember);
            }
        }

        List<Database.SaveResult> stdAccTeamSaveResults = Database.update(toUpdate, false);//duplicated records will be ignored
        if (newCustomAccTeamMemberList.size() > 0) {
            List<Database.SaveResult> customAccTeamSaveResults = Database.insert(newCustomAccTeamMemberList, false);//duplicated records will be ignored
            for (Database.SaveResult saveResult : customAccTeamSaveResults) {
                if (!saveResult.isSuccess()) {
                    if (saveResult.errors != null) {
                        for(Database.Error err : saveResult.getErrors()) {
                            system.debug(err.message);
                            // if (!err.message.contains('Team Member with same Role and Business segment')) {
                            //     throw new CustomException(err.message);// throw error if not related to duplicated records
                            // }
                        }
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext batchContext) {
    }
}