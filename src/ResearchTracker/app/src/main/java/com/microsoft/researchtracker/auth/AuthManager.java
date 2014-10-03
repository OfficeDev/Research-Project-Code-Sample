package com.microsoft.researchtracker.auth;

import java.security.NoSuchAlgorithmException;
import java.util.Date;

import javax.crypto.NoSuchPaddingException;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Log;

import com.microsoft.aad.adal.AuthenticationCallback;
import com.microsoft.aad.adal.AuthenticationCancelError;
import com.microsoft.aad.adal.AuthenticationContext;
import com.microsoft.aad.adal.AuthenticationResult;
import com.microsoft.aad.adal.AuthenticationResult.AuthenticationStatus;
import com.microsoft.aad.adal.PromptBehavior;
import com.microsoft.researchtracker.Constants;
import com.microsoft.researchtracker.R;
import com.microsoft.researchtracker.App;
import com.microsoft.researchtracker.sharepoint.OAuthCredentials;

public class AuthManager {

    private static final String TAG = "AuthManager";
    private static final String PREFS_HAS_CACHED_CREDENTIALS = "has_cached_creds";

    private App mApplication;
    private AuthenticationContext mAuthContext;
    private SharedPreferences mSharedPreferences;

    private AuthToken mCachedAuthToken;
    private boolean mAuthInProgress;


    public AuthManager(App application) throws NoSuchAlgorithmException, NoSuchPaddingException {
        mApplication = application;
        mAuthContext = new AuthenticationContext(application, Constants.AAD_AUTHORITY, false);
        mSharedPreferences = application.getSharedPreferences("authmanager_prefs", Context.MODE_PRIVATE);
    }

    private AuthToken getAuthToken() {
        if (mCachedAuthToken == null) {
            mCachedAuthToken = new AuthToken();
            mCachedAuthToken.readFrom(mSharedPreferences);
        }
        return mCachedAuthToken;
    }

    public OAuthCredentials getOAuthCredentials() {
        AuthToken authToken = getAuthToken();
        if (!authToken.isValid()) {
            //Must call authenticate, forceAuthenticate or refresh before invoking this method
            throw new RuntimeException("Auth token is not valid");
        }

        return new OAuthCredentials(authToken.getAccessToken());
    }

    private void updateAuthToken(AuthToken token) {
        assert token != null;
        mCachedAuthToken = token;
        mCachedAuthToken.writeTo(mSharedPreferences);
        mSharedPreferences
                .edit()
                .putBoolean(PREFS_HAS_CACHED_CREDENTIALS, mCachedAuthToken.isValid())
                .apply();
    }

    public boolean getAuthenticationInProgress() {
        return mAuthInProgress;
    }

    public boolean hasCachedCredentials() {
        return mSharedPreferences.getBoolean(PREFS_HAS_CACHED_CREDENTIALS, false);
    }

    public void clearAuthTokenAndCachedCredentials() {
        mAuthContext.getCache().removeAll();
        updateAuthToken(new AuthToken());
    }

    /**
     * Attempts to retrieve a new auth token.
     *
     * Note: must be called from the UI thread.
     *
     * @param currentActivity
     * @param handler
     */
    public void forceAuthenticate(final Activity currentActivity, final AuthCallback handler) {

        assert currentActivity != null;
        assert handler != null;

        mAuthInProgress = true;

        //No refresh tokens - ask the user to authenticate directly
        mAuthContext.acquireToken(currentActivity,
            /* Resource         */ Constants.AAD_RESOURCE_ID,
            /* Client Id        */ Constants.AAD_CLIENT_ID,
            /* Redirect Uri     */ Constants.AAD_REDIRECT_URL,
            /* Login Hint       */ Constants.AAD_LOGIN_HINT,
            /* Prompt Behaviour */ PromptBehavior.Auto,
            /* Extra            */ null,
                createAuthCallback(handler)
        );
    }

    /**
     * Attempts to retrieve a new auth token. If there is already an unexpired auth token then no action
     * is taken. If the token has expired then this method attempts to refresh it using the refresh token.
     *
     * Note: must be called from the UI thread.
     *
     * @param currentActivity
     * @param handler
     */
    public void authenticate(final Activity currentActivity, final AuthCallback handler) {

        assert currentActivity != null;
        assert handler != null;

        final AuthToken token = getAuthToken();

        if (token.isValid()) {
            //Already authenticated...
            handler.onSuccess();
            return;
        }

        mAuthInProgress = true;

        //Try and refresh using a refresh token
        final String refreshToken = token.getRefreshToken();

        //Do we have a refresh token?
        if (!TextUtils.isEmpty(refreshToken)) {
            mAuthContext.acquireTokenByRefreshToken(
                /* Refresh token */ refreshToken,
                /* Client Id     */ Constants.AAD_CLIENT_ID,
                    createAuthCallback(handler)
            );
        }

        forceAuthenticate(currentActivity, handler);
    }

