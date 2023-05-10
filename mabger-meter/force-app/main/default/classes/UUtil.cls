public with sharing class UUtil 
{
	
	public static Boolean inBatch = false;
    public static Boolean freezeProcess = false;

    public class ReturnObj
    {
        public List<SObject> objects {get;set;}
    	public UEnum.DML dmlType {get;set;}
        
        public ReturnObj(List<SObject> objects, UEnum.DML dmlType)
        {
            this.objects = objects;
            this.dmlType = dmlType;
        }
    }

    /**
     * getBaseQueryString Utility method for grabbing all fields for an sObject
     * @param  objectName String sObject API name
     * @return            Returns base query string ending with sObject API name
     */
    public static String getBaseQueryString(String objectName) 
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
 
        String fields = '';

        for(String fieldName : fieldMap.keyset())
        {
            if(fields == null || fields == '')
            {
                fields = fieldName;
            }
            else
            {
                fields = fields + ', ' + fieldName;
            }
        }
 
        return 'SELECT ' + fields + ' FROM ' + objectName;
    }
}