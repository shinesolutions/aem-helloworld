<%@page session="false"%><%@ page import="com.day.cq.wcm.foundation.Placeholder" %>
<%--
  Copyright 1997-2009 Day Management AG
  Barfuesserplatz 6, 4001 Basel, Switzerland
  All Rights Reserved.

  This software is the confidential and proprietary information of
  Day Management AG, ("Confidential Information"). You shall not
  disclose such Confidential Information and shall use it only in
  accordance with the terms of the license agreement you entered into
  with Day.

  ==============================================================================

  Text component

  Draws text.

--%><%
%><%@include file="/libs/foundation/global.jsp"%><%
%>
<cq:includeClientLib categories="cq.wcm.foundation.accessibility"/>
<%
    if (properties.get("text",null) == null ){
        String showAltComponentName = request.getParameter("showAltComponentName");
        if(showAltComponentName!=null && showAltComponentName.equalsIgnoreCase("true")) { %>
            <h2 class="cq-paragraphreference-thumbnail-text"><%= xssAPI.encodeForHTML(resource.getName()) %></h2>
        <%}
    }%>
    <cq:text property="text" escapeXml="true"
        placeholder="<%= Placeholder.getDefaultPlaceholder(slingRequest, component, null)%>"/>
