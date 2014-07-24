using OutlookResearchTrackerWeb.Utils;
using System.Xml.Linq;

namespace OutlookResearchTrackerWeb.Models
{
    public class Project
    {
        public int Id { get; set; }
        public string Type { get; set; }
        public string eTag { get; set; }
        public string Title { get; set; }

        /// <summary>
        /// Converts a Project to XML
        /// </summary>
        /// <returns>XElement</returns>
        public XElement ToXElement()
        {
            return new XElement(ExtensionMethods.atom + "entry",
                    new XAttribute(XNamespace.Xmlns + "d", ExtensionMethods.d),
                    new XAttribute(XNamespace.Xmlns + "m", ExtensionMethods.m),
                    new XElement(ExtensionMethods.atom + "category", new XAttribute("term", this.Type), new XAttribute("scheme", "http://schemas.microsoft.com/ado/2007/08/dataservices/scheme")),
                    new XElement(ExtensionMethods.atom + "content", new XAttribute("type", "application/xml"),
                        new XElement(ExtensionMethods.m + "properties",
                            new XElement(ExtensionMethods.d + "Title", this.Title))));
        }
    }

}