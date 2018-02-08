package apps.helloworld.components.page.simplenavigation;


import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.adobe.cq.sightly.WCMUsePojo;
import com.day.cq.wcm.api.Page;
import com.day.cq.wcm.api.PageFilter;

public class TopNav extends WCMUsePojo

{
    private List<Page> items = new ArrayList<Page>();
    private Page rootPage;
    
    @Override
    public void activate() throws Exception{
      rootPage = getCurrentPage().getAbsoluteParent(1);
      
      if(rootPage==null){
      rootPage = getCurrentPage();
      }
      
     Iterator<Page> listChildren = rootPage.listChildren(new PageFilter(getRequest()));
       while(listChildren.hasNext()){
       items.add(listChildren.next());
       }
    }
    
    public List<Page> getItems(){
    return items;
    }
    
    public Page rootPage(){
    return rootPage;
    }
    
    
}