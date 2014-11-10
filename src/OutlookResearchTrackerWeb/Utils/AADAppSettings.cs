using System;
using System.Configuration;

namespace OutlookResearchTrackerWeb.Utils
{
    public class AADAppSettings
    {
        private static readonly string _resource = ConfigurationManager.AppSettings["ida:Resource"];
        private static readonly string _clientId = ConfigurationManager.AppSettings["ida:ClientId"] ?? ConfigurationManager.AppSettings["ida:ClientID"];
        private static readonly string _appKey = ConfigurationManager.AppSettings["ida:AppKey"] ?? ConfigurationManager.AppSettings["ida:Password"];
        
        private const string AUTHORITY = "https://login.windows.net/common/";
        private const string DISCOVERY_SVC_RESOURCE_ID = "https://api.office.com/discovery/";
        private const string DISCOVERY_SVC_ENDPOINT_URI = "https://api.office.com/discovery/me/";
        private const string GRAPH_SVC_RESOURCE_ID = "https://graph.windows.net";
        private const string AUTHORIZATION_URI = "https://login.windows.net";

        public static string SharePointResourceId { get { return _resource; } }

        public static string ClientId { get { return _clientId; } }

        public static string AppKey { get { return _appKey; } }

        public static string AuthorizationUri { get { return AUTHORIZATION_URI; } }

        public static string Authority { get { return AUTHORITY; } }

        public static string AADGraphResourceId { get { return GRAPH_SVC_RESOURCE_ID; } }

        public static string DiscoveryServiceResourceId { get { return DISCOVERY_SVC_RESOURCE_ID; } }

        public static Uri DiscoveryServiceEndpointUri { get { return new Uri(DISCOVERY_SVC_ENDPOINT_URI); } }
    }
}