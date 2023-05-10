public class ShapeLayerBatchPage 
{
    public ShapeLayerBatchPage()
    {
        
    }
    
    public void RunBatch()
    {
        // clear out the existing folders
        deleteFolderStructure();        
        
        // create our new folder structure
        createFolderStructure();
        
        for (market__c m: [select id, name from Market__c]) {
            database.executeBatch(new MACreateShapeLayersBatchableV2(m.Name), 200);
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Generate Shape Layers batch has been started. You will be emailed when finished.'));
    } 
    
    public void deleteFolderStructure () 
    {
        system.debug('Removing Folders');
        List<maps__ShapeLayer__c> territoriesToDelete = new List<maps__ShapeLayer__c>();
        for (maps__ShapeLayer__c terr : [SELECT Id FROM maps__ShapeLayer__c WHERE Auto_Created__c = true ]){
            territoriesToDelete.add(terr);
        }
        delete territoriesToDelete;
        
        // Remove market folders
        list<maps__Folder__c> fldrsToDelete = new list<maps__Folder__c>();
        for (maps__Folder__c rFldrs: [select id, name from maps__Folder__c where maps__ParentFolder__r.Name = 'Territories']){
            fldrsToDelete.add(rfldrs);
        }
        delete fldrsToDelete;
    }
    
    private void createFolderStructure() 
    {
        system.debug('Creating Folders');
        
        // get territoryfolder id
        maps__Folder__c territoryFolder;
        for(maps__Folder__c tFld: [select id from maps__Folder__c where name = 'Territories']) {
            territoryFolder = tFld;
            break;
        }
        
        list<maps__Folder__c> mrktFolders = new list<maps__Folder__c>();
        for (market__c m: [select id, name from Market__c]) 
        {
            mrktFolders.add(new maps__Folder__c (Name= m.name, maps__ParentFolder__c=territoryFolder.id,Market__c = m.id));
        }

        insert mrktFolders;
    }    
}