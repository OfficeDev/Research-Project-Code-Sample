using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Mvc;
using WordResearchTrackerWeb.Models;

namespace WordResearchTrackerWeb.Controllers
{
    public class HomeController : Controller
    {
        private readonly IResearchRepository _repository;

        public HomeController(IResearchRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public ActionResult Index()
        {
            return RedirectToAction("SignIn", "Account");
        }

        /// <summary>
        /// This action creates a view model with a collection of projects and references
        /// It is the main page of the app
        /// </summary>
        /// <param name="projectName"></param>
        /// <returns>ActionResult(ViewModel)</returns>
        [HttpGet]
        public async Task<ActionResult> App(string projectName)
        {
            ViewModel viewModel = new ViewModel();
            viewModel.SelectedProject = projectName ?? "Select...";
            viewModel.Projects = await _repository.GetProjects();
            viewModel.Projects.Insert(0, new Project { Title = "Select...", Id = -1 });
            return View(viewModel);
        }

        [HttpGet]
        public async Task<JsonResult> GetReferences(string projectName)
        {
            if (string.IsNullOrWhiteSpace(projectName))
            {
                return Json(new object[0], JsonRequestBehavior.AllowGet);
            }

            List<Reference> references = await _repository.GetReferences(projectName);

            return Json(references, JsonRequestBehavior.AllowGet);
        }
    }
}