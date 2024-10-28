global without sharing class AccountSharingRecalculation implements Database.Batchable<SObject>,Database.stateful {

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, ParentId, OwnerId FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> accountList){
        List<User> users = UserUtility.getAllCommunityUsers();
        Set<Id> usersIds = new Set<Id>();
        for (User usr : users) {
            usersIds.add(usr.Id);
        }

        Set<Id> accountsIds = new Set<Id>();
        for (Account acc : accountList) {
            accountsIds.add(acc.Id);
        }
        
        AccountSharingUtility.deleteAllAccountRelatedSharing(users, accountList);
        AccountSharingUtility.createSharingForAccount(usersIds, accountsIds);
    }

    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('Account Sharing Recalculation Batch', bc);
    }
}