package com.microsoft.researchtracker;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.microsoft.researchtracker.data.ResearchDataSource;
import com.microsoft.researchtracker.sharepoint.SPETag;
import com.microsoft.researchtracker.sharepoint.models.ResearchProjectModel;
import com.microsoft.researchtracker.sharepoint.models.ResearchReferenceModel;
import com.microsoft.researchtracker.utils.AsyncUtil;
import com.microsoft.researchtracker.utils.AuthUtil;
import com.microsoft.researchtracker.utils.ViewUtil;
import com.microsoft.researchtracker.utils.auth.DefaultAuthHandler;

import java.util.Collections;
import java.util.List;

public class ViewProjectActivity extends Activity {

    private static final String TAG = "ViewProjectActivity";

    private static final int REQUEST_EDIT_PROJECT = 1;

    public static final String PARAM_PROJECT_ID = "project_id";

    private App mApp;

    private TextView mTitleLabel;
    private ListView mListView;
    private ProgressBar mProgress;

    private ListAdapter mAdapter;

    private int mProjectId;
    private SPETag mProjectETag;

    private boolean mLoaded;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_project);

        mApp = (App) getApplication();

        mTitleLabel = (TextView) findViewById(R.id.title_label);
        mTitleLabel.setText("");

        mListView = (ListView) findViewById(R.id.list_view);
        mProgress = (ProgressBar) findViewById(R.id.progress);

        mProjectId = getIntent().getIntExtra(PARAM_PROJECT_ID, 0);

        mLoaded = false;
    }

    @Override
    protected void onStart() {
        super.onStart();

        if (!mLoaded) {
            mLoaded = true;
            startRefresh();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.view_project, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_edit) {
            handleActionEdit(item);
            return true;
        }
        if (id == R.id.action_new) {
            handleActionNew(item);
            return true;
        }
        if (id == R.id.action_delete) {
            launchConfirmDeleteDialog();
            return true;
        }
        if (id == R.id.action_refresh) {
            startRefresh();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_EDIT_PROJECT && resultCode == RESULT_OK) {
            startRefresh();
        }
    }

    private void ensureAuthenticated(final Runnable r) {
        AuthUtil.ensureAuthenticated(this, new DefaultAuthHandler(this) {
            @Override public void onSuccess() {
                r.run();
            }
        });
    }

    private void startRefresh() {
        ensureAuthenticated(new Runnable() {

            //A temporary class for use within this refresh function
            class ViewModel {

                public final ResearchProjectModel project;
                public final List<ResearchReferenceModel> references;

                public ViewModel(ResearchProjectModel project, List<ResearchReferenceModel> references) {

                    this.project = project;
                    this.references = references;
                }
            }

            public void run() {
                mListView.setEnabled(false);
                mProgress.setVisibility(View.VISIBLE);

                AsyncUtil.onBackgroundThread(new AsyncUtil.BackgroundHandler<ViewModel>() {
                    public ViewModel run() {
                        try {
                            ResearchDataSource repository = mApp.getDataSource();

                            ResearchProjectModel project = repository.getResearchProjectById(mProjectId);

                            if (project == null) {
                                return null;
                            }

                            List<ResearchReferenceModel> items = repository.getResearchReferencesByProjectId(mProjectId);

                            if (items == null) {
                                items = Collections.emptyList();
                            }

                            return new ViewModel(project, items);
                        }
                        catch (Exception e) {
                            Log.e(TAG, "Error retrieving projects", e);

                            return null;
                        }
                    }
                })
                .thenOnUiThread(new AsyncUtil.ResultHandler<ViewModel>() {

                    public void run(ViewModel result) {
                        setProgressBarVisibility(false);
                        mProgress.setVisibility(View.GONE);

                        if (result == null) {
                            Toast.makeText(ViewProjectActivity.this, R.string.activity_view_project_error_loading_projects, Toast.LENGTH_LONG).show();
                            finish();
                            return;
                        }

                        mProjectETag = result.project.getODataEtag();

                        mTitleLabel.setText(result.project.getTitle());
                        mAdapter = new ReferencesListAdapter(result.references);
                        mListView.setAdapter(mAdapter);
                    }
                })
                .execute();
            }
        });
    }

    private void handleActionEdit(MenuItem item) {

        //Launch the "Edit Project" activity
        final Intent intent = new Intent(this, EditProjectActivity.class);
        intent.putExtra(EditProjectActivity.PARAM_PROJECT_ID, mProjectId);

        startActivityForResult(intent, REQUEST_EDIT_PROJECT);
    }

    private void handleActionNew(MenuItem item) {

        //TODO
    }

    private void launchConfirmDeleteDialog() {

        new AlertDialog.Builder(this)
                .setTitle(R.string.dialog_confirm_delete_project_title)
                .setMessage(R.string.dialog_confirm_delete_project_message)
                .setNegativeButton(R.string.label_cancel, null)
                .setPositiveButton(R.string.label_delete, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        deleteProjectAndFinish();
                    }
                })
                .create()
                .show();

    }

    private void deleteProjectAndFinish() {

        ensureAuthenticated(new Runnable() {
            public void run() {

                mProgress.setVisibility(View.VISIBLE);

                AsyncUtil.onBackgroundThread(new AsyncUtil.BackgroundHandler<Boolean>() {
                    public Boolean run() {
                        try {

                            mApp.getDataSource().deleteResearchProject(mProjectId, mProjectETag);

                            return true;
                        }
                        catch (Exception e) {
                            Log.e(TAG, "Error deleting project", e);
                            return false;
                        }
                    }
                })
                .thenOnUiThread(new AsyncUtil.ResultHandler<Boolean>() {
                    public void run(Boolean success) {

                        mProgress.setVisibility(View.GONE);

                        if (success) {

                            Toast.makeText(ViewProjectActivity.this, R.string.activity_edit_project_project_deleted_message, Toast.LENGTH_LONG).show();
                            finish();
                        }
                        else {
                            new AlertDialog.Builder(ViewProjectActivity.this)
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

    private class ReferencesListAdapter extends BaseAdapter {

        private LayoutInflater mViewInflater;

        private List<ResearchReferenceModel> mItems;

        public ReferencesListAdapter(List<ResearchReferenceModel> result) {
            mViewInflater = getLayoutInflater();
            mItems = result;
        }

        @Override
        public int getCount() {
            return mItems.size();
        }

        @Override
        public Object getItem(int position) {
            return mItems.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            View view = ViewUtil.prepareView(mViewInflater, android.R.layout.simple_list_item_2, convertView, null);

            TextView text1 = (TextView) ViewUtil.findChildView(view, android.R.id.text1);
            TextView text2 = (TextView) ViewUtil.findChildView(view, android.R.id.text2);

            ResearchReferenceModel item = mItems.get(position);

            text1.setText(item.getURL().getDescription());
            text2.setText(item.getNotes());

            return view;
        }
    }

}
