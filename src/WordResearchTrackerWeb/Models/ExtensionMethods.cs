using System.Linq;
using System.Xml.Linq;

namespace WordResearchTrackerWeb.Models
{
    public static class ExtensionMethods
    {
        public static XNamespace atom = "http://www.w3.org/2005/Atom";
        public static XNamespace d = "http://schemas.microsoft.com/ado/2007/08/dataservices";
        public static XNamespace m = "http://schemas.microsoft.com/ado/2007/08/dataservices/metadata";

         public static Project ToProject(this XElement root)
        {
            string sptype = root.Elements().Where(e => e.Name.LocalName == "category").First().Attribute("term").Value;
            XElement properties = root.Descendants(m + "properties").First();
            int id = int.Parse(properties.Descendants(d + "ID").First().Value);
            string title = properties.Descendants(d + "Title").First().Value;
            return new Project(id, title);
        }

        public static Reference ToReference(this XElement root)
        {
            string sptype = root.Elements().Where(e => e.Name.LocalName == "category").First().Attribute("term").Value;
            XElement properties = root.Descendants(m + "properties").First();
            int id = int.Parse(properties.Descendants(d + "ID").First().Value);
            string notes = properties.Descendants(d + "Comments").First().Value;
            string project = properties.Descendants(d + "Project").First().Value;
            XElement URL = properties.Descendants(d + "URL").First();
            string url = URL.Descendants(d + "Url").First().Value;
            string title = URL.Descendants(d + "Description").First().Value;
            return new Reference(id, title, url, notes, project);
        }
 
    }
}