using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Helpers;
using System.Web.Http;
using System.Web.Http.OData.Batch;

namespace SpResearchTracker.Controllers
{
    public class BreezeODataBatchHandler : DefaultODataBatchHandler
    {
        public BreezeODataBatchHandler(HttpServer server) : base(server) { }

        public override async System.Threading.Tasks.Task<System.Net.Http.HttpResponseMessage> ProcessBatchAsync(System.Net.Http.HttpRequestMessage request, System.Threading.CancellationToken cancellationToken)
        {
            System.Net.Http.HttpResponseMessage response = await base.ProcessBatchAsync(request, cancellationToken);
            OAuthController.RemoveFromCache("cookieToken");
            OAuthController.RemoveFromCache("formToken");
            return response;
        }
        public override void ValidateRequest(System.Net.Http.HttpRequestMessage request)
        {
            string cookieToken = string.Empty;
            string formToken = string.Empty;

            IEnumerable<string> tokenHeaders;
            if (request.Headers.TryGetValues("RequestVerificationToken", out tokenHeaders))
            {
                string[] tokens = tokenHeaders.First().Split(':');
                if (tokens.Length == 2)
                {
                    cookieToken = tokens[0].Trim();
                    formToken = tokens[1].Trim();
                    OAuthController.SaveInCache("cookieToken", cookieToken);
                    OAuthController.SaveInCache("formToken", formToken);
                }
            }

            AntiForgery.Validate(cookieToken, formToken);
            base.ValidateRequest(request);
        }

    }
}