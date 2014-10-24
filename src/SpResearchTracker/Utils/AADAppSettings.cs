using System;
using System.Configuration;
using System.Security.Claims;

namespace SpResearchTracker.Utils
{

    public class AADAppSettings
    {
        
        private static string _clientId = ConfigurationManager.AppSettings["ida:ClientId"] ?? ConfigurationManager.AppSettings["ida:ClientID"];
        private static string _appKey = ConfigurationManager.AppSettings["ida:AppKey"] ?? ConfigurationManager.AppSettings["ida:Password"];
        private static string _authorizationUri = ConfigurationManager.AppSettings["ida:AuthorizationUri"];
        private static string _graphResourceId = ConfigurationManager.AppSettings["ida:GraphResourceId"];

        private static string _authority="https://login.windows-ppe.net/common/";
        private static string _discoverySvcResourceId = "https://api.officeppe.com/discovery/";
        private static string _discoverySvcEndpointUri = "https://api.officeppe.com/discovery/me/";

        public static string ClientId
        {
            get
            {
                return _clientId;
            }
        }

        public static string AppKey
        {
            get
            {
                return _appKey;
            }
        }

        public static string AuthorizationUri
        {
            get
            {
                return _authorizationUri;
            }
        }

        public static string Authority
        {
            get
            {
                return _authority;
            }
        }

        public static string AADGraphResourceId
        {
            get
            {
                return _graphResourceId;
            }
        }

        public static string DiscoveryServiceResourceId
        {
            get
            {
                return _discoverySvcResourceId;
            }
        }

        public static Uri DiscoveryServiceEndpointUri
        {
            get
            {
                return new Uri(_discoverySvcEndpointUri);
            }
        }
    }
}
