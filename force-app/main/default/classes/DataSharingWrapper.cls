/* Created By : KVP- Surya Priya.S
* Name : DataSharingWrapper
* Created on : 18 Feb 2021
* Modified on: 09 June 2021
* Description : Wrapper class to send data to the COE Multi Org.
*/
public class DataSharingWrapper {
    
    public List<UserLicenseWrapper> LicenseData;
    public OrgDataWrapper OrgData;
    public NoOfUsers NoOfUSers;
    public userManagementDetails userManagementDetails;
    public List<objectMetaData> metaDataDetails;
     public List<apexClassData> apexDataDetails;
     public List<testClassData> testDataDetails;
    public DataSharingWrapper(){
        LicenseData = new List<UserLicenseWrapper>();
        metaDataDetails = new List<objectMetaData>();
        apexDataDetails = new List<apexClassData>();
        testDataDetails = new List<testClassData>();
    }
    
    Public Class OrgDataWrapper{
        public String OrgId;
        public String OrgName;
        public String OrgOwner;
        public String SupportLevel;
    }
    
    Public Class NoOfUsers{
        
        public Integer NumberOfAdmin;
        public Integer NumberofActiveusers;
        
    }
    Public Class UserLicenseWrapper{
        public String UserLicenseName;
        public String Status;
        public Integer TotalLicenses;
        public Integer UsedLicenses;
        public String orgId;
    }
    Public Class userManagementDetails{
        public Integer RolesUnassigned;
        public Integer RolesTotal;
        public Integer UserNotLoggin;
        public String Org;
        
    }
    Public Class objectMetaData{
        public String Org;
        public String ObjectName;// available
        public Integer ObjectNumberOfFields; // available
        public Date ObjectLastUsageDate;//available
        public Integer ObjectRecordCount;// available
        public Integer ObjectUnusedRecordTypesCount;// available
        public Integer ObjectTotalRecordTypesCount;// available
        Public Integer NumberOfApprovalProcessActive;// available
        public Integer NumberOfApprovalProcessInActive;// available
       
    }
    
    Public Class apexClassData{
        public String Org;
        public String className;// available
        public String LengthWithoutComments; // available
        public String APIVersion;//available
        public Integer countOfLines;
        public String classId;        
        public String CurrentAPIVersion;//available
    }
    Public Class testClassData{
        public String Org;
        public String testClassName;
        public Integer coverage;
       
    }
}