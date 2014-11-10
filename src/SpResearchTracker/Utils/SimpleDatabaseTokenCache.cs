using Microsoft.IdentityModel.Clients.ActiveDirectory;
using SpResearchTracker.Models;

namespace SpResearchTracker.Utils
{
    /// <summary>
    /// A basic token cache backed by a database, keyed on the given CacheId string.
    /// ADAL will automatically save tokens in the cache whenever you obtain them.  
    /// More details here: http://www.cloudidentity.com/blog/2014/07/09/the-new-token-cache-in-adal-v2/
    /// </summary>
    public class SimpleDatabaseTokenCache : TokenCache
    {
        private readonly string _cacheId;

        public SimpleDatabaseTokenCache(string cacheId)
        {
            _cacheId = cacheId;

            AfterAccess = AfterAccessNotification;
            BeforeAccess = BeforeAccessNotification;
        }

        private static AdCacheDbContext CreateDb()
        {
            return new AdCacheDbContext();
        }

        public void Load()
        {
            using (var db = CreateDb())
            {
                var entry = db.AdCacheEntries.Find(_cacheId);

                if (entry != null)
                {
                    Deserialize(entry.Data);
                }
            }
        }

        public void Persist()
        {
            // Optimistically set HasStateChanged to false. We need to do it early to avoid losing changes made by a concurrent thread.
            HasStateChanged = false;

            // Reflect changes in the persistent store
            byte[] data = Serialize();

            using (var db = CreateDb())
            {
                var entry = db.AdCacheEntries.Find(_cacheId);

                if (entry == null)
                {
                    entry = new CacheEntry { Id = _cacheId };
                    db.AdCacheEntries.Add(entry);
                }

                entry.Data = data;
                db.SaveChanges();
            }
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

            using (var db = CreateDb())
            {
                var entry = db.AdCacheEntries.Find(_cacheId);

                if (entry != null)
                {
                    db.AdCacheEntries.Remove(entry);
                    db.SaveChanges();
                }
            }
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
            // if the access operation resulted in a cache update
            if (HasStateChanged)
            {
                Persist();
            }
        }
    }
}
