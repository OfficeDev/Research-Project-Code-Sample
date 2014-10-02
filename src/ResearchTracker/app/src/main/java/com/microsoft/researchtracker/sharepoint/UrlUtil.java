package com.microsoft.researchtracker.sharepoint;

import java.net.URLDecoder;
import java.net.URLEncoder;

public class UrlUtil {

    public static String encodeComponent(String str) {
        return URLEncoder.encode(str).replace("+", "%20");
    }

    public static String decodeComponent(String encoded) {
        return URLDecoder.decode(encoded);
    }
}
