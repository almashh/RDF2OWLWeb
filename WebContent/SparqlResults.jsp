<%@page import="java.util.List"%>
<%@page import="org.apache.jena.rdf.model.Resource"%>
<%@page import="org.apache.jena.query.QuerySolution"%>
<%@page import="org.apache.jena.query.ResultSet"%>
<%@page import="org.apache.jena.query.QueryExecutionFactory"%>
<%@page import="org.apache.jena.query.QueryExecution"%>
<%@page import="org.apache.jena.query.QueryFactory"%>
<%@page import="org.apache.jena.query.Query"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="org.apache.jena.sparql.* "%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>




		<%
			String service = request.getParameter("sparqlEndpoint");
			String query = request.getParameter("sparqlQuery");
			QueryExecution qe = QueryExecutionFactory.sparqlService(service, query);
			
			
			try {
				ResultSet rs = qe.execSelect();
				
				List<String> l=rs.getResultVars();
				out.print("<table border=1 align=\"center\">");
				out.print("<tr>");
				for(int i=0;i<l.size();i++) {
					out.print("<th bgcolor=\"#FFA500\"><fontsize=6>"+l.get(i)+"</font></th>");
				}
				out.print("</tr>");
				out.print("<tbody bgcolor=\"#C0C0C0\">");

				while (rs.hasNext()) {

					QuerySolution qs = rs.nextSolution();
					out.print("<tr>");
					for(int i=0;i<l.size();i++){
						
						String val=qs.get(l.get(i).toString()).toString();
						out.print("<td>"+val+"</td>");
					
					}
					out.print("</tr>");
				
				}
				
				out.print("</tbody></table>");
				out.print("</body></html>");

			} catch (Exception e) {

				out.println("An exception occurred: " + e.getMessage());

			} finally {
				qe.close();
			}
		%>






</body>
</html>