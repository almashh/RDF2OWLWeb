<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<title>RDF-OWL</title>
</head>
<body>

	<form id="sparql-form" name="sparql form" action="RDF2OWL4.jsp"
		method="post">

		<fieldset>
			<legend>1) Enter SPARQL Queries</legend>
			<section>
			<p>
				<textarea name="sparqlQuery" id="textarea" rows="20"
					style="width: 50%;" cols="">

				</textarea>
			<div>
				<label for="relPattern">Relational Pattern:</label><br />
					<div>?X
					<input value="" name="relPattern" id="relPattern" type="text" />
					<select name="operator">
					  <option value=" some "  selected="selected">some</option>
					  <option value=" only ">only</option>
<!-- 					  <option value=" min ">min</option> -->
<!-- 					  <option value=" max ">max</option> -->
<!-- 					  <option value=" only ">only</option> -->
<!-- 					  <option value=" Self ">Self</option> -->
<!-- 					  <option value=" exactly ">exactly</option> -->
<!-- 					 <option value=" value ">value</option> -->
					</select>
					?Y
				</div>
				<p>
		</div>
			<div>
			<label for="sparqlEndpoint">SPARQL endpoint:</label><br />
			<div>
				<input value="" name="sparqlEndpoint" id="sparqlEndpoint" style="width: 50%" type="text" />
			</div>
		</div>
			</section>
			<p>
			<input name="SubmitQuery" value="Submit Query" type="submit"> &nbsp;
			<input name="Reset" value="Reset" type="submit">
			 <p> <%
		if (request.getParameter("msg") != null)
				out.println(" <br> <font size=\"3\" color=\"red\">" + request.getParameter("msg") + "</font> <br>");
		%>

		</fieldset>
		
	  

		<p>
		<fieldset>
		<legend>2) Save as an OWL File </legend>
		<div>
			<label for="refOntology">Import Reference Ontologies:</label><br />
			<div>
				<select name="refOntology" multiple >
					<option value="http://purl.obolibrary.org/obo/hp.owl">Human Phenotype Ontology</option>
					<option value="http://purl.obolibrary.org/obo/go.owl">Gene Ontology</option>
					<option value="http://purl.obolibrary.org/obo/ncbitaxon.owl">NCBI taxonomy Ontology</option>
					<option value="http://purl.obolibrary.org/obo/ro.owl">Relational Ontology</option>
					<option value="http://purl.obolibrary.org/obo/uberon.owl">Uberon Ontology</option>
					<option value="http://purl.obolibrary.org/obo/pato.owl">Phenotypic Quality Ontology</option>
					<option value="http://purl.obolibrary.org/obo/chebi.owl">Chebi Ontology</option>
				</select>
			</div>
		</div>

		</p>
	<input name="SaveOntology" value="Save a Ontology" type="submit"> &nbsp;
		</fieldset>
	</form>
	


	<%
		// for debugining
// 			Enumeration keys = session.getAttributeNames();
// 			while (keys.hasMoreElements()) {
// 				String key = (String) keys.nextElement();
// 				out.println(key + ": " + session.getValue(key) + "<br>");
// 			}
	%>
</body>
</html>