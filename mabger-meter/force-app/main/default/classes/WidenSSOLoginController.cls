public without sharing class WidenSSOLoginController {

    public String redirectURL {get; private set;}
    public Boolean isAuthenticatedWithWiden {get; private set;}

    public WidenSSOLoginController () {
        redirectURL = null;
        isAuthenticatedWithWiden = getSafeBoolean(ApexPages.currentPage().getParameters().get('authenticated'));
    }

    private Boolean getSafeBoolean (String input) {
        if (input == null) return false;
        if (input == 'true') return true;
        if (input == '1') return true;

        return false;
    }

    public PageReference authenticateAndRedirectToWidenDAM () {
        PageReference pr = new PageReference(loginToWidenDAM('/dam/dashboard'));
        return pr; 
    }

    public void authenticateAndRedirectToCommunityHome () {
        /*
        String loginURL = loginToWidenDAM('');
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(loginURL);
        request.setMethod('GET');

        HttpResponse response = new Http().send(request);

        cookieValues = response.getHeader('Set-Cookie');
        System.debug('COOKIES: '+ cookieValues);
        */
        
        //if (!isAuthenticatedWithWiden) {
            String thisPageInCommunity = '/partnercentral/apex/WidenSSOLoginFlow?authenticated=true';
            //String thisPageInCommunity = EncodingUtil.urlEncode('https://test-badgermeter.cs50.force.com/partnercentral/apex/WidenSSOLoginFlow?authenticated=true', 'UTF-8');
            System.debug('REDIRECT URL: '+ thisPageInCommunity);
            
            redirectURL = loginToWidenDAM(thisPageInCommunity);
            //return redirectURL;
            //return new PageReference(redirectURL);
        //}
        //else {
          //  return Auth.SessionManagement.finishLoginFlow();
       // }
        
    }

    public PageReference finishLoginFlow () {
        return Auth.SessionManagement.finishLoginFlow();
    }


    public static User getUserById (Id userId) {
        return [Select Id, Username, FirstName, LastName, Email, Phone, Title, CompanyName, Department, Street, City, State, StateCode, PostalCode, Country, CountryCode, Widen_DAM_Role__c, Profile.Name, Profile.UserLicense.Name, Contact.Account.Market_Libraries__c From User Where Id = :userId];
    }

    public static String loginToWidenDAM (String destinationURL) {
        User u = getUserById(UserInfo.getUserId());

        return loginToWidenDAM(destinationURL, u);
    }


    public static String loginToWidenDAM (String destinationURL, User u) {
        if (u.Email != 'alinsmeier@badgermeter.com') {
            LoginParameters loginParameters = new LoginParameters(u, destinationURL);

            return 'https://assets.badgermeter.com/auth/simple?'+ loginParameters.getRequestBody();
        }
        else return '/';
    }


    public static String loginToWidenDAMAsUser (String destinationURL, Id userId) {
        User u = getUserById(userId);
        return loginToWidenDAM(destinationURL, u);
    }



    private class LoginParameters {

        public Map <String, String> valuesMap;
        public String signature;

        /*
        public String timestamp;
        public String signature;
        public String guid;
        public String email;
        public String username;
        public String first_name;
        public String last_name;
        public String title;
        public String company;
        public String street_address;
        public String city;
        public String state;
        public String zip;
        public String country;
        public String phone;
        public String department;
        public String roles;
        public String registration_code;
        public String redirection_url;
        public String user_metadata_key;
        */


        public LoginParameters (User u, String destinationURL) {
            valuesMap = new Map <String, String> ();

            valuesMap.put('timestamp',           getFormattedTimestamp());
            valuesMap.put('guid',                getGUID());
            
            valuesMap.put('email',               getSafeString(u.Email));
            valuesMap.put('username',            getSafeString(u.Username));
            valuesMap.put('first_name',          getSafeString(u.FirstName));
            valuesMap.put('last_name',           getSafeString(u.LastName));
            valuesMap.put('title',               getSafeString(u.Title));
            valuesMap.put('company',             getSafeString(u.CompanyName));
            valuesMap.put('street_address',      getSafeString(u.Street));
            valuesMap.put('city',                getSafeString(u.City));
            valuesMap.put('state',               getSafeString(u.StateCode));
            valuesMap.put('zip',                 getSafeString(u.PostalCode));
            valuesMap.put('country',             getSafeString(u.CountryCode));
            valuesMap.put('phone',               getSafeString(u.Phone));
            valuesMap.put('department',          getSafeString(u.Department));

            valuesMap.put('roles',               getRoleForWidenDAM(u));
            valuesMap.put('registration_code',   getRegistrationCode());
            valuesMap.put('redirection_url',     getSafeString(destinationURL));
            //valuesMap.put('user_metadata_key',   getUserMetadataKey());

            signature = generateSignature();
        }

        private String getSafeString (String input) {
            return input == null ? '' : input;
        }

        private String getFormattedTimestamp () {
            return Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        }

        private String getGUID () {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            return guid;
        }

        private String getRoleForWidenDAM (User u) {
            if (isExternalUser(u))          return getUserRoleFromContactAccountMarketLibraries(u);
            else /* isInternalUser(u) */    return getUserRoleForInternalUsers(u);
        }

        private String getRegistrationCode () {
            return 'Test Partner Central Registration Code';
        }

        /*
        private String getRedirectionURL () {
            return '/dam/dashboard';
        }
        */

        private String getUserMetadataKey () {
            return 'User Metadata Value';
        }


        private List <String> getExternalLicenseNames () {
            List <String> externalLicenseNames = new List <String> ();
            externalLicenseNames.add('Partner Community');
            return externalLicenseNames;
        }

        private Boolean isExternalUser (User u) {
            String userLicenseName = u.Profile.UserLicense.Name;
            return getExternalLicenseNames().contains(userLicenseName);
        }

        private String getUserRoleFromContactAccountMarketLibraries (User u) {
            if (u.Contact != null && u.Contact.Account != null) {
                String externalUserMarketLibraries = u.Contact.Account.Market_Libraries__c;
                if (!String.isEmpty(externalUserMarketLibraries)) {
                    String reformattedLibraries = externalUserMarketLibraries.replaceAll(';', ', ');
                    return reformattedLibraries;
                }
            }

            // If we failed any of the above conditions, return a blank string.
            // There is something wrong with the external user's market library setup.
            return '';
        }

        private String getUserRoleForInternalUsers (User u) {
            if (u.Widen_DAM_Role__c != null) return u.Widen_DAM_Role__c.replaceAll(';', ', ');
            else return '';
        }

        /*
        private List <String> getValidPartnerCommunityProfileNames () {
            List <String> validPartnerCommunityProfileNames = new List <String> ();
            validPartnerCommunityProfileNames.add('2018 Partner Central Community User');
            return validPartnerCommunityProfileNames;
        }
        */

        private String generateSignature () {
            List <String> orderedKeyList = getOrderedKeyList();

            String valuesString = createValuesString(orderedKeyList) + getSharedSecret();
            //System.debug('VALUE STRING: '+ valuesString);
            Blob valuesBlob = Blob.valueOf(valuesString);
            Blob signatureBlob = Crypto.generateDigest('MD5', valuesBlob);
            String signatureString =  EncodingUtil.convertToHex(signatureBlob);
            //System.debug('SIGNATURE STRING: '+ signatureString);
            return signatureString;
        }

        private List <String> getOrderedKeyList () {
            List <String> orderedKeyList = new List <String> ();
            for (String key : valuesMap.keySet()) orderedKeyList.add(key);
            orderedKeyList.sort();
            return orderedKeyList;
        }

        private String createValuesString (List <String> orderedKeyList) {
            String valuesString = '';
            for (String key : orderedKeyList) valuesString += valuesMap.get(key);
            return valuesString;
        }

        private String getSharedSecret () {
            return '526e49fc-8f62-449f-82a8-39cbf7b2d101';
        }

        public String getRequestBody () {
            String requestBody = '';
            for (String key : valuesMap.keySet()) {
                String value = valuesMap.get(key);
                value = encodeUTF8(value);
                requestBody += (key+'='+value+'&');
                //System.debug('KEY: '+ key +' : '+ value);
            }
            requestBody += ('signature='+signature);
            //System.debug('KEY: signature : '+ signature);
            return requestBody;
        }


        private String encodeUTF8 (String input) {
            return input == null ? '' : EncodingUtil.urlEncode(input, 'UTF-8');//.replaceAll('\\+','%20');
        }
    }
}