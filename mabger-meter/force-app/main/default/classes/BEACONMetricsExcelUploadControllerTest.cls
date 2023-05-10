/***
Purpose: BEACONMetricsExcelUploadControllerTest to verify various functions of BEACONMetricsExcelUploadController, 
A controller uploading excel file to load into BEACON Metrics table
Date: 04/04/2017
***/
@isTest
private class BEACONMetricsExcelUploadControllerTest{
    //No data flow test
    private static TestMethod void beaconFileUploader(){
       BEACONMetricsExcelUploadController BU = new BEACONMetricsExcelUploadController();
       String csvFile ='12666,68886-101,1,0,0,0,0,NULL,false\r\n12666,68886-101,1,0,0,0,0,NULL,false';
       BU.nameFile = csvFile;
       Blob csvBlob = Blob.valueOf(csvFile ); 
       BU.contentFile =csvBlob;  
       BU.ReadFile();  
       BU.loadBMetrics();
    }
    //Null file test
    private static TestMethod void beaconFileUploaderNull(){
       BEACONMetricsExcelUploadController BU = new BEACONMetricsExcelUploadController();
       String csvFile =null;
       BU.nameFile = csvFile;
       //Blob csvBlob = Blob.valueOf(csvFile ); 
       //BU.contentFile =csvBlob;  
       BU.ReadFile();  
       BU.loadBMetrics();
    }    
}