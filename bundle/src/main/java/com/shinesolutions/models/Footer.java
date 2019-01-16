package com.shinesolutions.models;

import org.apache.sling.api.resource.Resource;
import org.apache.sling.models.annotations.Model;

import javax.annotation.PostConstruct;
import java.util.Calendar;


@Model(adaptables = Resource.class)
public class Footer {

    private int currentYear;

    @PostConstruct
    private void init() {
        currentYear = Calendar.getInstance().get(Calendar.YEAR);
    }

    public int getCurrentYear() {
        return currentYear;
    }

}
