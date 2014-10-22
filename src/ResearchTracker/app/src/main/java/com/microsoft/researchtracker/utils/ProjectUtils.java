package com.microsoft.researchtracker.utils;

import com.microsoft.researchtracker.sharepoint.models.ResearchProjectModel;

public class ProjectUtils {

    private static double getProjectHue(ResearchProjectModel project) {

        if (project == null) {
            return 0;
        }

        String hash = project.getId() + project.getTitle();

        return Math.abs(Math.sin(hash.hashCode()));
    }

    public static int getProjectColor(ResearchProjectModel project) {

        double hue = getProjectHue(project);

        return ColorUtil.hsvToColor(hue, 0.8, 0.85);
    }
}
