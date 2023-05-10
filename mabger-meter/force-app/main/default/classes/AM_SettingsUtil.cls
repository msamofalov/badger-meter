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

/* Description: Utilities class for commonly required functionality */


public with sharing class AM_SettingsUtil {
    //Name of the asset selected
    public static String assetLabel; 

    /**
    * Description: Method to set the AssetLabel based on the recordtype selected
    */
    public static String setAssetLabel(String recordTypeId){

        try
        {
            //Get the RecordType Name based on the record type selection
            RecordType rt = [Select Name from RecordType where id =: recordTypeId];

            //Set the assetName
            assetLabel = rt.Name;
        }
        catch (Exception e)
        {
            //Add a message that there was an error fetching records
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                                      'I1: Could not fetch RecordType Name for' + recordTypeId + '. ( ' + e.getMessage() + ' )'));                                                                        

            //Set assetLabel as blank
            assetLabel = '';            

        }

        //Return the assetName
        return assetLabel;
    }

    /**
    * Description: Method to set the Asset Record Type 
    */
    public static String setAssetRecordTypeId(String recordTypeId){

        //Asset Record Type
        String assetRecordType = '';

        //Set the Record type
        if(String.isEmpty(recordTypeId))
        {
            //If Parameter passed is empty then check if default Record Type is set
            String defaultRecordType = [select Id, AM_Asset_Record_Type__c 
                                        from User 
                                        where Id = :UserInfo.getUserId()
                                        Limit 1].AM_Asset_Record_Type__c;

            if(!String.isEmpty(defaultRecordType))
            {
                assetRecordType = defaultRecordType;
            }
            else
            {
                //Add a message that there was an error fetching records
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                                          'E3: Please select an Asset Type in the Home page or contact administrator to set default asset type.'));                
            }
        }
        else
        {
            //Use the parameter value to set the record type
            assetRecordType = recordTypeId;
        }

        return assetRecordType;
    }

    /**
    * Description: Prepare a list of messages to be displayed on the screen
    * Parameters: allMessages - List of all ApexPages.getMessage()
    *             includeSeverity - Messages with these severities should be included in the list
    */
    public static List<ApexPages.Message> prepareMessages(List<ApexPages.Message> allMessages)
    {
        //List of messages to be returned
        list<ApexPages.Message> showMessages = new list<ApexPages.Message>();

        //Loop through the messages and filter out unwanted messages
        for(ApexPages.Message msg: allMessages)
        {
            //Check Severity
            if(msg.getSeverity()==ApexPages.Severity.ERROR)
            {
                showMessages.add(msg);
            }
        }
        return showMessages;       
    }        
}