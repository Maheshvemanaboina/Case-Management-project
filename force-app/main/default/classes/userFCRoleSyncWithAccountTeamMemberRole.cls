public class userFCRoleSyncWithAccountTeamMemberRole {
    
    public static void syncUserRoleWithATMRole(List<User> newUsers){
         list<AccountTeamMember>atList = new list<AccountTeamMember>();
         for (User usr : newUsers) {
            list<AccountTeamMember> ATM = [select id,TeamMemberRole from AccountTeamMember where userId=:usr.id];
            for(AccountTeamMember at :ATM){
              at.TeamMemberRole = usr.Friesland_Campina_Role__c;  
                atList.add(at);
            }
         }
         if(atList.size()>0){
            update atList;
        }
    }
}