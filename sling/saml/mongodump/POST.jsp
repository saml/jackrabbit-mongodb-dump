<%@page contentType="application/json; charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@page import="org.apache.jackrabbit.util.ISO8601"%>
<%@page import="java.util.Calendar"%>
<%@page import="org.apache.sling.commons.json.JSONException"%>
<%@page import="org.apache.sling.commons.json.JSONArray"%>
<%@page import="org.apache.sling.commons.json.JSONObject"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.io.IOException"%>
<%@page import="org.apache.sling.api.resource.ResourceResolver"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.regex.Matcher"%>
<%@include file="/libs/foundation/global.jsp"%>
<%!
private static Object jsonValue(Value value) throws RepositoryException {
    final int type = value.getType();
    if (PropertyType.BOOLEAN == type) {
        return value.getBoolean();
    }

    if (PropertyType.LONG == type) {
        return value.getLong();
    }

    if (PropertyType.DOUBLE == type) {
        return value.getDouble();
    }

    if (PropertyType.DECIMAL == type) {
        return value.getDecimal();
    }

    if (PropertyType.DATE == type) {
        final Calendar cal = value.getDate();
        try {
            final JSONObject doc = new JSONObject();
            doc.put("$date", cal.getTimeInMillis());
            return doc;
        } catch (JSONException e) {
            return ISO8601.format(cal);
        }
    }

    if (PropertyType.STRING == type) {
        return value.getString();
    }

    return value.getString();
}

private static Object jsonValue(Property prop) throws RepositoryException {
    if (prop.isMultiple()) {
        final Value[] values = prop.getValues();
        if (values == null) {
            return null;
        }

        final List<Object> result = new ArrayList<Object>(values.length);
        for (final Value value : values) {
            result.add(jsonValue(value));
        }

        return result;
    }

    final Value value = prop.getValue();
    if (value == null) {
        return null;
    }
    return jsonValue(value);
}


private static abstract class NodeVisitor {
    abstract void visit(Node node) throws RepositoryException;
}

private static class AllNodesMatching {
    private final Pattern pattern;
    private final NodeVisitor visitor;

    // when pattern is null, all nodes are visited.
    public AllNodesMatching(Pattern pattern, NodeVisitor visitor) {
        this.pattern = pattern;
        this.visitor = visitor;
    }

    public void walk(Node node) throws RepositoryException {
        if (pattern == null || pattern.matcher(node.getPath()).find()) {
            visitor.visit(node);
        }

        final NodeIterator children = node.getNodes();
        while (children.hasNext()) {
            final Node child = children.nextNode();
            walk(child);
        }
    }
}

private static JSONObject nodeToJson(Node node) throws RepositoryException, JSONException {

    final JSONObject doc = new JSONObject();
    doc.put("_name", node.getName());

    final PropertyIterator props = node.getProperties();
    while (props.hasNext()) {
        final Property prop = props.nextProperty();
        doc.put(prop.getName(), jsonValue(prop));
    }

    final NodeIterator children = node.getNodes();
    final JSONArray arr = new JSONArray();
    while (children.hasNext()) {
        final Node child = children.nextNode();
        arr.put(nodeToJson(child));
    }
    if (arr.length() > 0) {
        doc.put("_children", arr);
    }

    return doc;
}

private static class NodeToJsonOutput extends NodeVisitor {
    private final JspWriter out;
    public NodeToJsonOutput(JspWriter out) {
        this.out = out;
    }

    @Override
    public void visit(Node node) throws RepositoryException {
        try {
            final JSONObject doc = nodeToJson(node);
            doc.put("_path", node.getPath());
            out.write(doc.toString());
            out.write("\n");
        } catch (JSONException e) {

        } catch (IOException e) {
            
        }
    }
}
%>

<%
final String rootPath = slingRequest.getParameter("path");
if (rootPath == null) {
    throw new ServletException("need parameters: path");
}

String pattern = slingRequest.getParameter("regex");
if (pattern == null) {
    pattern = "/\\d\\d\\d\\d/\\d\\d/(?:(?!\\d\\d/)[^/]+)/jcr:content$";
}

final Pattern regex = Pattern.compile(pattern);

final Node node = resourceResolver.getResource(rootPath).adaptTo(Node.class);
final NodeToJsonOutput worker = new NodeToJsonOutput(out);
final AllNodesMatching traverser = new AllNodesMatching(regex, worker);
traverser.walk(node);
%>
