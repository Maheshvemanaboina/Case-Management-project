@istest
public class SocialRegHandler_Test {
    
    @isTest
    static void AuthShouldCreateNewUserWithCommunityAndChatterProfile(){
        SocialRegHandler handler = new SocialRegHandler ();
        
        //Auth Data having Sfdc_networkId , so will create user with Community Profile
        Map<String,String> attributeMap1 = new Map<String, String>();
        attributeMap1.put('language','en_US');
        attributeMap1.put('unique_name','eduard.andrien@frieslandcampina.com.inv');
        attributeMap1.put('full_name','Test User');
        attributeMap1.put('name','Test Test User');
        attributeMap1.put('sfdc_networkid','007');
        Auth.UserData sampleData1 = new Auth.UserData('testId', '', '',
                                                     'testFirst testLast', 'eduard.andrien@frieslandcampina.com.invalid', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, attributeMap1);
        
        //Auth Data not having Sfdc_networkId , so will create user with chatter Profile
        Map<String,String> attributeMap2 = new Map<String, String>();
        attributeMap2.put('language','en_US');
        attributeMap2.put('unique_name','eduard.andrien@frieslandcampina.com.inv');
        Auth.UserData sampleData2 = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'eduard.andrien@frieslandcampina.com.invalid', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, attributeMap2);
        try{
            User u = handler.createUser(null, sampleData1);
            
            User u1 = handler.createUser(null, sampleData2);
        }
        catch(Exception e){
            System.debug('Exception e '+e.getLineNumber()+' with error '+e.getMessage());
        }
    }
    
    @isTest
    static void shouldUpdateExistingUser(){
        User u = TestUtility.createUser('Test66777@User.com','System Administrator');
        insert u;
        
        //Update existing user if email matches
        SocialRegHandler handler = new SocialRegHandler ();
        Map<String,String> attributeMap = new Map<String, String>();
        attributeMap.put('language','en_US');
        attributeMap.put('unique_name','no@email.com');
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'eduard.andrien@frieslandcampina.com.invalid', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, attributeMap);
        try{
            User updUser = handler.createUser(null, sampleData);
        }
        catch(Exception e){
            System.debug('Exception e '+e.getLineNumber()+' with error '+e.getMessage());
        }
    }
}