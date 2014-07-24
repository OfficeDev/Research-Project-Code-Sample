
namespace WordResearchTrackerWeb.Models
{
    public class Reference
    {
        public Reference() { }

        public Reference(int Id, string Title, string Url, string Notes, string Project)
        {
            this.Id = Id;
            this.Title = Title;
            this.Url = Url;
            this.Notes = Notes;
            this.Project = Project;
        }
        public int Id { get; set; }
        public string Title { get; set; }
        public string Url { get; set; }
        public string Notes { get; set; }
        public string Project { get; set; }

    }
}