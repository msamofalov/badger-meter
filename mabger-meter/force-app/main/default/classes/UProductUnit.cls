/* ************************************************************
 * Created By  :  Raja Yeccherla(GearsCRM)
 * Created Date:  12/15/2015 
 * Description :  Helper class for ProductUnitsTrigger
 *
 * Modified By   :    
 * Modified Date :  
 * Description   :   
 * ************************************************************/
public class UProductUnit
{
    public static void createProductUnitLineNumber(List <Product_Units__c> records)
    {
        if(records.size() == 0) return ;
        map<id,integer> productUnitCount = new map<id,integer>();
        set<id> productLineIds = new set<id>();
        
        system.debug('______records_____' + records);
        
        for(Product_Units__c prodUnit : records)
        {
            productLineIds.add(prodUnit.Product_Line__c);
        }
        
        system.debug('_______productLineIds____' + productLineIds);
        
        /* // JWB, Allium, 10/12/2018 - This code is being replaced for its inefficency. To get a count of product units, the query is actually pulling individual records.
        for(Product_Line__c pLine : [select id,Name,(select id,name from Product_Units__r) from Product_Line__c where id in :productLineIds])
        {
            productUnitCount.put(pLine.id,pLine.Product_Units__r.size());
        }
		*/
        
        // JWB, Allium, 10/12/2018 - This code replaces the above block. To get the product unit counts it executes an aggregate counting query. Much faster.
        for (AggregateResult productUnitCountItem : [Select Product_Line__c, Count(Id) ProductUnitCount From Product_Units__c Where Product_Line__c in :productLineIds Group By Product_Line__c]) {
            productUnitCount.put((Id)productUnitCountItem.get('Product_Line__c'), (Integer)productUnitCountItem.get('ProductUnitCount'));
        }
        
        for(Product_Units__c productUnits : records)
        {
            if (productUnitCount.containsKey(productUnits.Product_Line__c) && productUnitCount.get(productUnits.Product_Line__c) != null)     
            {
                Integer unitCount = productUnitCount.get(productUnits.Product_Line__c)+1;
                productUnits.ProductUnitLineNumber__c = unitCount;
                productUnitCount.put(productUnits.Product_Line__c, unitCount);
            }
        }
    }
}