using Microsoft.Owin;
using Owin;

[assembly: OwinStartup(typeof(SpResearchTracker.Startup))]
namespace SpResearchTracker
{
    /// <summary>
    /// Every OWIN Application has a startup class where you specify components for the application pipeline. 
    /// More details here: http://www.asp.net/aspnet/overview/owin-and-katana/owin-startup-class-detection
    /// </summary>
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}