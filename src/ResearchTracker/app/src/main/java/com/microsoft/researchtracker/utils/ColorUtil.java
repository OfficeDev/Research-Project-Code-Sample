package com.microsoft.researchtracker.utils;

import android.graphics.Color;

public class ColorUtil {

    public static int hsvToColor(double h, double s, double v)
    {
        if (h < 0 || h > 1) throw new IllegalArgumentException("h");
        if (s < 0 || s > 1) throw new IllegalArgumentException("s");
        if (v < 0 || v > 1) throw new IllegalArgumentException("v");

        // see: http://en.wikipedia.org/wiki/HSL_and_HSV#From_HSV
        double C = v * s; //Chroma
        double H = h * 6; //Hue
        double X = C * (1 - Math.abs((H % 2) - 1));
        double M = v - C;

        int column = (int)Math.floor(H);

        // Find the column into which our Hue falls
        // see: http://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/HSV-RGB-comparison.svg/300px-HSV-RGB-comparison.svg.png
        double[] rgb = (column == 0) ? new double[] { C, X, 0 } :
                       (column == 1) ? new double[] { X, C, 0 } :
                       (column == 2) ? new double[] { 0, C, X } :
                       (column == 3) ? new double[] { 0, X, C } :
                       (column == 4) ? new double[] { X, 0, C } :
                       (column == 5) ? new double[] { C, 0, X } : new double[] { 0, 0, 0 };

        return Color.argb(
            255,
            (int) Math.floor(256 * (rgb[0] + M)),
            (int) Math.floor(256 * (rgb[1] + M)),
            (int) Math.floor(256 * (rgb[2] + M))
        );
    }
}
