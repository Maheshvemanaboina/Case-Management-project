/* Created By : KVP- Surya Priya.S
* Name : ApexDataSharingWithMultiOrg
* Created on : 09 June 2021
* Modified on: 10 June 2021
* Description : Sharing the Apex class data to the COE Multi Org.
*/
public class ApexClassDataSharing {
    //SELECT ApiVersion,IsValid,LengthWithoutComments,Name,NamespacePrefix,Status FROM ApexClass
    public static List<DataSharingWrapper.apexClassData>  getApexData()
    {
        List<DataSharingWrapper.apexClassData> apexClassDetailsList = new List<DataSharingWrapper.apexClassData>();
        DataSharingWrapper.apexClassData dataApex;
        List<ApexClass> listofapex = new List<ApexClass>();
        if(!Test.isRunningTest()){
        	 listofapex = [SELECT id,ApiVersion,IsValid,LengthWithoutComments,Body,Name,NamespacePrefix,Status FROM ApexClass];
        }else{
             listofapex = [SELECT id,ApiVersion,IsValid,LengthWithoutComments,Body,Name,NamespacePrefix,Status FROM ApexClass where name like '%Scaf%'];
             system.debug('listofapex' + listofapex);
        }
        try{
            for(ApexClass apx : listofapex){
                system.debug('LengthWithoutComments ' +apx.LengthWithoutComments);
                if(apx.LengthWithoutComments!=-1){
                    dataApex = new DataSharingWrapper.apexClassData();
                    dataApex.APIVersion = String.valueOf(apx.ApiVersion);
                    dataApex.className = apx.Name;
                    dataApex.classId = apx.id;
                    if(apx.LengthWithoutComments < 150000){
                        List<String> lines = apx.Body.split('\n');
                        dataApex.countOfLines = lines.size();
                    }else{
                        
                    }
                    
                    dataApex.LengthWithoutComments = String.valueOf(apx.LengthWithoutComments) ;
                    dataApex.CurrentAPIVersion = '52';
                    dataApex.Org = UserInfo.getOrganizationId();
                    System.debug('dataApex--> '+dataApex);
                    apexClassDetailsList.add(dataApex);
                }
            }}
        catch(Exception ex){
            system.debug('exx'+ex.getLineNumber()+'message..'+ex.getMessage());
        }
        
        
        return apexClassDetailsList;
    }
    
    
}