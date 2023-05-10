@isTest 
      public class TestAutoConvertLeads{
      static testMethod void createnewlead() {
      User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      
      Test.startTest();    
      Lead leadToCreate =new Lead();
      List<id> Ids= New List<Id>();
      leadToCreate.ownerid= userToCreate.id;
      leadToCreate.LastName ='Lockwood';
      leadToCreate.Company='City of Kyle';
      leadToCreate.LeadSource='Web';
      leadToCreate.Rating='';
      leadToCreate.Status='';
      insert leadToCreate; 
      
      Ids.add(leadToCreate.id);
      AutoConvertLeads.LeadAssign(Ids);
      
      Test.stopTest();
   }
}