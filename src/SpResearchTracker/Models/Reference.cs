using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Linq;
using SpResearchTracker.Utils;
using System.Runtime.Serialization;
using System.Configuration;
using SpResearchTracker.Controllers;

namespace SpResearchTracker.Models
{
    [DataContract]
    public class Reference
    {
        public string ReferencesListName = ConfigurationManager.AppSettings["ReferencesListName"];

        public Reference(){}

        public Reference(int Id, string eTag, string Title, string Url, string Notes, string Project)
        {
            this.Id = Id;
            this.Title = Title;
            this.Url = Url;
            this.Notes = Notes;
            this.Project = Project;
            __eTag = eTag;
        }

        [DataMember]
        public int Id { get; set; }

        [DataMember]
        public string __eTag { get; set; }

        [DataMember]
        public string Title { get; set; }

        [DataMember]
        public string Url { get; set; }

        [DataMember]
        public string Notes { get; set; }

        [DataMember]
        public string Project { get; set; }

        public XElement ToXElement()
        {
            return new XElement(ExtensionMethods.atom + "entry",
                    new XAttribute(XNamespace.Xmlns + "d", ExtensionMethods.d),
                    new XAttribute(XNamespace.Xmlns + "m", ExtensionMethods.m),
                    new XElement(ExtensionMethods.atom + "category", new XAttribute("term", OAuthController.GetFromCache(this.ReferencesListName)), new XAttribute("scheme", "http://schemas.microsoft.com/ado/2007/08/dataservices/scheme")),
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