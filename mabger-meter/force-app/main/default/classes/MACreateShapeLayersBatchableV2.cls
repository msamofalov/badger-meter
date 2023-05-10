global class MACreateShapeLayersBatchableV2 implements Database.Batchable<sObject>, Database.Stateful 
{
    //usage: Database.executeBatch(new MACreateShapeLayersBatchableV2(), 25);
    
    global map<string, map<string, list<tmtwrapper>>> bigFldrMap = new map<string, map<string, list<tmtwrapper>>>();
    global map<string, string> SalesCreditNumberAccountNameMap = new map<string, string>();
    
    global string MarketName;
    global string MarketFolderId;

    global MACreateShapeLayersBatchableV2(string mName)
    {
        MarketName = mName;

        for(maps__Folder__c mFldr : [SELECT Id FROM maps__Folder__c WHERE maps__ParentFolder__r.Name = 'Territories' AND Name = :MarketName]) 
        {
            MarketFolderId = mFldr.Id;
        }
        
        for (Sales_Credit_ID__c scid : [SELECT Sales_Credit_Number__c, Channel_Partner__c, Channel_Partner__r.Name FROM Sales_Credit_ID__c])
        {
            if (scid.Channel_Partner__c != null)
            {
                SalesCreditNumberAccountNameMap.put(scid.Sales_Credit_Number__c, scid.Channel_Partner__r.Name);
            }
        }
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator([SELECT Id, Country2__c, Market_Name__c, MATest__c, Sales_Credit_Number__c, Zip_Postal_Code__c FROM TMT__c WHERE country2__c != null AND Market_Name__c = :MarketName]);
    }

    global void execute(Database.BatchableContext BC, List<tmt__c> scope) 
    {
        for (tmt__c currentTMT : scope) 
        {
            //system.debug('Current TMT ' + currentTMT.id);
            
            if (bigFldrMap.containsKey(currentTMT.market_name__c))
            {
                //system.debug('Big folder map contains market ' + currentTMT.market_name__c);
                map<string, list<tmtwrapper>> existingScidMap = bigFldrMap.get(currentTMT.market_name__c);
                if (existingScidMap.containsKey(currentTMT.Sales_Credit_Number__c))
                {
                    //system.debug('Market Contains SCID ' + currentTMT.Sales_Credit_Number__c);
                    list<tmtwrapper> existingTMTs = existingScidMap.get(currentTMT.Sales_Credit_Number__c);
                    existingTMTs.add(new tmtwrapper(currentTMT.Zip_Postal_Code__c, currentTMT.country2__c));
                    
                    existingScidMap.put(currentTMT.Sales_Credit_Number__c, existingTMTs);
                    bigFldrMap.put(currentTMT.market_name__c, existingScidMap);
                }
                else 
                {
                    //system.debug('Market does not Contain  SCID ' + currentTMT.Sales_Credit_Number__c);
                    // add scid and tmt
                    list<tmtwrapper> newTMTs = new list<tmtwrapper>();
                    newTMTS.add(new tmtwrapper(currentTMT.Zip_Postal_Code__c, currentTMT.country2__c));
                    
                    existingScidMap.put(currentTMT.sales_credit_number__c, newTMTs);
                    
                    bigFldrMap.put(currentTMT.market_name__c, existingScidMap);
                }
            } 
            else 
            {
                //system.debug('Big folder map does not contain market :' + currentTMT.market_name__c);
                list<tmtwrapper> subTMTS = new list<tmtwrapper>();
                subTMTS.add(new tmtwrapper(currentTMT.Zip_Postal_Code__c, currentTMT.country2__c));
                
                map<string, list<tmtwrapper>> scidMap = new map<string, list<tmtwrapper>>();
                scidMap.put(currentTMT.Sales_Credit_Number__c, subTMTS);
                
                bigFldrMap.put(currentTMT.Market_Name__c, scidMap);
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        map<string, maps__ShapeLayer__c> territories = new map<string, maps__ShapeLayer__c>();
        Map<maps__ShapeLayer__c, list<string>> t2g = new Map<maps__ShapeLayer__c, list<string>>();

        // go through markets
        for (string mrktKey : bigFldrMap.keyset()) 
        {
            string currentMarket = mrktKey;

            map<string, list<tmtwrapper>> subMap = bigFldrMap.get(mrktKey);
            
            for (string scidKey : subMap.keyset()) 
            {
                string randomColor = getRandomColor();
                
                list<string> geoZips = new list<string>();
                
                for (tmtwrapper scidTMT : subMap.get(scidKey)) 
                {
                    geoZips.add(createZipGeo(scidTMT.cntryStr, scidTMT.zipStr));
                }
                
                if (geoZips.size() <= 8000)
                {
                    // Create Single Territory
                    string terrKey = scidKey + '-' + MarketFolderId;

                    maps__ShapeLayer__c t = buildTerritoryV2(scidKey, MarketFolderId, randomColor, null);
                    territories.put(terrKey, t);
                    t2g.put(t, geoZips);                    
                }
                else
                {
                    // Create Multiple Territories

                    list<string> geoZipChunk = new list<string>();
                    integer geoZipCount = 0;
                    integer geoChunkCount = 0;
                    
                    for (integer x = 0; x < geoZips.size(); x++)
                    {
                        geoZipChunk.add(geoZips[x]);
                        geoZipCount++;
                        
                        if (geoZipCount == 8000 || x == geoZips.size() - 1)
                        {
                            // Create new Territory
                            geoChunkCount++;
                            
                            string terrKey = scidKey + '-' + MarketFolderId + '-' + geoChunkCount;
                            maps__ShapeLayer__c t = buildTerritoryV2(scidKey, MarketFolderId, randomColor, geoChunkCount);
                            territories.put(terrKey, t);
                            
                            list<string> tempList = new list<string>();
                            tempList = geoZipChunk;
                            
                            t2g.put(t, tempList); 
                            
                            geoZipCount = 0;
                            geoZipChunk = new list<string>();
                        }
                    }                    
                }
            }
        }
        
        insert territories.values();
        
        list<maps__ShapeLayerGeometry__c> geos = new list<maps__ShapeLayerGeometry__c>();
        for (maps__ShapeLayer__c newTerritory : t2g.keySet()){

            list<string> zips = t2g.get(newTerritory);
            
            string geoStr = '';
            
            if (zips != null)
            {
                geoStr = createGeoStr(zips);
            }
            
            maps__ShapeLayerGeometry__c  geo = new maps__ShapeLayerGeometry__c();
            geo.maps__Geometry__c = geoStr;
            geo.maps__ShapeLayer__c = newTerritory.Id;
            geo.Name = newTerritory.Name + '-geometry'; 
            
            geos.add(geo);
        }
        
        insert geos;
        //system.debug('Territories Created : ' + territories.size());
        //system.debug('Territories');
        
        //system.debug('Geometries Created : ' + geos.size());
        //system.debug('Geometries');
        
        
        boolean AllBatchesDone = true;
        
        for (AsyncApexJob batchjob : [SELECT Id, JobItemsProcessed, TotalJobItems, JobType, MethodName, Status 
                                        FROM AsyncApexJob 
                                        WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = 'MACreateShapeLayersBatchableV2') AND CreatedDate = TODAY AND JobType = 'BatchApex'])
        {
            if (batchjob.Status != 'Completed')
            {
                AllBatchesDone = false;
            }
        }
        
        if (AllBatchesDone)
        {
            list<string> EmailAddresses = new list<string>();
            
            EmailAddresses.add(UserInfo.getUserEmail());
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.ToAddresses = EmailAddresses;
            message.Subject = 'Shape Layers Batch Complete';
            message.PlainTextBody = 'The batch for Generating Shape Layers has finished.';
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] rslts = Messaging.sendEmail(messages);            
        }
    }
    
    private string createZipGeo(string countryCode, string zip)
    {
        string geo = '';
        
        geo += '"' + countryCode + '-';
        
        if (countryCode == 'MEX')
        {
            if (zip.length() < 2)
            {
                geo += '0' + zip;
            }
        }
        else
        {
            geo += zip;
        }
        
        geo += '"';
        
        return geo;
    }

    private string createGeoStr(list<string> zips) 
    {
        string geoStr = '{"1":[';

        for (string tzip:zips){
            geoStr += tzip + ',';
        }
        geoStr = geoStr.removeEnd(',');
        geoStr += ']}';
        
        return geoStr;
    }
    
    private string getRandomColor()
    {
        string randomColor = '';

        list<string> HexColorsList = new list<string> { 
                '#7fffd4', '#9370d8', '#008000', '#ff0000', '#9acd32', '#ff00ff', '#ff8c00', '#dc143c', '#00ffff', '#3cb371', '#c71585', '#191970', '#ffa500', '#2e8b57', '#40e0d0', '#808000', '#8b4513', '#008080', '#ff6347', '#ffff00', 
                '#48d1cc', '#8b0000', '#008b8b', '#8a2be2', '#f0ffff', '#00ffff', '#8fbc8f', '#4b0082', '#e6e6fa', '#cd5c5c', '#e0ffff', '#f08080', '#add8e6', '#add8e6', '#20b2aa', '#ffa07a', '#7cfc00', '#ffffe0', '#32cd32', '#cd853f',
                '#ee82ee', '#8b008b', '#da70d6', '#ff4500', '#eee8aa', '#afeeee', '#87ceeb', '#800080', '#ff7f50', '#ffe4c4', '#f0fff0', '#e9967a', '#9400d3', '#b22222', '#ff1493', '#00bfff', '#ff69b4', '#00ff00', '#800000', '#d2b48c',
                '#66cdaa', '#f5fffa', '#ffe4e1', '#d87093', '#98fb98', '#fa8072', '#a0522d', '#00ff7f', '#4682b4', '#4169e1', '#adff2f', '#00ced1', '#a52a2a', '#9932cc', '#483d8b', '#1e90ff', '#00fa9a', '#ffe4b5', '#000080', '#6b8e23', 
                '#d2691e', '#7fff00', '#006400', '#556b2f', '#deb887', '#ffc0cb', '#b0e0e6', '#bc8f8f', '#7b68ee', '#ba55d3', '#f4a460', '#dda0dd', '#ffb6c1', '#87cefa', '#778899', '#b0c4de', '#90ee90', '#228b22', '#ff00ff', '#d8bfd8',
                '#00008b', '#b8860b', '#f0f8ff', '#0000ff', '#daa520', '#ffd700', '#0000cd'
        };
        
        randomColor = HexColorsList[integer.valueof(Math.floor(Math.random() * (HexColorsList.size()-1)))];
        
        return randomColor;
    }

    private maps__ShapeLayer__c buildTerritoryV2(string scid, id inFldr, string randomColor, integer territoryIndex) 
    {
        string terrName = '';
        
        if (SalesCreditNumberAccountNameMap.containsKey(scid))
        {
            terrName += scid + ' - ' + SalesCreditNumberAccountNameMap.get(scid);
        }
        else
        {
            terrName += scid;
        }
        
        if (territoryIndex != null)
        {
            terrName += ' - ' + territoryIndex;
        }
        
        maps__ShapeLayer__c terr = new maps__ShapeLayer__c();
        terr.maps__Folder__c = inFldr;
        terr.Name = terrName;
        terr.Auto_Created__c = true;
        
        map<string,object> ShapeLayerOptions = new map<string,object> {
            'country' => 'shapesV2',
            'advancedOptions' => new map<string,object> {
                'calculateTerritoryAggregates' => false,
                'dissolveGeometry' => true
            },
            'colorOptions' => new map<string,object> {
                'fillColor' => randomColor,
                'borderColor' => randomColor,
                'fillOpacity' => '0.5',
                'labelEnabled' => true,
                'labelOverride' => scid,
                'labelJustification' => 'center',
                'labelFontSize' => '9px',
                'labelFontColor' => '#FFFFFF',
                'labelBGColor' => '#000000',
                'labelBGOpacity' => '0.3'
            }
        };
        
        terr.maps__Options__c = JSON.serialize(ShapeLayerOptions);

        return terr;
    }

    public class tmtWrapper {
        public string zipStr {get;set;}
        public string cntryStr {get;set;}
        
        public tmtWrapper (string zip , string cntry) {
            zipStr = zip;
            cntryStr = cntry;
        }
    }
}