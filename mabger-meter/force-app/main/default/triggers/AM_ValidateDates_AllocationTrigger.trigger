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
/*Description: Validate that asset is not double-allocated.
*---------------------------------------------------------------------------
*     Date     |        Description                |
*---------------------------------------------------------------------------
*  06/25/2014      Created Trigger to validate that asset allocation dates are available
*/

trigger AM_ValidateDates_AllocationTrigger on Asset_Inventory_Allocation__c (before insert, before update) {
    List<Id> assetIdList = new List<Id>();
    for (Asset_Inventory_Allocation__c alloc : Trigger.New) {
        assetIdList.add(alloc.Asset__c);
    }
    
    List<Asset> assetList = [select Id from Asset where Id IN : assetIdList];
    List<Asset_Inventory_Allocation__c> allocSiblings = [Select Id, Start_date__c, End_Date__c, Asset__c from Asset_Inventory_Allocation__c where Asset__c IN: assetList AND Id NOT IN: Trigger.New];
    System.debug('List of asset allocation siblings: ' + allocSiblings);

    for (Asset_Inventory_Allocation__c alloc : Trigger.New) {
        for (Asset_Inventory_Allocation__c sibling : allocSiblings) {
            if (alloc.Start_date__c >= sibling.Start_date__c && alloc.End_Date__c <= sibling.End_Date__c || 
                alloc.Start_date__c <= sibling.Start_date__c && alloc.End_Date__c >= sibling.End_Date__c ||
                alloc.Start_date__c <= sibling.Start_date__c && alloc.End_Date__c <= sibling.End_Date__c && alloc.End_Date__c >= sibling.Start_date__c ||
                alloc.Start_date__c >= sibling.Start_date__c && alloc.End_Date__c >= sibling.End_Date__c && alloc.Start_date__c <= sibling.End_Date__c) {
                alloc.addError('The asset is already allocated for the specified dates. Please choose available dates or select a different asset.');
            }
        }
    }
    

}