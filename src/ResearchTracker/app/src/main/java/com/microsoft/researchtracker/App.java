package com.microsoft.researchtracker;

import android.app.Application;
import android.util.Log;

import com.microsoft.office365.api.MailClient;
import com.microsoft.office365.oauth.OAuthCredentials;
import com.microsoft.researchtracker.auth.AuthManager;

public class App extends Application {

    private static final String TAG = "TodoApplication";

    private AuthManager mAuthManager;

    public AuthManager getAuthManager() {

        if (mAuthManager == null) {
            try {
                mAuthManager = new AuthManager(this);
            }
            catch (Exception e) {
                Log.e(TAG, "Error creating authentication context", e);
                throw new RuntimeException("Error creating authentication context", e);
            }
        }

        return mAuthManager;
    }

    public MailClient getMailClient() {

        OAuthCredentials credentials = getAuthManager().getOAuthCredentials();

        return new MailClient.Builder()
                .setCredentials(credentials)
                .setResourceId(Constants.EXCHANGE_RESOURCE_ID)
                .setODataEndpoint(Constants.EXCHANGE_ODATA_ENDPOINT)
                .setMaxDefaultResults(Constants.EXCHANGE_DEFAULT_MAX_RESULTS)
                .build();
    }
}