    /**
     * Attempts to refresh the cached auth token if it has expired.
     *
     * @param handler
     */
    public void refresh(final AuthCallback handler) {

        assert handler != null;

        final AuthToken token = getAuthToken();
        String refreshToken = token.getRefreshToken();

        if (refreshToken == null) {
            handler.onFailure(mApplication.getString(R.string.auth_manager_error_no_refresh_token));
            return;
        }

        if (token.isValid()) {
            //Already authenticated...
            handler.onSuccess();
            return;
        }

        mAuthInProgress = true;

        AuthenticationCallback<AuthenticationResult> callback = createAuthCallback(handler);

        mAuthContext.acquireTokenByRefreshToken(
            /* Refresh token */ refreshToken,
            /* Client Id     */ Constants.AAD_CLIENT_ID,
                callback
        );
    }

    private AuthenticationCallback<AuthenticationResult> createAuthCallback(final AuthCallback handler) {
        return new AuthenticationCallback<AuthenticationResult>() {
            @Override
            public void onSuccess(AuthenticationResult authResult) {
                mAuthInProgress = false;
                final AuthenticationStatus status = authResult.getStatus();
                if (status == AuthenticationStatus.Succeeded) {
                    // create a credentials instance using the token from ADAL
                    updateAuthToken(new AuthToken(authResult));
                    handler.onSuccess();
                }
                else if (status == AuthenticationStatus.Failed) {
                    Log.e(TAG, "Authentication failed: " + authResult.getErrorDescription());
                    handler.onFailure(authResult.getErrorDescription());
                }
                else {
                    Log.i(TAG, "Authentication cancelled");
                    handler.onCancelled();
                }
            }

            @Override
            public void onError(Exception ex) {
                mAuthInProgress = false;
                if (ex instanceof AuthenticationCancelError) {
                    Log.i(TAG, "Authentication cancelled");
                    handler.onCancelled();
                }
                else {
                    Log.e(TAG, "Error during authentication", ex);
                    handler.onFailure(ex.getMessage());
                }
            }
        };
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        mAuthContext.onActivityResult(requestCode, resultCode, data);
    }

    private class AuthToken {

        private static final String PREFS_REFRESH_TOKEN = "refreshToken";
        private static final String PREFS_ACCESS_TOKEN = "accessToken";
        private static final String PREFS_EXPIRES_ON = "expiresOn";

        private String mAccessToken;
        private Date mExpiresOn;

        private String mRefreshToken;

        public AuthToken() {

        }

        public AuthToken(AuthenticationResult source) {
            mAccessToken = source.getAccessToken();
            mRefreshToken = source.getRefreshToken();
            mExpiresOn = source.getExpiresOn();
        }

        public String getAccessToken() {
            return mAccessToken;
        }

        public String getRefreshToken() {
            return mRefreshToken;
        }

        public boolean isValid() {
            return mExpiresOn != null && mExpiresOn.after(new Date());
        }

        //TODO: currently we're storing the refresh token in SharedPreferences in plaintext.
        //Ideally this would be updated to use the android AccountManager API or some other
        //encrypted storage mechanism

        public void readFrom(SharedPreferences prefs) {
            mRefreshToken = prefs.getString(PREFS_REFRESH_TOKEN, null);
            mAccessToken = prefs.getString(PREFS_ACCESS_TOKEN , null);
            long ms = prefs.getLong(PREFS_EXPIRES_ON, 0);
            if (ms > 0) {
                mExpiresOn = new Date(ms);
            }
        }

        public void writeTo(SharedPreferences prefs) {
            prefs
                .edit()
                .putString(PREFS_REFRESH_TOKEN, mRefreshToken)
                .putString(PREFS_ACCESS_TOKEN, mAccessToken)
                .putLong(PREFS_EXPIRES_ON, mExpiresOn == null ? 0 : mExpiresOn.getTime())
                .apply();
        }
    }

    /**
     * This method is provided to artifically expiring the authentication token
     * in order to test app behaviour in that situation.
     */
    public void forceExpireToken() {
        updateAuthToken(new AuthToken());
    }
}

