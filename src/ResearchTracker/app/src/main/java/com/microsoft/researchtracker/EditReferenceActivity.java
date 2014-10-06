package com.microsoft.researchtracker;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.microsoft.researchtracker.data.ResearchDataSource;
import com.microsoft.researchtracker.sharepoint.SPETag;
import com.microsoft.researchtracker.sharepoint.SPUrl;
import com.microsoft.researchtracker.sharepoint.models.ResearchReferenceModel;
import com.microsoft.researchtracker.utils.AsyncUtil;
import com.microsoft.researchtracker.utils.AuthUtil;
import com.microsoft.researchtracker.utils.auth.DefaultAuthHandler;

public class EditReferenceActivity extends Activity {

    private static final String TAG = "EditReferenceActivity";
    private static final int NEW_REFERENCE_ID = -1;

    public static final String PARAM_NEW_REFERENCE_MODE = "new_reference_mode";
    public static final String PARAM_PROJECT_ID = "project_id";
    public static final String PARAM_REFERENCE_ID = "reference_id";

    private App mApp;

    private EditText mUrlText;
    private EditText mTitleText;
    private EditText mDescriptionText;
    private ProgressBar mProgress;

    private boolean mLoaded;

    private int mReferenceId;
    private String mReferenceProjectId;
    private SPETag mReferenceETag;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_reference);

        mApp = (App) getApplication();

        mUrlText = (EditText) findViewById(R.id.url_edit_text);
        mUrlText.setEnabled(false);

        mTitleText = (EditText) findViewById(R.id.title_edit_text);
        mTitleText.setEnabled(false);

        mDescriptionText = (EditText) findViewById(R.id.description_edit_text);
        mDescriptionText.setEnabled(false);

        mProgress = (ProgressBar) findViewById(R.id.progress);
        mProgress.setVisibility(View.GONE);

        mLoaded = false;
    }

    @Override
    protected void onStart() {
        super.onStart();

        if (!mLoaded) {
            mLoaded = true;

            Intent launchIntent = getIntent();

            if (launchIntent.getBooleanExtra(PARAM_NEW_REFERENCE_MODE, false)) {

                mReferenceId = NEW_REFERENCE_ID;
                mReferenceProjectId = Integer.toString(launchIntent.getIntExtra(PARAM_PROJECT_ID, -1));
                prepareView(null);
            }
            else {

                mReferenceId = launchIntent.getIntExtra(PARAM_REFERENCE_ID, 0);
                retrieveReferenceDetails();
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.edit_reference, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_accept) {
            saveChangesAndFinish();
            return true;
        }
        if (id == R.id.action_cancel) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void ensureAuthenticated(final Runnable r) {
        AuthUtil.ensureAuthenticated(this, new DefaultAuthHandler(this) {
            public void onSuccess() {
                r.run();
            }
        });
    }

    private void prepareView(ResearchReferenceModel model) {

        SPUrl url = (model == null) ? null : model.getURL();

        mUrlText.setText(url == null ? null : url.getUrl());
        mUrlText.setEnabled(true);

        mTitleText.setText(url == null ? null : url.getDescription());
        mTitleText.setEnabled(true);

        mDescriptionText.setText(model == null ? null : model.getNotes());
        mDescriptionText.setEnabled(true);
    }

    private void retrieveReferenceDetails() {

        ensureAuthenticated(new Runnable() {
            public void run() {

                mProgress.setVisibility(View.VISIBLE);

                AsyncUtil.onBackgroundThread(new AsyncUtil.BackgroundHandler<ResearchReferenceModel>() {
                    public ResearchReferenceModel run() {
                        try {
                            return mApp.getDataSource().getResearchReferenceById(mReferenceId);
                        }
                        catch (Exception e) {
                            Log.e(TAG, "Error retrieving project", e);
                            return null;
                        }
                    }
                })
                .thenOnUiThread(new AsyncUtil.ResultHandler<ResearchReferenceModel>() {
                    public void run(ResearchReferenceModel model) {

                        mProgress.setVisibility(View.GONE);

                        if (model == null) {

                            new AlertDialog.Builder(EditReferenceActivity.this)
                                    .setTitle(R.string.dialog_generic_error_title)
                                    .setMessage(R.string.dialog_generic_error_message)
                                    .setNegativeButton(R.string.label_go_back, null)
                                    .setOnCancelListener(new DialogInterface.OnCancelListener() {
                                        public void onCancel(DialogInterface dialog) {
                                            finish();
                                        }
                                    })
                                    .create()
                                    .show();

                        }
                        else {

                            mReferenceProjectId = model.getProjectId();
                            mReferenceETag = model.getODataETag();

                            prepareView(model);
                        }
                    }
                })
                .execute();
            }
        });

    }

    private void saveChangesAndFinish() {

        ensureAuthenticated(new Runnable() {
            public void run() {

                mProgress.setVisibility(View.VISIBLE);
                mUrlText.setEnabled(false);
                mTitleText.setEnabled(false);
                mDescriptionText.setEnabled(false);

                AsyncUtil.onBackgroundThread(new AsyncUtil.BackgroundHandler<Boolean>() {
                    public Boolean run() {
                        try {
                            final ResearchDataSource data = mApp.getDataSource();
                            final ResearchReferenceModel model = new ResearchReferenceModel();

                            SPUrl url = new SPUrl();

                            url.setUrl(mUrlText.getText().toString());
                            url.setDescription(mTitleText.getText().toString());

                            model.setURL(url);
                            model.setNotes(mDescriptionText.getText().toString());

                            if (mReferenceId == NEW_REFERENCE_ID) {
                                model.setProjectId(mReferenceProjectId);
                                data.createResearchReference(model);
                            }
                            else {
                                data.updateResearchReference(mReferenceId, mReferenceETag, model);
                            }
                            return true;
                        }
                        catch (Exception e) {
                            Log.e(TAG, "Error saving reference changes", e);
                            return false;
                        }
                    }
                })
                .thenOnUiThread(new AsyncUtil.ResultHandler<Boolean>() {
                    public void run(Boolean success) {

                        mProgress.setVisibility(View.GONE);
                        mUrlText.setEnabled(true);
                        mTitleText.setEnabled(true);
                        mDescriptionText.setEnabled(true);

                        if (success) {

                            int resourceId =
                                    (mReferenceId == NEW_REFERENCE_ID)
                                            ? R.string.activity_edit_reference_project_created_message
                                            : R.string.activity_edit_reference_project_updated_message;

                            Toast.makeText(EditReferenceActivity.this, resourceId, Toast.LENGTH_LONG).show();

                            setResult(RESULT_OK);
                            finish();
                        }
                        else {
                            new AlertDialog.Builder(EditReferenceActivity.this)
                                    .setTitle(R.string.dialog_generic_error_title)
                                    .setMessage(R.string.dialog_generic_error_message)
                                    .setNeutralButton(R.string.label_continue, null)
                                    .create()
                                    .show();
                        }
                    }
                })
                .execute();

            }
        });

    }
}
