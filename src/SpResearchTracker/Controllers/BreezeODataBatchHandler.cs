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
            return response;
        }
    }
}