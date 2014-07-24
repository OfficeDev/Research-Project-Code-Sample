using System.Collections.Generic;

namespace OutlookResearchTrackerWeb.Models
{
    public class ViewModel
    {
    
        public ViewModel(){
            Projects = new List<Project>();
            References = new List<Reference>();
            SelectedProject = "Select...";
        }
        public List<Project> Projects { get; set; }
        public List<Reference> References { get; set; }

        public string SelectedProject { get; set; }
        public string ProjectEntityType { get; set; }
        public string ReferenceEntityType { get; set; }
    }
}