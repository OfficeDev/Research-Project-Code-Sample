package com.microsoft.researchtracker.http;

import org.apache.http.client.methods.HttpUriRequest;

import java.net.URI;

public interface HttpUriRequestFactory {

    public HttpUriRequest create(final HttpMethod method, final URI uri);

}
