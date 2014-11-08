using Microsoft.IdentityModel.Clients.ActiveDirectory;
using SpResearchTracker.Models;

namespace SpResearchTracker.Utils
{
    /// <summary>
    /// A basic token cache using current session
    /// ADAL will automatically save tokens in the cache whenever you obtain them.  
    /// More details here: http://www.cloudidentity.com/blog/2014/07/09/the-new-token-cache-in-adal-v2/
    /// Warning: If the session is lost, the user will need to sign out and then in again.
    /// </summary>
    public class SimpleDatabaseCache : TokenCache
    {
        private readonly AdCacheDbContext _db;
        private readonly string _cacheId;

        private CacheEntry _entry;

        public SimpleDatabaseCache(string userId)
        {
            _db = new AdCacheDbContext();
            _cacheId = userId;

            AfterAccess = AfterAccessNotification;
            BeforeAccess = BeforeAccessNotification;
        }

        private CacheEntry GetCacheEntry()
        {
            return _entry ?? (_entry = _db.AdCacheEntries.Find(_cacheId));
        }

        public void Load()
        {
            var entry = GetCacheEntry();

            if (entry != null)
            {
                Deserialize(entry.Data);
            }
        }

        public void Persist()
        {
            // Optimistically set HasStateChanged to false. We need to do it early to avoid losing changes made by a concurrent thread.
            HasStateChanged = false;

            // Reflect changes in the persistent store
            byte[] data = Serialize();

            var entry = GetCacheEntry();

            if (entry == null)
            {
                entry = new CacheEntry { Id = _cacheId };
                _db.AdCacheEntries.Add(entry);
            }

            entry.Data = data;
            _db.SaveChanges();
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

            var entry = GetCacheEntry();

            if (entry != null)
            {
                _db.AdCacheEntries.Remove(entry);
                _db.SaveChanges();
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
