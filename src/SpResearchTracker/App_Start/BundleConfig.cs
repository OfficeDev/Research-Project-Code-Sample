using System.Web;
using System.Web.Optimization;

namespace SpResearchTracker {
  public class BundleConfig {
    // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
    public static void RegisterBundles(BundleCollection bundles) {
      bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                  "~/Scripts/jquery-{version}.js"));

      bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                  "~/Scripts/jquery.validate*"));

      // Use the development version of Modernizr to develop with and learn from. Then, when you're
      // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
      bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                  "~/Scripts/modernizr-*"));

      bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                "~/Scripts/bootstrap.js",
                "~/Scripts/respond.js"));

      bundles.Add(new StyleBundle("~/Content/css").Include(
                "~/Content/bootstrap.css",
                "~/Content/bootstrap-theme.css",
                "~/Content/site.css",
                "~/Content/animation.css",
                "~/Content/breeze.directives.css",
                "~/Content/toastr.css"));

      // misc vendor script bundle
      bundles.Add(new ScriptBundle("~/bundles/thirdparty").Include(
                "~/Scripts/spin.js",
                "~/Scripts/toastr.js"));

      // angular bundle
      bundles.Add(new ScriptBundle("~/bundles/angular").Include(
                "~/Scripts/angular.js",
                "~/Scripts/angular-route.js",
                "~/Scripts/angular-sanitize.js",
                "~/Scripts/angular-animate.js",
                "~/Scripts/angular-ui/ui-bootstrap-tpls.js"));

      // breeze bundle
      bundles.Add(new ScriptBundle("~/bundles/breeze").Include(
                "~/Scripts/datajs-1.1.3.js",
                "~/Scripts/q.js",
                "~/Scripts/breeze.debug.js",
                "~/Scripts/breeze.angular.js",
                "~/Scripts/breeze.directives.js"));

      // spa bootstrapping bundle
      bundles.Add(new ScriptBundle("~/bundles/appcore").Include(
                "~/App/app.js",
                "~/App/config.js",
                "~/App/config.route.js",
                "~/App/config.exceptionHandler.js",
                "~/App/config.angular.js",
                "~/App/config.breeze.js"));
      
      // spa common modules
      bundles.Add(new ScriptBundle("~/bundles/appcommonmodules").Include(
                "~/App/common/common.js",
                "~/App/common/logger.js",
                "~/App/common/spinner.js"));

      // spa controllers
      bundles.Add(new ScriptBundle("~/bundles/appcontrollers").Include(
                "~/App/dashboard/dashboard.js",
                "~/App/layout/shell.js",
                "~/App/projects/list.js",
                "~/App/projects/detailView.js", 
                "~/App/projects/detailEdit.js",
                "~/App/references/list.js",
                "~/App/references/detailEdit.js",
                "~/App/bookmarklet/add.js"));

      // spa services
      bundles.Add(new ScriptBundle("~/bundles/appservices").Include(
                "~/App/services/directives.js",
                "~/App/services/datacontext.angular.js",
                "~/App/services/datacontext.breeze.js"));

      // Set EnableOptimizations to false for debugging. For more information,
      // visit http://go.microsoft.com/fwlink/?LinkId=301862
      BundleTable.EnableOptimizations = false;
    }
  }
}
