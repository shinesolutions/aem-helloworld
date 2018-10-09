package com.shinesolutions.models;

import org.apache.sling.api.resource.Resource;
import org.apache.sling.models.annotations.Model;
import org.apache.sling.models.annotations.injectorspecific.Self;



@Model(adaptables = Resource.class)
public class HeroImage {

    @Self
    private Resource resource;

    public String getImagePath() {
        return resource.getPath() + ".img.jpg";
    }

}
