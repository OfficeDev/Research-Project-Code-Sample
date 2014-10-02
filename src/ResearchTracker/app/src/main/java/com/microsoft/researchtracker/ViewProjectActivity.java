package com.microsoft.researchtracker;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.BaseAdapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.microsoft.researchtracker.sharepoint.ListsClient;
import com.microsoft.researchtracker.sharepoint.SPODataCollection;
import com.microsoft.researchtracker.sharepoint.SPODataObject;
import com.microsoft.researchtracker.sharepoint.models.ResearchProjectModel;
import com.microsoft.researchtracker.sharepoint.models.ResearchReferenceModel;
import com.microsoft.researchtracker.sharepoint.odata.Query;
import com.microsoft.researchtracker.sharepoint.odata.QueryOperations;
import com.microsoft.researchtracker.utils.AsyncUtil;
import com.microsoft.researchtracker.utils.AuthUtil;
import com.microsoft.researchtracker.utils.ViewUtil;
import com.microsoft.researchtracker.utils.auth.DefaultAuthHandler;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ViewProjectActivity extends Activity {

    private static final String TAG = "ViewProjectActivity";

    public static final String PARAM_PROJECT_ID = "project_id";

    private App mApp;

    private TextView mTitleLabel;
    private ListView mListView;
    private ProgressBar mProgress;

    private ListAdapter mAdapter;

    private int mProjectId;

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

        startRefresh();
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
        if (id == R.id.action_refresh) {
            handleActionRefresh(item);
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

                            final ListsClient client = mApp.getListsClient();

                            final SPODataObject projectData = client.getListItemById(Constants.RESEARCH_PROJECTS_LIST, mProjectId);
                            final ResearchProjectModel project = new ResearchProjectModel(projectData);

                            final Query query = QueryOperations.field("Project").eq().val(mProjectId);
                            final SPODataCollection result = client.getListItems(Constants.RESEARCH_REFERENCES_LIST, query);

                            final List<ResearchReferenceModel> items = new ArrayList<ResearchReferenceModel>();

                            if (result != null) {
                                for (final SPODataObject listItemData : result.getValue()) {
                                    items.add(new ResearchReferenceModel(listItemData));
                                }
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

                        mTitleLabel.setText(result.project.getTitle());
                        mAdapter = new ReferencesListAdapter(result.references);
                        mListView.setAdapter(mAdapter);
                    }
                })
                .execute();
            }
        });
    }

    private void handleActionRefresh(MenuItem item) {
        startRefresh();
    }

    private void handleActionEdit(MenuItem item) {

        //TODO
    }

    private void handleActionNew(MenuItem item) {

        //TODO
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
