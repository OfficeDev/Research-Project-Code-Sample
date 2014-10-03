package com.microsoft.researchtracker;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.microsoft.researchtracker.sharepoint.ListsClient;
import com.microsoft.researchtracker.sharepoint.SPETag;
import com.microsoft.researchtracker.sharepoint.SPObject;
import com.microsoft.researchtracker.sharepoint.models.ResearchProjectModel;
import com.microsoft.researchtracker.utils.AsyncUtil;
import com.microsoft.researchtracker.utils.AuthUtil;
import com.microsoft.researchtracker.utils.auth.DefaultAuthHandler;

public class EditProjectActivity extends Activity {

    private static final String TAG = "EditProjectActivity";
    private static final int NEW_PROJECT_ID = -1;

    public static final String PARAM_NEW_PROJECT_MODE = "new_project_mode";
    public static final String PARAM_PROJECT_ID = "project_id";

    private App mApp;

    private EditText mTitleText;
    private ProgressBar mProgress;

    private int mProjectId;
    private SPETag mProjectETag;

    private int mRequestId;
    private boolean mLoaded;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_project);

        mApp = (App) getApplication();

        mTitleText = (EditText) findViewById(R.id.title_edit_text);
        mTitleText.setEnabled(false);

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

            if (launchIntent.getBooleanExtra(PARAM_NEW_PROJECT_MODE, false)) {

                mProjectId = NEW_PROJECT_ID;
                prepareView(null);
            }
            else {

                mProjectId = launchIntent.getIntExtra(PARAM_PROJECT_ID, 0);
                retrieveProjectDetails();
            }
        }
    }

    private void prepareView(ResearchProjectModel model) {

        mTitleText.setText(model == null ? null : model.getTitle());
        mTitleText.setEnabled(true);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.edit_project, menu);
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
            @Override public void onSuccess() {
                r.run();
            }
        });
    }

    private void retrieveProjectDetails() {

        ensureAuthenticated(new Runnable() {
            public void run() {

                mProgress.setVisibility(View.VISIBLE);

                AsyncUtil.onBackgroundThread(new AsyncUtil.BackgroundHandler<ResearchProjectModel>() {
                    public ResearchProjectModel run() {
                        try {
                            final ListsClient client = mApp.getListsClient();
                            final SPObject projectData = client.getListItemById(Constants.RESEARCH_PROJECTS_LIST, mProjectId);

                            return new ResearchProjectModel(projectData);
                        }
                        catch (Exception e) {
                            Log.e(TAG, "Error retrieving project", e);
                            return null;
                        }
                    }
                })
                .thenOnUiThread(new AsyncUtil.ResultHandler<ResearchProjectModel>() {
                    public void run(ResearchProjectModel model) {

                        mProgress.setVisibility(View.GONE);
                        mProjectETag = model.getODataEtag();

                        prepareView(model);
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
                mTitleText.setEnabled(false);

                AsyncUtil.onBackgroundThread(new AsyncUtil.BackgroundHandler<Boolean>() {
                    public Boolean run() {
                        try {

                            final ListsClient client = mApp.getListsClient();
                            final ResearchProjectModel model = new ResearchProjectModel();

                            model.setTitle(mTitleText.getText().toString());

                            if (mProjectId == NEW_PROJECT_ID) {
                                client.createListItem(Constants.RESEARCH_PROJECTS_LIST, model.getInternalData());
                            }
                            else {
                                client.updateListItem(Constants.RESEARCH_PROJECTS_LIST, mProjectId, mProjectETag, model.getInternalData());
                            }
                            return true;
                        }
                        catch (Exception e) {
                            Log.e(TAG, "Error saving project changes", e);
                            return false;
                        }
                    }
                })
                .thenOnUiThread(new AsyncUtil.ResultHandler<Boolean>() {
                    public void run(Boolean success) {

                        mProgress.setVisibility(View.GONE);
                        mTitleText.setEnabled(true);

                        if (success) {

                            int resourceId =
                                    (mProjectId == NEW_PROJECT_ID)
                                            ? R.string.activity_edit_project_project_created_message
                                            : R.string.activity_edit_project_project_updated_message;

                            Toast.makeText(EditProjectActivity.this, resourceId, Toast.LENGTH_LONG).show();

                            setResult(RESULT_OK);
                            finish();
                        }
                        else {
                            new AlertDialog.Builder(EditProjectActivity.this)
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
