package com.shinesolutions.models;

import com.day.cq.wcm.api.Page;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.models.annotations.Model;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

@Model(adaptables = SlingHttpServletRequest.class)

public class Navigation {

    @Inject
    private Page currentPage;

    private List<Page> items = new ArrayList<>();

    private Page rootPage;

    @PostConstruct
    private void init() {
        rootPage = currentPage.getAbsoluteParent(1);

        if (rootPage == null) {
            rootPage = currentPage;
        }

        Iterator<Page> listChildren = rootPage.listChildren();

        while (listChildren.hasNext()) {
            items.add(listChildren.next());
        }

    }

    public List<Page> getItems() {
        return items;
    }

    public Page getRootPage() {
        return rootPage;
    }

}
