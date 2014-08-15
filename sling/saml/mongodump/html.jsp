<%@ page trimDirectiveWhitespaces="true" contentType="text/html; charset=UTF-8" %>
<%@ include file="/libs/foundation/global.jsp" %>
<!doctype html>
<meta charset="utf-8">
<title>Mongodump</title>
<style>
input { width: 100%; }
</style>
<form method="POST">
    <input type="text" name="path" value="/content/nymag/daily"><br>
    <input type="submit" value="Dump">
</form>
