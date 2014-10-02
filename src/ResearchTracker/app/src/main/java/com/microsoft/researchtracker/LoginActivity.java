package com.microsoft.researchtracker;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.Toast;

import com.microsoft.researchtracker.auth.AuthCallback;
import com.microsoft.researchtracker.auth.AuthManager;

public class LoginActivity extends Activity {

    public static final String PARAM_AUTH_IMMEDIATE = "auth_immediate";

    private App mApp;
    private AuthManager mAuth;

    private Button mloginButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setProgressBarIndeterminate(true);

        setContentView(R.layout.activity_login);

        mApp = (App) getApplication();
        mAuth = mApp.getAuthManager();

        mloginButton = (Button) findViewById(R.id.loginButton);
        mloginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startAuthentication();
            }
        });

        resetView();

        if (getIntent().getBooleanExtra(PARAM_AUTH_IMMEDIATE, false))
        {
            startAuthentication();
        }
    }

    private void resetView() {

        // Reset view
        mloginButton.setEnabled(true);
    }

    /**
     * Starts authentication with the O365 backend.
     */
    private void startAuthentication() {

        mloginButton.setEnabled(false);

        //Start authentication procedure
        mAuth.forceAuthenticate(this, new AuthCallback() {

            @Override
            public void onSuccess() {
                completeLogin();
            }

            @Override
            public void onFailure(String errorDescription) {
                Toast.makeText(LoginActivity.this, errorDescription, Toast.LENGTH_LONG).show();
                launchRetryDialog(errorDescription);
            }

            @Override
            public void onCancelled() {
                resetView();
            }

            private void launchRetryDialog(String errorDescription) {
                new AlertDialog.Builder(LoginActivity.this)
                        .setTitle(R.string.dialog_auth_failed_title)
                        .setMessage(errorDescription)
                        .setPositiveButton(R.string.label_retry, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                resetView();
                                startAuthentication();
                            }
                        })
                        .setNegativeButton(R.string.label_cancel, null)
                        .create()
                        .show();
            }
        });

    }

    private void completeLogin() {

        Toast.makeText(this, R.string.activity_login_sign_in_complete, Toast.LENGTH_SHORT).show();

        //navigate to next activity

        final Intent intent = new Intent(this, ListProjectsActivity.class);

        startActivity(intent);
        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        //Handle authentication completion
        mAuth.onActivityResult(requestCode, resultCode, data);
    }

}
