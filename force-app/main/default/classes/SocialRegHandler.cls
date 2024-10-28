global without sharing class SocialRegHandler implements Auth.RegistrationHandler{
    
    static final string social_account = 'Social Sign-On';
    //static final string community_profile = 'Customer Community User';
    static final string community_profile = 'FCI Distributor Community User';
    static final string chatter_profile  = 'Chatter Free User';
    
    void prepareUserData(Auth.UserData data, User u)
    {   
        String name, firstName, lastName, username, alias, email;
        
        //TODO: Customize the user attributes. Also check that the username doesn't 
        //already exist and possibly ensure there are enough org licenses to 
        //create a user. Must be 80 characters or less
        
        // Print the attributes list retrieved by the Authentication Provider
        system.debug('Email: ' + data.email);
        system.debug('First Name: ' + data.firstName);
        system.debug('Last Name: ' + data.lastName);
        for(string key : data.attributeMap.keySet())
        {
            system.debug('key: ' + key + ' value: ' + data.attributeMap.get(key));
        }
        system.debug('unique name:'+data.attributeMap.get('unique_name'));
        // Initialize the attributes essential for creating a new user with dummy values 
        // in case they will not be provided by the Auth Provider 
        firstName = 'change-me';
        lastName  = 'change-me';
        email     = 'change@me.com';
        email = data.attributeMap.get('unique_name');
        
        if(data.email != null && data.email != '')
            email = data.email;           
        
        
        if(data.firstName != null && data.firstName != '')
            firstName = data.firstName;
        
        if(data.LastName != null && data.lastName != '')
            lastName = data.lastName;
        
        if(data.attributeMap.containsKey('full_name'))
            name = data.attributeMap.get('full_name');
        
        if(data.attributeMap.containsKey('name'))
            name = data.attributeMap.get('name');
        
        if(firstName == 'change-me' && name != '')
            firstName = name.substringBefore(' ');
        
        if(lastName == 'change-me' && name.substringAfter(' ') != '')
            lastName = name.substringAfter(' ');
        
        // Generate a random username
        Integer rand = Math.round(Math.random()*100000000);
        username = rand + email;        
        
        alias = firstName;
        //Alias must be 8 characters or less
        if(alias.length() > 8)
            alias = alias.substring(0, 8);   
        
        system.debug('USERNAME:'+username);
        system.debug('EMAIL:'+email);
        u.username = username;
        u.email = email;
        u.lastName = lastName;
        u.firstName = firstName;
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'Europe/Amsterdam';
        u.Create_Case__c = true;
    }
    
    // Creates a chatter or a community user
    global User createUser(Id portalId, Auth.UserData data){
        
        system.debug('----create user-----');
        system.debug('----data-------'+data);
        User u = new User();
        String email = data.attributeMap.get('unique_name');
        System.debug('email --> '+email);
        
        System.debug('email 1 --> '+data.attributeMap.get('unique_name'));
        List<User> userList = [Select Id,Email,firstName,lastName from User where email =: email];
        if(!userList.isEmpty()){
            System.debug('entered existing User '+userList);
            u = userList[0];
            updateUser(u.Id,u.Id,data);
        }
        else{
            System.debug('entered create User ');
            prepareUserData(data, u);
            if(data.attributeMap.containsKey('sfdc_networkid')){ 
                system.debug('---contains---');
                
                Profile p = [SELECT Id FROM profile WHERE name=:community_profile];     // if Community id is included create user with community profile
                u.profileId = p.Id;          
                
            }
            else{
                system.debug('--not contains---');      
                
                Profile p = [SELECT Id FROM profile WHERE name=:chatter_profile];       // if Community id is not included create user with chatterprofile
                u.profileId = p.Id;            
            }   
        }
        System.debug('u --> '+u);        
        return u;
    } 
    /**************** 
prepareUserData(data, u);

//TODO: Customize the username, profile and account name

if(data.attributeMap.containsKey('sfdc_networkid')) {
//We have a community id, so create a user with community access

//TODO: Customize the Account
Account a;
List<Account> accounts = [SELECT Id FROM account WHERE name=:social_account];
if(accounts.isEmpty())
{
a = new Account(name = social_account);
insert(a);
}else
a = accounts[0];

Contact c = new Contact();
c.accountId = a.Id;

c.firstName = u.firstName;
c.lastName  = u.lastName;
insert(c);

//TODO: Customize the profile
Profile p = [SELECT Id FROM profile WHERE name=:community_profile];     
u.profileId = p.Id;
u.contactId = c.Id;
return u;
} else {
//TODO: Customize the profile
Profile p = [SELECT Id FROM profile WHERE name=:chatter_profile];
u.profileId = p.Id;
return u;
} ***********/
    
    // Updates the user's first and last name
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
        system.debug('----update user-------'+userId);
        system.debug('----data-------'+data);
        List<User> userList = new List<User>();
        User u = new User();
        String email = data.attributeMap.get('unique_name');
        //String email = data.email;
        if(email == null){
            System.debug('email is null in update');
        }
        userList = [Select Id,email,lastName,firstName,profileId from User where email =: email and isActive = true];
        if(!userList.isEmpty()){
            System.debug('userList final '+userList);
            u = userList[0];
            if(data.email != null && data.email != ''){
                System.debug('email in update if'+email);
                u.email = data.email;
            }
            
            /*if(data.lastName != null && data.lastName != '')
                u.lastName = data.lastName;
            
            if(data.firstName != null && data.firstName != '') 
                u.firstName = data.firstName;*/
            
            update(u);
        }
        
        
        
    } 
    
}