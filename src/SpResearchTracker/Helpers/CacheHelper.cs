using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SpResearchTracker.Helpers
{
    public static class CacheHelper
    {
        //
        // This sample uses ASP.Net session state to cache access tokens and refresh tokens for the user.
        // You can also cache these tokens in a database, keyed to the user's identity.
        // If cached in a database, the tokens can be stored across user sessions, and can be used when the user isn't present.
        //
        private const string CachePrefix = "WindowsAzureAdCache#";
        internal static void SaveInCache(string name, object value)
        {
            System.Web.HttpContext.Current.Session[CachePrefix + name] = value;
        }

        internal static object GetFromCache(string name)
        {
            return System.Web.HttpContext.Current.Session[CachePrefix + name];
        }
    }
}