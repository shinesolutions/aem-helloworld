
package apps.helloworld.components.page.footer;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;

import com.adobe.cq.sightly.WCMUsePojo;
import com.day.cq.wcm.api.Page;
import com.day.cq.wcm.api.PageFilter;


public class Footer extends WCMUsePojo {

    private List<Page> items = new ArrayList<Page>();
    private int currentYear;

    @Override
    public void activate() throws Exception {
        currentYear = Calendar.getInstance().get(Calendar.YEAR);
       }

    public int getCurrentYear() {
        return currentYear;
    }
}
