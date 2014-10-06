/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * See License.txt in the project root for license information.
 ******************************************************************************/
package com.microsoft.researchtracker.http.odata;

import java.nio.charset.Charset;

public class Constants {

    /**
     * UTF-8 Encoding name
     */
    public static final String UTF8_NAME = "UTF-8";

    /**
     * UTF-8 Charset instance
     */
    public static final Charset UTF8 = Charset.forName(UTF8_NAME);


    /**
     * ISO8601 date/time format for use with Gson, etc.
     * SharePoint seems to transmit it's data in this format exclusively.
     */
    public static final String ODATA_DATE_TIME_ISO8601_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'";
}