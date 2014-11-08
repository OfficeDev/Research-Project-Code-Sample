using System.Web.Mvc;

namespace SpResearchTracker.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return RedirectToAction("SPA");
        }

        public ActionResult SPA()
        {
            if (!Request.IsAuthenticated)
            {
                return RedirectToAction("SignIn", "Account");
            }

            //This method just returns the view where the SPA is located
            return View();
        }
    }
}