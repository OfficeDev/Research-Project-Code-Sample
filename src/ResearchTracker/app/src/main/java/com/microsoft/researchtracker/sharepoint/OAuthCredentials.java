package com.microsoft.researchtracker.sharepoint;

public class OAuthCredentials {

    private String mToken;

    public OAuthCredentials(String oAuthToken) {
        mToken = oAuthToken;
    }

    /**
     * Returns the OAuth Token
     */
    public String getToken() {
        return mToken;
    }

}