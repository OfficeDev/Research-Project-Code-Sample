using System.Web.Http;
using System.Web.Http.OData.Batch;
using Microsoft.Practices.Unity;
using SpResearchTracker.Models;
using System.Web.Http.OData.Builder;
using SpResearchTracker.Controllers;

namespace SpResearchTracker
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Dependency resolver for dependency injection
            UnityContainer container = new UnityContainer();
            container.RegisterType<IResearchRepository, ResearchRepository>(new HierarchicalLifetimeManager());
            container.RegisterType<IProjectsRepository, ProjectsRepository>(new HierarchicalLifetimeManager());
            container.RegisterType<IReferencesRepository, ReferencesRepository>(new HierarchicalLifetimeManager());
            config.DependencyResolver = new UnityResolver(container);

            config.MapHttpAttributeRoutes();

            // API routes
            config.Routes.MapHttpRoute(
             name: "DefaultApi",
             routeTemplate: "api/{controller}/{id}",
             defaults: new { id = RouteParameter.Optional });

            //OData Models
            ODataModelBuilder odataBuilder = new ODataConventionModelBuilder();
            odataBuilder.Namespace = "SpResearchTracker.Models";
            odataBuilder.EntitySet<Project>("Projects");
            odataBuilder.EntitySet<Reference>("References");

            // OData routes
            config.Routes.MapODataRoute(
              routeName: "odata",
              routePrefix: "odata",
              model: odataBuilder.GetEdmModel(),
              batchHandler: new DefaultODataBatchHandler(GlobalConfiguration.DefaultServer)
            );
        }
    }
}
