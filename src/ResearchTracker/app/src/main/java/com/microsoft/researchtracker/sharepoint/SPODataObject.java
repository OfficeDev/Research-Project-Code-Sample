package com.microsoft.researchtracker.sharepoint;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class SPODataObject {

    private DateFormat mZuluFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

    private JsonObject mData;

    public SPODataObject(JsonObject data) {

        mData = data;
    }

    private DateFormat getZuluFormat() {
        if (mZuluFormat == null) {
            mZuluFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            mZuluFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        }
        return mZuluFormat;
    }

    public String getODataMetadata() {
        return getStringField("odata.metadata");
    }

    public String getODataId() {
        return getStringField("odata.id");
    }

    public String getODataETag() {
        return getStringField("odata.etag");
    }

    public String getStringField(final String fieldName) {
        JsonElement value = mData.get(fieldName);
        if (value == null || value.isJsonNull() || !value.isJsonPrimitive()) {
            return null;
        }
        return mData.getAsJsonPrimitive(fieldName).getAsString();
    }

    public Integer getIntField(final String fieldName) {
        JsonElement value = mData.get(fieldName);
        if (value == null || value.isJsonNull() || !value.isJsonPrimitive()) {
            return null;
        }
        return mData.getAsJsonPrimitive(fieldName).getAsInt();
    }

    public Double getDoubleField(final String fieldName) {
        JsonElement value = mData.get(fieldName);
        if (value == null || value.isJsonNull() || !value.isJsonPrimitive()) {
            return null;
        }
        return mData.getAsJsonPrimitive(fieldName).getAsDouble();
    }

    public Date getDateField(final String fieldName) {
        JsonElement value = mData.get(fieldName);
        if (value == null || value.isJsonNull() || !value.isJsonPrimitive()) {
            return null;
        }
        try {
            return getZuluFormat().parse(value.getAsJsonPrimitive().getAsString());
        }
        catch (ParseException e) {
            return null;
        }
    }

    public SPUrl getUrlField(final String fieldName) {
        JsonObject value = mData.getAsJsonObject(fieldName);
        if (value == null || value.isJsonNull()) {
            return null;
        }
        return new SPUrl(value);
    }

    public void setField(final String fieldName, String value) {
        if (value == null) {
            mData.add(fieldName, null);
        }
        else {
            mData.add(fieldName, new JsonPrimitive(value));
        }
    }

    public void setField(final String fieldName, boolean value) {
        mData.add(fieldName, new JsonPrimitive(value));
    }

    public void setField(final String fieldName, int value) {
        mData.add(fieldName, new JsonPrimitive(value));
    }

    public void setField(final String fieldName, double value) {
        mData.add(fieldName, new JsonPrimitive(value));
    }

    public void setField(final String fieldName, Date value) {
        if (value == null) {
            mData.add(fieldName, null);
        }
        else {
            setField(fieldName, mZuluFormat.format(value));
        }
    }

    public void setField(final String fieldName, SPUrl value) {
        if (value != null) {
            mData.add(fieldName, null);
        }
        else {
            mData.add(fieldName, value.toJson());
        }
    }

    public JsonElement toJson() {
        return mData;
    }
}
