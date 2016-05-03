<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>RDF-OWL</title>
</head>
<body>

	<form id="sparql-form" name="sparql form" action="RDF2OWL4.jsp"
		method="POST">

		<fieldset>
			<legend>Enter SPARQL Query</legend>
			<section>
			<p>
				<textarea name="sparqlQuery" id="textarea" rows="20"
					style="width: 50%;" cols="">
PREFIX GO: <http://purl.uniprot.org/go/>
PREFIX taxon:<http://purl.uniprot.org/taxonomy/>
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT ?protein ?ontid WHERE {
?protein up:classifiedWith ?ontid .
FILTER regex(str(?ontid),"GO+")} LIMIT 10
				</textarea>
			<div>
				<label for="RelationalPattern">Relational Pattern</label><br />
				<div>
					<input value="has_function" name="RelationalPattern"
						id="RelationalPattern" style="width: 100%" type="text" />
				</div>
			</div>

			</section>
		</fieldset>
		<p>
		<div>
			<label for="sparqlEndpoint">SPARQL endpoint</label><br />
			<div>
				<input value="http://sparql.uniprot.org/" name="sparqlEndpoint"
					id="sparqlEndpoint" style="width: 100%" type="text" />
			</div>
		</div>
		<p>
			<input name="SubmitQuery" value="Submit Query" type="submit"> &nbsp;
			<input name="SaveOntology" value="Save a Ontology" type="submit"> &nbsp;
			<input name="Reset" value="Reset" type="submit">
			


			<%
				
				 if (request.getParameter("msg") !=null)
				 	out.println(" <br>"+ request.getParameter("msg") + " <br>"  );
				%>

		</p>
		</section>
		</fieldset>
	</form>
		<%
	Enumeration keys = session.getAttributeNames();
while (keys.hasMoreElements())
{
  String key = (String)keys.nextElement();
  out.println(key + ": " + session.getValue(key) + "<br>");
}
%>
</body>
</html>