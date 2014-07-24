using SpResearchTracker.Utils;
using System.Runtime.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Linq;
using SpResearchTracker.Controllers;
using System.Configuration;

namespace SpResearchTracker.Models
{
    [DataContract]
    public class Project
    {
        public string ProjectsListName = ConfigurationManager.AppSettings["ProjectsListName"];

        public Project()
        {        }

        public Project(int Id, string eTag, string Title)
        {
            this.Id = Id;
            this.Title = Title;
            __eTag = eTag;
        }
        

        [DataMember]
        public int Id { get; set; }
        
        [DataMember]
        public string __eTag { get; set; }

        [DataMember]
        public string Title { get; set; }

        public XElement ToXElement()
        {
            return new XElement(ExtensionMethods.atom + "entry",
                    new XAttribute(XNamespace.Xmlns + "d", ExtensionMethods.d),
                    new XAttribute(XNamespace.Xmlns + "m", ExtensionMethods.m),
                    new XElement(ExtensionMethods.atom + "category", new XAttribute("term", OAuthController.GetFromCache(this.ProjectsListName)), new XAttribute("scheme", "http://schemas.microsoft.com/ado/2007/08/dataservices/scheme")),
                    new XElement(ExtensionMethods.atom + "content", new XAttribute("type", "application/xml"),
                        new XElement(ExtensionMethods.m + "properties",
                            new XElement(ExtensionMethods.d + "Title", this.Title))));
        }
    }
}