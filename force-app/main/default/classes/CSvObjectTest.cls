@isTest
public class CSvObjectTest {
    
    Public Static testmethod void test(){
        
        List<CSVHeader> lstObj = new List<CSVHeader>();
        CSVHeader header= new CSVHeader( 'test','test2');
        lstObj.add(header);
        
        list<string> lstString = new list<string>();
        lstString.add('test');
        list<list<string>> lstOflistSting = new list<list<string>>();
        lstOflistSting.add(lstString);
        
        CSVObject obj = new CSVObject();
        obj.line_count = 123;
        obj.message = 'test';
        
        
        
        string column_name='test1';
        String column_type = 'test2';
        
        test.startTest();
        CSVObject objectTest = new CSVObject(lstObj,lstOflistSting);
        CSVHeader h = new CSVHeader(column_name ,column_type );
        CSVHeader h1 = new CSVHeader(column_name);
        test.stopTest();
        
    }
    
}