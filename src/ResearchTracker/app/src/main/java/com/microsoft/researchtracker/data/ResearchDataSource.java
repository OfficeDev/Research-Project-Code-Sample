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

public class ResearchDataSource {

    private static final String TAG = "ResearchDataSource";

    private final ListsClient mClient;

    public ResearchDataSource(ListsClient client) {

        mClient = client;
    }

    public List<ResearchProjectModel> getResearchProjects() throws IOException {

        Query query = QueryOperations.select(ResearchProjectModel.FIELDS);

        SPCollection result = mClient.getListItems(Constants.RESEARCH_PROJECTS_LIST, query);

        List<ResearchProjectModel> items = new ArrayList<ResearchProjectModel>();

        if (result != null) {
            for (SPObject listItemData : result.getValue()) {
                items.add(new ResearchProjectModel(listItemData));
            }
        }

        return items;
    }

    public ResearchProjectModel getResearchProjectById(int projectId) throws IOException {

        Query query = QueryOperations.select(ResearchProjectModel.FIELDS);

        SPObject projectData = mClient.getListItemById(Constants.RESEARCH_PROJECTS_LIST, projectId, query);

        return new ResearchProjectModel(projectData);
    }

    public List<ResearchReferenceModel> getResearchReferencesByProjectId(int projectId) throws IOException {

        Query query = QueryOperations.field("Project").eq().val(projectId)
                                           .select(ResearchReferenceModel.FIELDS);

        SPCollection result = mClient.getListItems(Constants.RESEARCH_REFERENCES_LIST, query);

        List<ResearchReferenceModel> items = new ArrayList<ResearchReferenceModel>();

        if (result != null) {
            for (SPObject listItemData : result.getValue()) {
                items.add(new ResearchReferenceModel(listItemData));
            }
        }

        return items;
    }

    public ResearchReferenceModel getResearchReferenceById(int referenceId) throws IOException {

        Query query = QueryOperations.select(ResearchReferenceModel.FIELDS);

        SPObject result = mClient.getListItemById(Constants.RESEARCH_REFERENCES_LIST, referenceId, query);

        return new ResearchReferenceModel(result);
    }

    public void deleteResearchProject(int projectId, SPETag eTag) throws IOException {

        mClient.deleteListItem(Constants.RESEARCH_PROJECTS_LIST, projectId, eTag);
    }

    public void createResearchProject(ResearchProjectModel model) throws IOException {

        mClient.createListItem(Constants.RESEARCH_PROJECTS_LIST, model.getInternalData());
    }

    public void updateResearchProject(int projectId, SPETag eTag, ResearchProjectModel model) throws IOException {

        mClient.updateListItem(Constants.RESEARCH_PROJECTS_LIST, projectId, eTag, model.getInternalData());
    }

    public void deleteResearchReference(int referenceId, SPETag eTag) throws IOException {

        mClient.deleteListItem(Constants.RESEARCH_REFERENCES_LIST, referenceId, eTag);
    }

    public void createResearchReference(ResearchReferenceModel model) throws IOException {

        mClient.createListItem(Constants.RESEARCH_REFERENCES_LIST, model.getInternalData());
    }

    public void updateResearchReference(int referenceId, SPETag referenceETag, ResearchReferenceModel model) throws IOException {

        mClient.updateListItem(Constants.RESEARCH_REFERENCES_LIST, referenceId, referenceETag, model.getInternalData());
    }
}
