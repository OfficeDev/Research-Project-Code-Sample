using System.Web;
using Microsoft.IdentityModel.Clients.ActiveDirectory;

namespace OutlookResearchTrackerWeb.Utils
{
    /// <summary>
    /// A simple token cache which stores its data in the System.Web.Caching.Cache.
    /// </summary>
    public class SimpleTokenCache : TokenCache
    {
        private const string CACHE_KEY_PREFIX = "ADCACHE_";

        private readonly string _nameIdentifier;

        public SimpleTokenCache(string nameIdentifier)
        {
            _nameIdentifier = nameIdentifier;

            AfterAccess = AfterAccessNotification;
            BeforeAccess = BeforeAccessNotification;
        }

        public void Load()
        {
            byte[] data = HttpContext.Current.Cache[CACHE_KEY_PREFIX + _nameIdentifier] as byte[];

            Deserialize(data);
        }

        public void Persist()
        {
            // Optimistically set HasStateChanged to false. We need to do it early to avoid losing changes made by a concurrent thread.
            HasStateChanged = false;

            // Reflect changes in the persistent store
            byte[] data = Serialize();

            HttpContext.Current.Cache[CACHE_KEY_PREFIX + _nameIdentifier] = data;
        }

        public override void DeleteItem(TokenCacheItem item)
        {
            base.DeleteItem(item);
            Persist();
        }

        /// <summary>
        /// Empties the persistent store.
        /// </summary>
        public override void Clear()
        {
            base.Clear();

            HttpContext.Current.Cache.Remove(CACHE_KEY_PREFIX + _nameIdentifier);
        }

        /// <summary>
        /// Triggered right before ADAL needs to access the cache.
        /// Reload the cache from the persistent store in case it changed since the last access.
        /// </summary>
        private void BeforeAccessNotification(TokenCacheNotificationArgs args)
        {
            Load();
        }

        /// <summary>
        /// Triggered right after ADAL accessed the cache.
        /// </summary>
        private void AfterAccessNotification(TokenCacheNotificationArgs args)
        {
            if (HasStateChanged)
            {
                Persist();
            }
        }
    }
}