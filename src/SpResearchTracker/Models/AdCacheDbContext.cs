using System.Data.Entity;

namespace SpResearchTracker.Models
{
    public class AdCacheDbContext : DbContext
    {
        public AdCacheDbContext()
            : base("DefaultConnection")
        {

        }

        public DbSet<CacheEntry> AdCacheEntries { get; set; }
    }
}