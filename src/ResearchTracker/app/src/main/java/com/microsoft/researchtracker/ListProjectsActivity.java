package com.microsoft.researchtracker;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.microsoft.researchtracker.sharepoint.SPODataCollection;
import com.microsoft.researchtracker.sharepoint.ListsClient;
import com.microsoft.researchtracker.sharepoint.SPODataObject;
import com.microsoft.researchtracker.sharepoint.models.ResearchProjectModel;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ListProjectsActivity extends Activity {

    private static final String TAG = "ListProjectsActivity";

    private App mApp;

    private ListView mListView;
    private ProjectsListAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_projects);

        mApp = (App) getApplication();

        setProgressBarIndeterminate(true);

        mListView = (ListView) findViewById(R.id.listView);

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
        if (id == R.id.action_add_new) {
            handleActionAddNew(item);
            return true;
        }
        if (id == R.id.action_refresh) {
            handleActionRefresh(item);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void handleActionRefresh(MenuItem item) {
        startRefresh();
    }

    private void handleActionAddNew(MenuItem item) {

        //TODO
        Toast.makeText(this, "Add new Project", Toast.LENGTH_SHORT).show();
    }

    private void startRefresh() {

        new AsyncTask<Void, Void, List<ResearchProjectModel>>() {

            @Override
            protected void onPreExecute() {
                super.onPreExecute();
                setProgressBarVisibility(true);
                mListView.setEnabled(false);
            }

            @Override
            protected List<ResearchProjectModel> doInBackground(Void... params) {

                try {

                    ListsClient client = mApp.getListsClient();

                    SPODataCollection result = client.getListItems(Constants.RESEARCH_PROJECTS_LIST, null);

                    final List<ResearchProjectModel> items = new ArrayList<ResearchProjectModel>();

                    if (result != null) {
                        for (SPODataObject listItemData : result.getValue()) {
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

            @Override
            protected void onPostExecute(List<ResearchProjectModel> folderList) {
                super.onPostExecute(folderList);
                setProgressBarVisibility(false);
                mListView.setEnabled(true);

                if (folderList == null) {

                    folderList = Collections.emptyList();
                    Toast.makeText(ListProjectsActivity.this, R.string.activity_list_projects_error_loading_projects, Toast.LENGTH_LONG).show();
                }

                mAdapter = new ProjectsListAdapter(folderList);
                mListView.setAdapter(mAdapter);
            }
        }
        .execute();
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
