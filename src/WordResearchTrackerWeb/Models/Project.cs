
namespace WordResearchTrackerWeb.Models
{
    public class Project
    {
        public Project()
        { }

        public Project(int Id, string Title)
        {
            this.Id = Id;
            this.Title = Title;
        }
        public int Id { get; set; }   
        public string Title { get; set; }

    }
}