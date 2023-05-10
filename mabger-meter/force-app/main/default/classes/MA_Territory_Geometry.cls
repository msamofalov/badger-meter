public class MA_Territory_Geometry {

    // Created by Allium 6/19/18
    // Populate Regions field according to Postal Codes contained in Geometry field.
    // Update Regions field of related Territory, based on the Regions its children.
        
    public static void Populate_Geometry_Regions(list <ID> geometryIDs){

        system.debug('Number of Geometries to Process: ' + geometryIDs.size());
       
        // Populate list of Geometry records from GeometryIDs
        list <maps__ShapeLayerGeometry__c> geometries = new list <maps__ShapeLayerGeometry__c>(
            [SELECT ID, maps__Geometry__c, maps__ShapeLayer__r.name
             FROM maps__ShapeLayerGeometry__c
             WHERE ID in : geometryIDs]
        );

        map <string, set <string>> ZipCodes_Per_Sales_Credit_Num = new map <string, set <string>>();
        set <string> Relevant_Zip_Codes = new set <string>();
        
        // Get a list of all SC#'s for all Territories represented by the geographies
        for (maps__ShapeLayerGeometry__c geo : geometries){
            // Could do some format checking here
            system.debug('Adding SC# ' + geo.maps__ShapeLayer__r.name.left(6) + ' to Map');
            ZipCodes_Per_Sales_Credit_Num.put(geo.maps__ShapeLayer__r.name.left(6), new set <string>());
        }
        
        // Get all TMT records where Sales Credit Number is relevant
        for (TMT__c tmt : [SELECT Sales_Credit_Number__c, TMT_Search__c
                           FROM TMT__c
                           WHERE Sales_Credit_Number__c in : ZipCodes_Per_Sales_Credit_Num.keySet()]){
            ZipCodes_Per_Sales_Credit_Num.get(tmt.Sales_Credit_Number__c).add(tmt.TMT_Search__c);
            Relevant_Zip_Codes.add(tmt.TMT_Search__c);                   
        }
        
        // Populate Region Sets
        set <string> Northeast_Postal_Codes = new set <string>();
        set <string> Southeast_Postal_Codes = new set <string>();
        set <string> Midwest_Postal_Codes = new set <string>();
        set <string> Central_Postal_Codes = new set <string>();
        set <string> West_Postal_Codes = new set <string>();
        
        // Use 3-digit zip code for match
        for (TMT__c tmt : [SELECT ID, TMT_Search__c 
                           FROM TMT__c 
                           WHERE Sales_Credit_Number__c = '061779' and
                                 TMT_Search__c in : Relevant_Zip_Codes])
            Northeast_Postal_Codes.add(tmt.TMT_Search__c);

        for (TMT__c tmt : [SELECT ID, TMT_Search__c
                           FROM TMT__c
                           WHERE Sales_Credit_Number__c = '061060' and
                                 TMT_Search__c in : Relevant_Zip_Codes])
            Southeast_Postal_Codes.add(tmt.TMT_Search__c);

        for (TMT__c tmt : [SELECT ID, TMT_Search__c
                           FROM TMT__c
                           WHERE Sales_Credit_Number__c = '060613' and
                                 TMT_Search__c in : Relevant_Zip_Codes])
            Midwest_Postal_Codes.add(tmt.TMT_Search__c);

        for (TMT__c tmt : [SELECT ID, TMT_Search__c
                           FROM TMT__c
                           WHERE Sales_Credit_Number__c = '061044' and
                                 TMT_Search__c in : Relevant_Zip_Codes])
            Central_Postal_Codes.add(tmt.TMT_Search__c);        

        for (TMT__c tmt : [SELECT ID, TMT_Search__c
                           FROM TMT__c
                           WHERE Sales_Credit_Number__c = '061612' and
                                 TMT_Search__c in : Relevant_Zip_Codes])
            West_Postal_Codes.add(tmt.TMT_Search__c);   
        
        
        // Loop through the New / Updated Geometry records.
        // Set / Update Regions as needed.
        for (maps__ShapeLayerGeometry__c tg : geometries){
            boolean northeast = false;
            boolean southeast = false;
            boolean midwest = false;
            boolean central = false;
            boolean west = false;
            
            string SC_Num = tg.maps__ShapeLayer__r.name.left(6);

            system.debug('Northeast 3-Digit Zips: ' + Northeast_Postal_Codes.size());
            system.debug('Southeast 3-Digit Zips: ' + Southeast_Postal_Codes.size());
            system.debug('Midwest 3-Digit Zips: ' + Midwest_Postal_Codes.size());
            system.debug('Central 3-Digit Zips: ' + Central_Postal_Codes.size());
            system.debug('West 3-Digit Zips: ' + West_Postal_Codes.size());
            
            system.debug('Processing Sales Credit #: ' + SC_Num);            
            
            // set region boolean values
            for (string PostalCode : Northeast_Postal_Codes)
                if (ZipCodes_Per_Sales_Credit_Num.get(SC_Num).contains(PostalCode)){
                    system.debug('Found Northeast ZipCode: ' + PostalCode);
                    northeast = true;
                    break;}
            for (string PostalCode : Southeast_Postal_Codes)
                if (ZipCodes_Per_Sales_Credit_Num.get(SC_Num).contains(PostalCode)){
                    system.debug('Found Southeast ZipCode: ' + PostalCode);
                    southeast = true;
                    break;}
            for (string PostalCode : Midwest_Postal_Codes)
                if (ZipCodes_Per_Sales_Credit_Num.get(SC_Num).contains(PostalCode)){
                    system.debug('Found Midwest ZipCode: ' + PostalCode);
                    midwest = true;
                    break;}
            for (string PostalCode : Central_Postal_Codes)
                if (ZipCodes_Per_Sales_Credit_Num.get(SC_Num).contains(PostalCode)){
                    system.debug('Found Central ZipCode: ' + PostalCode);
                    central = true;
                    break;}
            for (string PostalCode : West_Postal_Codes)
                if (ZipCodes_Per_Sales_Credit_Num.get(SC_Num).contains(PostalCode)){
                    system.debug('Found West ZipCode: ' + PostalCode);
                    west = true;
                    break;}
            
            // Assemble Region String
            string RegionString = '';
            RegionString = northeast ? RegionString + 'Northeast;' : RegionString;
            RegionString = southeast ? RegionString + 'Southeast;' : RegionString;
            RegionString = midwest ? RegionString + 'Midwest;' : RegionString;
            RegionString = central ? RegionString + 'Central;' : RegionString;
            RegionString = west ? RegionString + 'West;' : RegionString;
            
            // update the value on the record
            tg.Regions__c = RegionString;
            system.debug('Regions Found: ' + RegionString);
        }
        update geometries;
    }
    
    public static void Populate_Territory_Regions(list <ID> geometryIDs){    

        // Populate list of Geometry records from GeometryIDs
        list <maps__ShapeLayerGeometry__c> geometries = new list <maps__ShapeLayerGeometry__c >(
            [SELECT ID, maps__ShapeLayer__c, Regions__c 
             FROM maps__ShapeLayerGeometry__c
             WHERE ID in : geometryIDs]
        );        
        
        // Update Territory Regions to match Regions in trigger.new
        // Assumes only one Geometry per Territory, which is true in this situation.

        list <maps__ShapeLayer__c> Territories = new list <maps__ShapeLayer__c>();

        for(maps__ShapeLayerGeometry__c tg : geometries){
            try{
                maps__ShapeLayer__c Terr = new maps__ShapeLayer__c(id = tg.maps__ShapeLayer__c, 
                                                                   Regions__c = tg.Regions__c);
                Territories.add(Terr);     
            }
            catch(Exception e){
                system.debug(e.getMessage());
                continue;
            }
        }        
        
        update Territories;        
        
    }    
}