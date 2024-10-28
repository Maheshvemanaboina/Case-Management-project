@isTest
public class userFCRoleSyncWithAccountTest {


    public static testMethod void testRunAs() {
        // Setup test data
        // This code runs as the system user
           List<Account> accList = new List<Account>();
                 list<AccountTeamMember>atList = new list<AccountTeamMember>();

        for (Integer i = 0; i < 5; i++) {
            Account newAcc = new Account(Name='Test',BillingCity='Bangalore',BillingCountry='India');
            accList.add(newAcc);
        }
        insert accList;
           Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		   String teamMemberRole = 'Account Manager';
         String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'None';

        // create the Users
        List<User> userList = new List<User>();
        for (Integer i = 0; i< 5; i++) {
            // observe the same name for Opp and TSG
            USer newUser = new User(lastname = 'Test',Alias = 'Test',TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'eu_ES',EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.id,LanguageLocaleKey = 'en_US',
            userName='Test' + i + '@sdkksdhfhdsjhf.com',email='Test' + i + '@asjgdgsad.com');
            userList.add(newUser);
        }
        insert userList;
       
       
        //Create the AccountTeam
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        For (Integer i = 0; i< 5; i++) {
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = accList[i].ID,
		TeamMemberRole = 'Technical Sales',UserId = userList[i].ID);
        teamList.add(newTeam);
        }
        insert teamList;
        
          for (User usr : userList) {
            list<AccountTeamMember> ATM = [select id,TeamMemberRole from AccountTeamMember where userId=:usr.id];
            for(AccountTeamMember at :ATM){
              at.TeamMemberRole = usr.Friesland_Campina_Role__c;  
                atList.add(at);
            }
         }
        if(atList.size()>0){
            update atList;
        }
        userFCRoleSyncWithAccountTeamMemberRole.syncUserRoleWithATMRole(userList);
    }

}