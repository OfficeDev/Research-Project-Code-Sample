package com.microsoft.researchtracker.sharepoint;

import android.text.TextUtils;

import com.google.gson.JsonElement;
import com.microsoft.researchtracker.http.JsonClientBase;
import com.microsoft.researchtracker.sharepoint.odata.Query;
import com.microsoft.researchtracker.sharepoint.odata.QueryOperations;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;

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

    private String getListApiUrl(String listTitle) {

        final String listTitleToken = UrlUtil.encodeComponent(QueryOperations.val(listTitle).toString());

        return String.format("%s/%s/_api/Lists/getByTitle(%s)", mSharePointUrl, mSitePath, listTitleToken);
    }

    public SPODataObject getList(final String listTitle) throws IOException {

        String url = getListApiUrl(listTitle);

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPODataObject(element.getAsJsonObject());
    }

    public SPODataCollection getListItems(final String listTitle, final Query query) throws IOException {

        String url = getListApiUrl(listTitle) + "/items";

        if (query != null) {
            url += "?$filter=" + UrlUtil.encodeComponent(query.toString());
        }

        JsonElement element = executeJsonRequest(new HttpGet(url));

        if (element == null || !element.isJsonObject())
            return null;

        return new SPODataCollection(element.getAsJsonObject());
    }
}
