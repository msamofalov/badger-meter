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

/* Description: This class contains all constants used in this app's Apex classes */

public with sharing class AM_Constants {

    //AM_Asset AM_Status__c values
    public static final String AM_ASSET_STATUS_AVAILABLE = 'Inventory';
    public static final String AM_ASSET_STATUS_ASSIGNED = 'Loaned';
    public static final String AM_ASSET_STATUS_OUTOFSERVICE = 'OutofService';

    //Constant for AM_Asset__c object type
    public static final String AM_ASSET_API_NAME = 'Asset';

    //Constant for CONTACT object type
    public static final String AM_CONTACT_API_NAME = 'Contact';    

    //Constant for AM_Status__c field name
    public static final String AM_STATUS_API_NAME = 'Status';  

    //Constant for Case Record Type Name
    public static final String AM_CASE_RT_NAME = 'Case';  

    //Constant for Dynamic SOQL 
    //'Where'
    public static final String AM_WHERE = String.escapeSingleQuotes('where');
    //'Like'
    public static final String AM_LIKE = String.escapeSingleQuotes('Like');
    //'AND'
    public static final String AM_AND = String.escapeSingleQuotes('AND');
    //'OR'
    public static final String AM_OR = String.escapeSingleQuotes('OR');
    //'SPACE'
    public static final String AM_SPACE = String.escapeSingleQuotes(' ');
}