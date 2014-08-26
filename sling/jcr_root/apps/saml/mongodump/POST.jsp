<%@page contentType="application/json; charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@page import="org.apache.jackrabbit.util.ISO8601"%>
<%@page import="java.util.Calendar"%>
<%@page import="org.apache.sling.commons.json.JSONException"%>
<%@page import="org.apache.sling.commons.json.JSONArray"%>
<%@page import="org.apache.sling.commons.json.JSONObject"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.BufferedWriter"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileWriter"%>
<%@page import="java.io.Writer"%>
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

        final JSONArray arr = new JSONArray();
        for (final Value value : values) {
            arr.put(jsonValue(value));
        }
        
        return arr;
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
        if (pattern.matcher(node.getPath()).find()) {
            visitor.visit(node);
        } else {
            final NodeIterator children = node.getNodes();
            while (children.hasNext()) {
                final Node child = children.nextNode();
                walk(child);
            }
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
    private final Writer out;
    private final JspWriter respOut;
    private long count;
    public NodeToJsonOutput(Writer out, JspWriter respOut) {
        this.out = out;
        this.respOut = respOut;
        this.count = 0;
    }

    @Override
    public void visit(Node node) throws RepositoryException {
        try {
            final JSONObject doc = nodeToJson(node);
            doc.put("_path", node.getPath());
            out.write(doc.toString());
            out.write("\n");
            count++;
            if (count % 10000 == 0) {
                respOut.write(String.format("dumpped: %d articles\n", count));
                respOut.flush();
            }
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

final String outputPath = slingRequest.getParameter("out");
if (outputPath == null) {
    throw new ServletException("need parameter: out | full path to dump file");
}
final File outputFile = new File(outputPath);
final Writer writer = new BufferedWriter(new FileWriter(outputFile)); 

final long t = System.currentTimeMillis();
final Node node = resourceResolver.getResource(rootPath).adaptTo(Node.class);
final NodeToJsonOutput worker = new NodeToJsonOutput(writer, out);
final AllNodesMatching traverser = new AllNodesMatching(regex, worker);
traverser.walk(node);

writer.close();
out.write(String.format("Took: %d secs.\n", (System.currentTimeMillis() - t)/1000));
%>