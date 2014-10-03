package com.microsoft.researchtracker;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.microsoft.researchtracker.sharepoint.SPCollection;
import com.microsoft.researchtracker.sharepoint.ListsClient;
import com.microsoft.researchtracker.sharepoint.SPObject;
import com.microsoft.researchtracker.sharepoint.models.ResearchProjectModel;
import com.microsoft.researchtracker.utils.AsyncUtil;
import com.microsoft.researchtracker.utils.AuthUtil;
import com.microsoft.researchtracker.utils.auth.DefaultAuthHandler;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ListProjectsActivity extends Activity {

    private static final String TAG = "ListProjectsActivity";

    private App mApp;

    private ListView mListView;
    private ProgressBar mProgress;

    private ProjectsListAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_list_projects);

        mApp = (App) getApplication();

        mListView = (ListView) findViewById(R.id.list_view);
        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                ResearchProjectModel project = (ResearchProjectModel) mAdapter.getItem(position);

                //Launch the "View Project" activity
                final Intent intent = new Intent(ListProjectsActivity.this, ViewProjectActivity.class);
                intent.putExtra(ViewProjectActivity.PARAM_PROJECT_ID, project.getId());

                startActivity(intent);
            }
        });

        mProgress = (ProgressBar) findViewById(R.id.progress);
    }

    @Override
    protected void onStart() {
        super.onStart();

        startRefresh();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.list_projects, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_new) {
            handleActionNew();
            return true;
        }
        if (id == R.id.action_refresh) {
            startRefresh();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void handleActionNew() {

        //Launch the "Edit Project" activity in "new" mode
        final Intent intent = new Intent(this, EditProjectActivity.class);
        intent.putExtra(EditProjectActivity.PARAM_NEW_PROJECT_MODE, true);

        startActivity(intent);
    }

    private void startRefresh() {
        ensureAuthenticated(new Runnable() {
            public void run() {
                mListView.setEnabled(false);
                mProgress.setVisibility(View.VISIBLE);

                AsyncUtil.onBackgroundThread(new AsyncUtil.BackgroundHandler<List<ResearchProjectModel>>() {
                    public List<ResearchProjectModel> run() {
                        try {

                            final ListsClient client = mApp.getListsClient();

                            final SPCollection result = client.getListItems(Constants.RESEARCH_PROJECTS_LIST, null);

                            final List<ResearchProjectModel> items = new ArrayList<ResearchProjectModel>();

                            if (result != null) {
                                for (final SPObject listItemData : result.getValue()) {
                                    items.add(new ResearchProjectModel(listItemData));
                                }
                            }

                            return items;
                        }
                        catch (Exception e) {
                            Log.e(TAG, "Error retrieving projects", e);

                            return null;
                        }
                    }
                })
                .thenOnUiThread(new AsyncUtil.ResultHandler<List<ResearchProjectModel>>() {

                    public void run(List<ResearchProjectModel> result) {
                        mListView.setEnabled(true);
                        mProgress.setVisibility(View.GONE);

                        if (result == null) {
                            result = Collections.emptyList();
                            Toast.makeText(ListProjectsActivity.this, R.string.activity_list_projects_error_loading_projects, Toast.LENGTH_LONG).show();
                        }

                        mAdapter = new ProjectsListAdapter(result);
                        mListView.setAdapter(mAdapter);
                    }
                })
                .execute();
            }
        });
    }

    private void ensureAuthenticated(final Runnable r) {
        AuthUtil.ensureAuthenticated(this, new DefaultAuthHandler(this) {
            @Override public void onSuccess() {
                r.run();
            }
        });
    }

    private class ProjectsListAdapter extends BaseAdapter {

        private final List<ResearchProjectModel> mItems;
        private final LayoutInflater mViewInflater;

        public ProjectsListAdapter(List<ResearchProjectModel> folderList) {

            mItems = folderList;
            mViewInflater = getLayoutInflater();
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

            TextView v = (TextView) (convertView != null ? convertView : mViewInflater.inflate(android.R.layout.simple_list_item_1, null));

            ResearchProjectModel item = mItems.get(position);

            v.setText(item.getTitle());

            return v;
        }
    }
}
