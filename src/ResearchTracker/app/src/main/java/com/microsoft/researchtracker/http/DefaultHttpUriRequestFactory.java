package com.microsoft.researchtracker.http;

import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.methods.HttpUriRequest;

import java.net.URI;

/**
 * Default implementation returning default HttpUriRequest implementations.
 */
public class DefaultHttpUriRequestFactory implements HttpUriRequestFactory {

    @Override
    public HttpUriRequest create(final HttpMethod method, final URI uri) {
        HttpUriRequest result;

        switch (method) {
            case POST:
                result = new HttpPost(uri);
                break;

            case PUT:
                result = new HttpPut(uri);
                break;

            case PATCH:
                result = new HttpPatch(uri);
                break;

            case MERGE:
                result = new HttpMerge(uri);
                break;

            case DELETE:
                result = new HttpDelete(uri);
                break;

            case GET:
            default:
                result = new HttpGet(uri);
                break;
        }

        return result;
    }
}