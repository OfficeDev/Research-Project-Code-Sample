package com.microsoft.researchtracker.sharepoint;

import android.text.TextUtils;

import com.google.gson.JsonElement;
import com.microsoft.researchtracker.http.HttpMerge;
import com.microsoft.researchtracker.http.JsonClientBase;
import com.microsoft.researchtracker.sharepoint.odata.Query;
import com.microsoft.researchtracker.sharepoint.odata.QueryOperations;

import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;

import java.io.IOException;

public class ListsClient extends JsonClientBase {

    private final String mSharePointUrl;
    private final String mSitePath;

    public ListsClient (final String sharepointUrl, final String sitePath, final OAuthCredentials credentials) {
        super(credentials);
        if (TextUtils.isEmpty(sharepointUrl)) {
            throw new IllegalArgumentException("SharepointUrl required");
        }
        if (credentials == null) {
            throw new IllegalArgumentException("Credentials required");
        }

        mSharePointUrl = sharepointUrl;
        mSitePath = sitePath == null ? "" : sitePath;

    }

    private String getListUrl(final String listTitle) {

        final String listTitleToken = UrlUtil.encodeComponent(QueryOperations.val(listTitle).toString());

        return String.format("%s/%s/_api/Lists/getByTitle(%s)", mSharePointUrl, mSitePath, listTitleToken);
    }

    private String getListItemsUrl(final String listTitle) {

        return getListUrl(listTitle) + "/items";
    }

    private String getListItemUrl(final String listTitle, final int id) {

        return getListUrl(listTitle) + "/items(" + UrlUtil.encodeComponent(QueryOperations.val(id).toString()) + ")";
    }

    public SPObject getList(final String listTitle) throws IOException {

        String url = getListUrl(listTitle);

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPObject(element.getAsJsonObject());
    }

    public SPObject getListItemById(final String listTitle, final int id) throws IOException {

        String url = getListItemUrl(listTitle, id);

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPObject(element.getAsJsonObject());
    }

    public SPCollection getListItems(final String listTitle, final Query query) throws IOException {

        String url = getListItemsUrl(listTitle);

        if (query != null) {
            url +=
                "?$filter=" +
                    UrlUtil.encodeComponent(query.toString()) +
                    query.getQueryParameters();
        }

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPCollection(element.getAsJsonObject());
    }

    public void createListItem(final String listTitle, SPObject data) throws IOException {

        String url = getListItemsUrl(listTitle);

        HttpPost request = new HttpPost(url);

        request.setEntity(createJsonEntity(data.toJson()));

        executeVoidRequest(request);
    }

    public void updateListItem(final String listTitle, final int id, final SPETag eTag, SPObject data) throws IOException {

        String url = getListItemUrl(listTitle, id);

        HttpMerge request = new HttpMerge(url);

        if (eTag != null) {
            request.addHeader("If-Match", eTag.getValue());
        }

        request.setEntity(createJsonEntity(data.toJson()));

        executeVoidRequest(request);
    }

    public void deleteListItem(final String listTitle, final int id, final SPETag eTag) throws IOException {

        String url = getListItemUrl(listTitle, id);

        HttpDelete request = new HttpDelete(url);

        if (eTag != null) {
            request.addHeader("If-Match", eTag.getValue());
        }

        executeVoidRequest(request);
    }
}
