<%--
  ADOBE CONFIDENTIAL
  ___________________

   Copyright 2016 Adobe Systems Incorporated
   All Rights Reserved.

  NOTICE:  All information contained herein is, and remains
  the property of Adobe Systems Incorporated and its suppliers,
  if any.  The intellectual and technical concepts contained
  herein are proprietary to Adobe Systems Incorporated and its
  suppliers and are protected by trade secret or copyright law.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe Systems Incorporated.

  ==============================================================================

  Text component

  Draws text.

--%>
<%@page session="false" import="org.apache.commons.lang.ArrayUtils,
                                com.day.cq.wcm.foundation.utils.RTEUtils,
                                java.lang.IllegalArgumentException" %><%
%><%@include file="/libs/foundation/global.jsp"%>
<%
    String [] selectors = slingRequest.getRequestPathInfo().getSelectors();
    Boolean disableXSS = ArrayUtils.contains(selectors, "disableXSSFiltering");
    try {
        RTEUtils.createFilteredJSONResponse(sling.getRequest(), sling.getResponse(), "text", xssAPI, !disableXSS);
    } catch (IllegalArgumentException e) {
        log.warn("Unexpected selector type", e.getMessage());
    }
%>