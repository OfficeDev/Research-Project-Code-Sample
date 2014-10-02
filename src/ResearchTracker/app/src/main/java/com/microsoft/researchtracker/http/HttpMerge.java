package com.microsoft.researchtracker.http;

//import org.apache.http.annotation.NotThreadSafe;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;

import java.net.URI;

/**
 * Class identifying MERGE HTTP method.
 */
//@NotThreadSafe
public class HttpMerge extends HttpEntityEnclosingRequestBase {

    public final static String METHOD_NAME = "MERGE";

    /**
     * Constructor.
     */
    public HttpMerge() {
        super();
    }

    /**
     * Constructor.
     *
     * @param uri request URI.
     */
    public HttpMerge(final URI uri) {
        super();
        setURI(uri);
    }

    /**
     * Constructor.
     *
     * @param uri request URI.
     * @throws IllegalArgumentException if the uri is invalid.
     */
    public HttpMerge(final String uri) {
        super();
        setURI(URI.create(uri));
    }

    /**
     * Gets HTTP method name.
     *
     * @return HTTP method name.
     */
    @Override
    public String getMethod() {
        return METHOD_NAME;
    }
}

