/* Created By : KVP- Surya Priya.S
* Name : DataSharingWithMultiOrg
* Created on : 11 Feb 2021
* Modified on: 19 May 2021
* Description : Post the organization related data to the COE Multi Org.
*/
@RestResource(urlMapping='/OrgData')
global with sharing class DataSharingWithMultiOrg {
    @HttpGet
    global static void fetchOrgData(){  
        RestResponse res = Restcontext.response; 
        Map<String,Object> responseMap = new Map<String,Object>();
        MetaDataSharingWithMultiOrg getObjMetaData = new MetaDataSharingWithMultiOrg();
        DataSharingWrapper dataWrap = new DataSharingWrapper();
        DataSharingWrapper.OrgDataWrapper dataOfOrg = new DataSharingWrapper.OrgDataWrapper();
        DataSharingWrapper.NoOfUsers noOfUsers = new DataSharingWrapper.NoOfUsers();
        DataSharingWrapper.UserLicenseWrapper userLicense ;
        DataSharingWrapper.objectMetaData objMetaDataDetails ;
        DataSharingWrapper.userManagementDetails userManagement = new DataSharingWrapper.userManagementDetails();
        List<DataSharingWrapper.UserLicenseWrapper> userLicenseList = new List<DataSharingWrapper.UserLicenseWrapper>();
        Map<Map<String,Integer>,Integer> metaDataObjMap = new Map<Map<String,Integer>,Integer>();
        try{
            Integer adminUsers = [ SELECT count() FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'];
            Integer activeUsers = [ SELECT count() FROM User WHERE IsActive = true];
            //UserManagement Data starts
            Integer usersNotLoggin = [select count() from user where LastLoginDate < LAST_N_DAYS:30 and  isActive = true];
            Integer rolesTotal = [SELECT count() FROM UserRole];
            List<UserRole> rolesUnassigned = [ Select Name from UserRole where id not in (select UserRoleId from User)];
            Integer numberOfUnassignedRoles = rolesUnassigned.size();
            userManagement.RolesTotal = rolesTotal;
            userManagement.RolesUnassigned = numberOfUnassignedRoles;
            userManagement.UserNotLoggin = usersNotLoggin;
            userManagement.Org = UserInfo.getOrganizationId();
            //UserManagement Data end
            
            noOfUsers.NumberOfAdmin = adminUsers;
            noOfUsers.NumberofActiveusers = activeUsers;
            
            
            for(Organization org:[SELECT PrimaryContact, Id, Name, OrganizationType, TotalTrustedRequestsUsage, TotalTrustedRequestsLimit FROM Organization LIMIT 1]){
                
                dataOfOrg.OrgId = org.Id;
                dataOfOrg.OrgName = org.Name;
                dataOfOrg.OrgOwner =org.PrimaryContact;
                dataOfOrg.SupportLevel = Label.Support_level;
                
                
            }
            
            
            String orgId =UserInfo.getOrganizationId();
            for(UserLicense userli:[SELECT Id, TotalLicenses, Status, UsedLicenses, Name FROM UserLicense]){
                userLicense = new DataSharingWrapper.UserLicenseWrapper();
                userLicense.UserLicenseName=userli.Name;
                userLicense.Status=userli.Status;
                userLicense.TotalLicenses=userli.TotalLicenses;
                userLicense.UsedLicenses=userli.UsedLicenses;
                userLicense.orgId = orgId;
                userLicenseList.add(userLicense);
            }
            //metaData code starts
              
            List<DataSharingWrapper.objectMetaData> dataOfObjList= MetaDataSharingWithMultiOrg.getObjData();
                
            //metaData end
            List<DataSharingWrapper.apexClassData> dataOfApexList = ApexClassDataSharing.getApexData();
            dataWrap.NoOfUsers = noOfUsers;
            dataWrap.OrgData = dataOfOrg;
            dataWrap.LicenseData = userLicenseList;
            dataWrap.userManagementDetails = userManagement;
           dataWrap.metaDataDetails = dataOfObjList;
            dataWrap.apexDataDetails = dataOfApexList;
            res.statusCode=200;
            responseMap.put('statusCode','200');
            responseMap.put('statusMessage','Success');
            responseMap.put('response',dataWrap);
        }
        Catch(Exception ex){
            responseMap.put('response',ex.getMessage());
        }   
        res.responseBody=Blob.valueOf(JSON.serialize(responseMap));
    }
    
    
    
}