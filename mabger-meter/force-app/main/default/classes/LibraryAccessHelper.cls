public class LibraryAccessHelper {

    public static void updateAccess (Account singleAccount) {
        updateAccess(singleAccount, false);
    }
    public static void updateAccess (Account singleAccount, Boolean debug) {
        try {
            // Bypass the qualification filter and just recalculate library permissions for a single account.
            updateAccessForQualifiedAccounts(new List <Account> {singleAccount}, debug);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
            System.debug(ex.getStackTraceString());
        }
    }
    
    
    public static void updateAccess (List <Account> newAccountVersions, Map <Id, Account> oldAccountVersions) {
      updateAccess(newAccountVersions, oldAccountVersions, false);
    }
    public static void updateAccess (List <Account> newAccountVersions, Map <Id, Account> oldAccountVersions, Boolean debug) {
        try {
            // Perform a check to see if an account has had the Market Libraries field changed, thus qualifying it.
            List <Account> qualifyingAccounts = filterForMarketLibraryChange(newAccountVersions, oldAccountVersions);
            
            // Pass in the qualified list to the updating method.
            updateAccessForQualifiedAccounts(qualifyingAccounts, debug);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
            System.debug(ex.getStackTraceString());
        }
    }
    
    
    private static List <Account> filterForMarketLibraryChange (List <Account> newAccountVersions, Map <Id, Account> oldAccountVersions) {
        // This list will contain accounts that have had their market library changed.
        List <Account> qualifyingAccounts = new List <Account> ();
        
        for (Account newAccountVersion : newAccountVersions) {
            if (newAccountVersion.Market_Libraries__c != oldAccountVersions.get(newAccountVersion.Id).Market_Libraries__c) {
                qualifyingAccounts.add(newAccountVersion);
            }
        }
        
        return qualifyingAccounts;
    }
    
    
    private static void updateAccessForQualifiedAccounts (List <Account> qualifyingAccounts, Boolean debug) {
        List <Id> accountIds = new List <Id> ();
        for (Account a : qualifyingAccounts) accountIds.add(a.Id);
        
      If (accountIds.size() > 0) executeGroupSharingUpdates(accountIds, debug);
    }
    
    
    @Future
    private static void executeGroupSharingUpdates (List <Id> accountIds, Boolean debug) {
      // Load the indicated accounts.
      List <Account> qualifiedAccounts = [Select Id, Market_Libraries__c From Account Where Id in :accountIds];
        
        // Get sets of the users and groups involved for proper targeting of group memberships.
        Set <User>   involvedUsers   = getInvolvedUsers(qualifiedAccounts);
        Set <Group> involvedGroups   = getInvolvedGroups(qualifiedAccounts);
        
        // Get a map of the groups so we can reference them by name.
        Map <String, Group> nameToGroupMap = getNameToGroupMap(involvedGroups);
        
        // Get mappings of the users and groups keyed by account.
        Map <Id, List <User>>   accountIdToUsersMap   = getAffectedUsers(qualifiedAccounts);
         Map <Id, List <Group>>   accountIdToGroupsMap   = getAffectedGroups(qualifiedAccounts, nameToGroupMap);
        
        // Target all current group memberships for deletion.
        List <GroupMember> currentGroupMembershipsForDeletion = getGroupMembershipsForDeletion(involvedUsers, involvedGroups);
        
        
        // Iterate over the accounts and start to build the group memberships.
        List <GroupMember> newGroupMembershipsToInsert = new List <GroupMember> ();
        for (Account a : qualifiedAccounts) {
            List <User> accountUsers   = accountIdToUsersMap.get(a.Id);
            List <Group> accountGroups   = accountIdToGroupsMap.get(a.Id);
            
            if (accountUsers != null && accountGroups != null) {
                for (User u : accountUsers) {
                    for (Group g : accountGroups) {
                        newGroupMembershipsToInsert.add(new GroupMember (GroupId=g.Id, UserOrGroupId=u.Id));
                    }
                }
            }
        }
        
        // Perform the deletions and inserts.
        Savepoint sp = Database.setSavepoint();
        try {
            delete currentGroupMembershipsForDeletion;
            insert newGroupMembershipsToInsert;
        }
        catch (Exception ex) {
            Database.rollback(sp);
        }
    }
    
    
    private static List <GroupMember> getGroupMembershipsForDeletion (Set <User> involvedUsers, Set <Group> involvedGroups) {
        return [Select Id From GroupMember Where /*GroupId in :involvedGroups and*/ UserOrGroupId in :involvedUsers];
    }
    
    
    
    private static Set <User> getInvolvedUsers (List <Account> qualifiedAccounts) {
        Set <User> involvedUsers = new Set <User> ();
        for (User u : [Select Id, AccountId From User Where AccountId in :qualifiedAccounts]) involvedUsers.add(u);
        return involvedUsers;
    }
    
    private static Set <Group> getInvolvedGroups (List <Account> qualifiedAccounts) {
        Set <String> involvedGroupNames = new Set <String> ();
        
        for (Account a : qualifiedAccounts) {
            if (!String.isBlank(a.Market_Libraries__c)) {
                String[] libraries = a.Market_Libraries__c.split(';');
                for (String s : libraries) {
                    if (!String.isBlank(s)) {
                        involvedGroupNames.add(s);
                    }
                }
            }
        }
        
        Set <Group> involvedGroups = new Set <Group> ();
        for (Group g : [Select Id, Name From Group Where Name in :involvedGroupNames]) involvedGroups.add(g);
        return involvedGroups;
    }
    
    
    
    private static Map <String, Group> getNameToGroupMap (Set <Group> groups) {
        Map <String, Group> groupMap = new Map <String, Group> ();
        for (Group g : groups) groupMap.put(g.Name, g);
        return groupMap;
    }
    
    
    private static Map <Id, List <Group>> getAffectedGroups (List <Account> qualifiedAccounts, Map <String, Group> involvedGroups) {
        
        
        // This will contain each account's groups.
        Map <Id, List <Group>> accountsToGroupsMap = new Map <Id, List <Group>> ();
        
        for (Account a : qualifiedAccounts) {
            if (!String.isBlank(a.Market_Libraries__c)) {
                String[] libraries = a.Market_Libraries__c.split(';');
                for (String s : libraries) {
                    if (!String.isBlank(s) && involvedGroups.containsKey(s)) {
                        if (!accountsToGroupsMap.containsKey(a.Id)) accountsToGroupsMap.put(a.Id, new List <Group> ());
                        accountsToGroupsMap.get(a.Id).add(involvedGroups.get(s));
                    }
                }
            }
        }
        
        return accountsToGroupsMap;
    }
    
    
    private static Map <Id, List <User>> getAffectedUsers (List <Account> qualifiedAccounts) {
        // This will contain each account's users.
        Map <Id, List <User>> accountsToUsersMap = new Map <Id, List <User>> ();
        
        for (User u : [Select Id, AccountId From User Where AccountId in :qualifiedAccounts]) {
            if (!accountsToUsersMap.containsKey(u.AccountId)) accountsToUsersMap.put(u.AccountId, new List <User> ());
            accountsToUsersMap.get(u.AccountId).add(u);
        }
        
        return accountsToUsersMap;
    }
    
    
}