package com.microsoft.researchtracker.data;

import com.microsoft.researchtracker.Constants;
import com.microsoft.researchtracker.sharepoint.ListsClient;
import com.microsoft.researchtracker.sharepoint.SPCollection;
import com.microsoft.researchtracker.sharepoint.SPETag;
import com.microsoft.researchtracker.sharepoint.SPObject;
import com.microsoft.researchtracker.sharepoint.models.ResearchProjectModel;
import com.microsoft.researchtracker.sharepoint.models.ResearchReferenceModel;
import com.microsoft.researchtracker.http.odata.Query;
import com.microsoft.researchtracker.http.odata.QueryOperations;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ResearchRepository {

    private static final String TAG = "ResearchRepository";

    private final ListsClient mClient;

    public ResearchRepository(ListsClient client) {

        mClient = client;
    }

    public List<ResearchProjectModel> getResearchProjects() throws IOException {

        final SPCollection result = mClient.getListItems(Constants.RESEARCH_PROJECTS_LIST, null);

        final List<ResearchProjectModel> items = new ArrayList<ResearchProjectModel>();

        if (result != null) {
            for (final SPObject listItemData : result.getValue()) {
                items.add(new ResearchProjectModel(listItemData));
            }
        }

        return items;
    }

    public ResearchProjectModel getResearchProjectById(final int projectId) throws IOException {

        final SPObject projectData = mClient.getListItemById(Constants.RESEARCH_PROJECTS_LIST, projectId);

        return new ResearchProjectModel(projectData);
    }

    public List<ResearchReferenceModel> getResearchReferencesByProjectId(final int projectId) throws IOException {

        final Query query = QueryOperations.field("Project").eq().val(projectId);
        final SPCollection result = mClient.getListItems(Constants.RESEARCH_REFERENCES_LIST, query);

        final List<ResearchReferenceModel> items = new ArrayList<ResearchReferenceModel>();

        if (result != null) {
            for (final SPObject listItemData : result.getValue()) {
                items.add(new ResearchReferenceModel(listItemData));
            }
        }

        return items;
    }

    public void deleteResearchProject(final int projectId, final SPETag eTag) throws IOException {

        mClient.deleteListItem(Constants.RESEARCH_PROJECTS_LIST, projectId, eTag);
    }

    public void createResearchProject(final ResearchProjectModel model) throws IOException {

        mClient.createListItem(Constants.RESEARCH_PROJECTS_LIST, model.getInternalData());
    }

    public void updateResearchProject(final int projectId, final SPETag eTag, final ResearchProjectModel model) throws IOException {

        mClient.updateListItem(Constants.RESEARCH_PROJECTS_LIST, projectId, eTag, model.getInternalData());
    }
}
