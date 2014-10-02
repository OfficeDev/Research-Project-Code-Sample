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
        JsonPrimitive v = mData.getAsJsonPrimitive(fieldName);
        return (v != null) ? v.getAsString() : null;
    }

    public Integer getIntField(final String fieldName) {
        JsonPrimitive v = mData.getAsJsonPrimitive(fieldName);
        return (v != null) ? v.getAsInt() : null;
    }

    public Double getDoubleField(final String fieldName) {
        JsonPrimitive v = mData.getAsJsonPrimitive(fieldName);
        return (v != null) ? v.getAsDouble() : null;
    }

    public Date getDateField(final String fieldName) {
        JsonPrimitive v = mData.getAsJsonPrimitive(fieldName);
        if (v == null || !v.isString()) {
            return null;
        }
        try {
            return getZuluFormat().parse(v.getAsString());
        }
        catch (ParseException e) {
            return null;
        }
    }

    public SPUrl getUrlField(final String fieldName) {
        JsonObject v = mData.getAsJsonObject(fieldName);
        if (v == null) {
            return null;
        }
        return new SPUrl(v);
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
