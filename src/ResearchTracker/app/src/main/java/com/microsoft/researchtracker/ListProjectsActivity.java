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

import com.microsoft.office365.api.MailClient;
import com.microsoft.office365.microsoft.exchange.services.odata.model.types.Folder;
import com.microsoft.office365.microsoft.exchange.services.odata.model.types.FolderCollection;

import java.util.ArrayList;
import java.util.List;

public class ListProjectsActivity extends Activity {

    private static final String TAG = "ListProjectsActivity";

    private App mApp;

    private ListView mListView;

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

        new AsyncTask<Void, Void, List<Folder>>() {

            @Override
            protected void onPreExecute() {
                super.onPreExecute();
                ListProjectsActivity.this.setProgressBarVisibility(true);
            }

            @Override
            protected List<Folder> doInBackground(Void... params) {

                final List<Folder> folders = new ArrayList<Folder>();

                try {

                    MailClient mailClient = mApp.getMailClient();
                    FolderCollection auxFolders = mailClient.getChildFolders();

                    for (Folder folder : auxFolders.execute()) {
                        folders.add(folder);
                    }

                } catch (Exception e) {
                    Log.e(TAG, "Error retrieving folders", e);
                }

                return folders;
            }

            @Override
            protected void onPostExecute(List<Folder> folderList) {
                super.onPostExecute(folderList);

                FolderListAdapter adapter = new FolderListAdapter(folderList);
                mListView.setAdapter(adapter);

                ListProjectsActivity.this.setProgressBarVisibility(false);
            }
        }
        .execute();
    }

    private class FolderListAdapter extends BaseAdapter {

        private final List<Folder> mFolders;
        private final LayoutInflater mViewInflater;

        public FolderListAdapter(List<Folder> folderList) {

            mFolders = folderList;
            mViewInflater = getLayoutInflater();
        }

        @Override
        public int getCount() {
            return mFolders.size();
        }

        @Override
        public Object getItem(int position) {
            return mFolders.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            TextView v = (TextView) (convertView != null ? convertView : mViewInflater.inflate(android.R.layout.simple_list_item_1, null));

            Folder item = mFolders.get(position);

            v.setText(item.getDisplayName());

            return v;
        }
    }
}
