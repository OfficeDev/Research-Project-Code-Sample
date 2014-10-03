package com.microsoft.researchtracker.http;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.microsoft.researchtracker.sharepoint.OAuthCredentials;

import org.apache.http.Header;
import org.apache.http.HeaderElement;
import org.apache.http.HttpEntity;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpRequestInterceptor;
import org.apache.http.HttpResponse;
import org.apache.http.HttpResponseInterceptor;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHeader;
import org.apache.http.protocol.HttpContext;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;

public class JsonClientBase {

    private static final String TAG = "JsonClientBase";
    private static final String CONTENT_TYPE_JSON = "application/json";
    private static final String ENCODING_TYPE_GZIP = "gzip";

    private final Gson mGson;
    private final HttpClient mClient;

    public JsonClientBase(final OAuthCredentials credentials) {
        mClient = createHttpClient(credentials);
        mGson = createGson();
    }

    private static boolean isSuccessStatusCode(int statusCode) {
        return statusCode >= 200 && statusCode <= 299;
    }

    private HttpClient createHttpClient(final OAuthCredentials credentials) {
        DefaultHttpClient client = new DefaultHttpClient();

        //Adds default request headers
        client.addRequestInterceptor(new HttpRequestInterceptor() {
            @Override
            public void process(HttpRequest httpRequest, HttpContext httpContext) throws HttpException, IOException {
                httpRequest.addHeader(new BasicHeader("Accept", CONTENT_TYPE_JSON));
                httpRequest.addHeader(new BasicHeader("Accept-Encoding", ENCODING_TYPE_GZIP));
                httpRequest.addHeader(new BasicHeader("Authorization", "Bearer " + credentials.getToken()));
            }
        });

        //Adds GZip decompression
        client.addResponseInterceptor(new HttpResponseInterceptor() {
            @Override
            public void process(HttpResponse httpResponse, HttpContext httpContext) throws HttpException, IOException {
                HttpEntity entity = httpResponse.getEntity();
                if (entity == null)
                    return;

                Header encodingHeader = entity.getContentEncoding();
                if (encodingHeader == null)
                    return;

                for (HeaderElement codec : encodingHeader.getElements()) {
                    if (ENCODING_TYPE_GZIP.equalsIgnoreCase(codec.getName())) {
                        httpResponse.setEntity(new GzipDecompressingEntity(entity));
                    }
                }
            }
        });

        return client;
    }

    private Gson createGson() {

        return new GsonBuilder().create();
    }

    private JsonElement parseJsonResponse(final HttpEntity entity) throws IOException {

        Reader reader = null;

        try {

            //Parse the response
            String charSet = EntityUtils.getContentCharSet(entity);

            reader = new InputStreamReader(entity.getContent(), charSet);

            return mGson.fromJson(reader, JsonElement.class);
        }
        finally {
            if (reader != null) {
                reader.close();
            }
        }
    }

    protected void executeVoidRequest(HttpUriRequest request) throws IOException {

        final HttpResponse response = mClient.execute(request);
        final StatusLine statusLine = response.getStatusLine();
        final int statusCode = statusLine.getStatusCode();

        if (!isSuccessStatusCode(statusCode)) {

            final HttpEntity entity = response.getEntity();

            throw new IOException(statusCode + ": " + statusLine.getReasonPhrase() + " " + EntityUtils.toString(entity));
        }
    }

    protected JsonElement executeJsonRequest(HttpUriRequest request) throws IOException {

        final HttpResponse response = mClient.execute(request);
        final StatusLine statusLine = response.getStatusLine();
        final int statusCode = statusLine.getStatusCode();

        final HttpEntity entity = response.getEntity();

        if (isSuccessStatusCode(statusCode)) {
            try {
                //Try parse a success response
                return parseJsonResponse(entity);
            }
            catch (Exception e) {
                Log.wtf(TAG, "Error while handling api request", e);
                throw new IOException(e);
            }
        }

        throw new IOException(statusCode + ": " + statusLine.getReasonPhrase() + " " + EntityUtils.toString(entity));
    }

    protected HttpEntity createJsonEntity(JsonElement data) {

        StringBuilder sb = new StringBuilder();

        mGson.toJson(data, sb);

        try {
            StringEntity entity = new StringEntity(sb.toString(), "utf-8");

            entity.setContentType(CONTENT_TYPE_JSON);

            return entity;
        }
        catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }
}
