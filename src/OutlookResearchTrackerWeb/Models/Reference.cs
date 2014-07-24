using OutlookResearchTrackerWeb.Utils;
using System.Xml.Linq;

namespace OutlookResearchTrackerWeb.Models
{
    public class Reference
    {
        public int Id { get; set; }
        public string Type { get; set; }
        public string eTag { get; set; }
        public string Title { get; set; }
        public string Url { get; set; }
        public string Notes { get; set; }
        public string Project { get; set; }

        /// <summary>
        /// Converts a Reference to XML
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
                            new XElement(ExtensionMethods.d + "URL", new XAttribute(ExtensionMethods.m + "type", "SP.FieldUrlValue"),
                                new XElement(ExtensionMethods.d + "Description", this.Title),
                                new XElement(ExtensionMethods.d + "Url", this.Url)),
                            new XElement(ExtensionMethods.d + "Comments", this.Notes),
                            new XElement(ExtensionMethods.d + "Project", this.Project))));
        }
    }
}