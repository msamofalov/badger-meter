/* ************************************************************
 * Created By  :  Raja Yeccherla(GearsCRM)
 * Created Date:  12/15/2015 
 * Description :  Helper class for ProductLineTrigger
 *
 * Modified By   :    
 * Modified Date :  
 * Description   :   
 * ************************************************************/
public class UProductLine
{
    public static void createNewProductUnits(List <Product_Line__c> records)
    {
        if(records.size() == 0) return ;
        map<id,integer> productUnitCount = new map<id,integer>();
        list<Product_Units__c> productUnitsToBeInserted = new list<Product_Units__c>();
        
        for(Product_Line__c pLine : [select id,Name,(select id,name from Product_Units__r) from Product_Line__c where id in :records])
        {
            productUnitCount.put(pLine.id,pLine.Product_Units__r.size());
        }
        
        
        for(Product_Line__c productLines : records)
        {
            if(productUnitCount.containsKey(productLines.id) && (productLines.Sample_Size__c > productUnitCount.get(productLines.id)))
            {
                integer productUnitsCount = Integer.valueOf(productLines.Sample_Size__c - productUnitCount.get(productLines.id));
                for(integer i=0;i< productUnitsCount;i++ )
                {
                    Product_Units__c productUnitObj = new product_Units__c();
                    productUnitObj.Case__c = productLines.case__c;
                    productUnitObj.Product_Line__c = productLines.id;
                    productUnitsToBeInserted.add(productUnitObj);
                }
                
            }
        }
        
        
        if(productUnitsToBeInserted.size() > 0 && productUnitsToBeInserted != null)
        {
            insert productUnitsToBeInserted;
        }
        
    }
    
}