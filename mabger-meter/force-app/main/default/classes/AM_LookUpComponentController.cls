/*

Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/* Description: This class is the controller for the look up component */

public with sharing class AM_LookUpComponentController {

    //Variable for errormessage
    public List<ApexPages.Message> compErrorMessages 
    {
        get
        {
            //Get only error messages
            return AM_SettingsUtil.prepareMessages(ApexPages.getMessages());
        }

        private set;
    }

    //Look up object name
    public String lookupObjectName {get; set;}

    //Asset Record Type
    public String assetRecordType {get; set;}

    //Asset Status
    public String assetStatus {get; set;}

    //List for storing the Asset lookup values
    public List <Asset> assetLookupValues {get; private set;} 

    //List for storing the Asset lookup values
    public List <Contact> contactLookupValues {get; private set;} 

    //Lookup query
    public String lookupQuery {get; set;}

    //Show Asset Lookup
    public Boolean showAsset {get; private set;} {showAsset = false;}

    //Show Asset Lookup
    public Boolean showContact {get; private set;} {showContact = false;}    

    //Constructor
    public AM_LookUpComponentController() {

    }
    
    public PageReference runQuery()
    {
        //Check 
        if(String.isEmpty(this.lookupQuery) || this.lookupQuery.length()==1)
        {
            //Add a message that the search term is less than a character.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'E3: Search term cannot be 1 character. Please change the search term.'));            
        }
        else if(String.isEmpty(this.lookupObjectName))
        {
            //Add a message that lookup object is not specified
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'E4: LookUp object could not be determined. Please try again. If the error persists contact administrator'));             
        }
        else if(this.lookupObjectName.equalsIgnoreCase(AM_Constants.AM_ASSET_API_NAME))
        {
            //Initialise search results list
            List<List<Asset>> searchResults = new List<List<Asset>>();

            //Check if recordtype has been passed
            if(String.isEmpty(this.assetRecordType))
            {

                //Add a message that recordtype is not specified
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           'E5: Record Type could not be determined. Please try again. If the error persists contact administrator'));                              
            }
            else
            {
                try
                {
                    //If status is not provided then remove it from where clause
                    if(!String.isEmpty(this.assetStatus))
                    {
                        searchResults = [FIND :lookupQuery IN ALL FIELDS RETURNING Asset (id, 
                                                                                                name, 
                                                                                                Address__c,
                                                                                                Address__r.Name, 
                                                                                                Status, 
                                                                                                RecordType.name,
                                                                                                product2.name
                                                                                                where AM_Available_for_allocation__c= true
                                                                                                AND RecordTypeId = :assetRecordType)];                    
    
                    }
                    else
                    {
                        searchResults=[FIND :lookupQuery IN ALL FIELDS RETURNING Asset (id, 
                                                                                              name, 
                                                                                              Address__c, 
                                                                                              Address__r.Name, 
                                                                                              Status, 
                                                                                              RecordType.name,
                                                                                              product2.name
                                                                                              where RecordTypeId = :assetRecordType)];
                    }
    
                    assetLookupValues=searchResults[0]; 
    
                    //Show the table
                    this.showAsset = true;
    
                    //Hide other tables
                    this.showContact = false;                                
                }
                catch (Exception e)
                {
                    //Add a message that there was an error fetching records
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                               'E3: Error fetching Asset records. ( ' + e.getMessage() + ' )'));                     
                }               
            }


        }
        else if(this.lookupObjectName.equalsIgnoreCase(AM_Constants.AM_CONTACT_API_NAME))
        {
            try
            {
                List<List<Contact>> searchResults=[FIND :lookupQuery IN ALL FIELDS RETURNING Contact (id, 
                                                                                                      name,
                                                                                                      email,
                                                                                                      phone,
                                                                                                      account.name)];
                contactLookupValues=searchResults[0]; 

                //Show the table
                this.showContact = true;

                //Hide other tables
                this.showAsset = false;                 
            }
            catch (Exception e)
            {
                //Add a message that there was an error fetching records
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           'E3: Error fetching Contact records. ( ' + e.getMessage() + ' )')); 
            }    
             
        }   

        return null;
    }   

}