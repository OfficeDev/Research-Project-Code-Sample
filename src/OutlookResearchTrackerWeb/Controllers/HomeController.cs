using System.Collections.Generic;
using System.Linq;
using System.Net;
using OutlookResearchTrackerWeb.Models;
using System;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace OutlookResearchTrackerWeb.Controllers
{
    public class HomeController : Controller
    {
        private readonly IResearchRepository _repository;

        public HomeController(IResearchRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public ActionResult QuickLoad()
        {
            return View();
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
        /// [HttpGet]
        public async Task<ActionResult> App(string projectName)
        {
            ViewModel viewModel = new ViewModel {
                SelectedProject = projectName ?? "Select...",
                Projects = await _repository.GetProjects()
            };
            viewModel.Projects.Insert(0, new Project { Title = "Select...", Id = -1, eTag = string.Empty, Type = string.Empty });
            viewModel.ReferenceEntityType = await _repository.GetReferenceEntityType();
            return View(viewModel);
        }

        public async Task<JsonResult> GetReferences(string projectId)
        {
            var references =  await _repository.GetReferences(projectId);

            return Json(references, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public async Task<ActionResult> App(string projectName, string[] referenceLinks, string referenceEntityType)
        {
            if (referenceLinks == null || !referenceLinks.Any())
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);

            IEnumerable<Task<Reference>> tasks = referenceLinks.Select(referenceLink => {
                return _repository.CreateReference(new Reference {
                    Title = string.Empty,
                    Type = referenceEntityType,
                    eTag = "0",
                    Id = 0,
                    Notes = "Created by Outlook",
                    Project = projectName,
                    Url = referenceLink
                });
            });

            try
            {
                await Task.WhenAll(tasks);
            }
            catch (Exception)
            {
                return new HttpStatusCodeResult(HttpStatusCode.InternalServerError);
            }

            return new HttpStatusCodeResult(HttpStatusCode.OK);
        }
    }
}