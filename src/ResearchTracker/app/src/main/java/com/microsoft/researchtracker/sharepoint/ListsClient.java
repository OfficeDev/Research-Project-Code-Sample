package com.microsoft.researchtracker.sharepoint;

import android.text.TextUtils;

import com.google.gson.JsonElement;
import com.microsoft.researchtracker.http.HttpMerge;
import com.microsoft.researchtracker.http.odata.JsonClientBase;
import com.microsoft.researchtracker.http.odata.Query;
import com.microsoft.researchtracker.http.odata.QueryOperations;

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

    private String getListUrl(final String listTitle, final Query query) {

        final String listTitleToken = UrlUtil.encodeComponent(QueryOperations.val(listTitle).toString());

        return String.format("%s/%s/_api/Lists/getByTitle(%s)%s",
            mSharePointUrl,
            mSitePath,
            listTitleToken,
            (query == null) ? "" : query.getQueryParameters()
        );
    }

    private String getListItemsUrl(final String listTitle, final Query query) {

        return getListUrl(listTitle, null) +
                    "/items" +
                    ((query == null) ? "" : query.getQueryParameters());
    }

    private String getListItemUrl(final String listTitle, final int id, final Query query) {

        return getListUrl(listTitle, null) +
                    "/items(" + id + ")" +
                    ((query == null) ? "" : query.getQueryParameters());
    }

    public SPObject getList(final String listTitle, final Query query) throws IOException {

        String url = getListUrl(listTitle, query);

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPObject(element.getAsJsonObject());
    }

    public SPObject getListItemById(final String listTitle, final int id, final Query query) throws IOException {

        String url = getListItemUrl(listTitle, id, query);

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPObject(element.getAsJsonObject());
    }

    public SPCollection getListItems(final String listTitle, final Query query) throws IOException {

        String url = getListItemsUrl(listTitle, query);

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPCollection(element.getAsJsonObject());
    }

    public void createListItem(final String listTitle, SPObject data) throws IOException {

        String url = getListItemsUrl(listTitle, null);

        HttpPost request = new HttpPost(url);

        request.setEntity(createJsonEntity(data.toJson()));

        executeVoidRequest(request);
    }

    public void updateListItem(final String listTitle, final int id, final SPETag eTag, SPObject data) throws IOException {

        String url = getListItemUrl(listTitle, id, null);

        HttpMerge request = new HttpMerge(url);

        if (eTag != null) {
            request.addHeader("If-Match", eTag.getValue());
        }

        request.setEntity(createJsonEntity(data.toJson()));

        executeVoidRequest(request);
    }

    public void deleteListItem(final String listTitle, final int id, final SPETag eTag) throws IOException {

        String url = getListItemUrl(listTitle, id, null);

        HttpDelete request = new HttpDelete(url);

        if (eTag != null) {
            request.addHeader("If-Match", eTag.getValue());
        }

        executeVoidRequest(request);
    }
}
