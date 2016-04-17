<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    
    
<%@ page import="org.apache.jena.query.*" %>
<%@ page import="org.semanticweb.owlapi.apibinding.OWLManager" %>
<%@ page import="org.semanticweb.owlapi.expression.OWLEntityChecker" %>
<%@ page import="org.semanticweb.owlapi.expression.ShortFormEntityChecker" %>
<%@ page import="org.semanticweb.owlapi.model.*" %>
<%@ page import="org.semanticweb.owlapi.util.OWLOntologyMerger" %>
<%@ page import="org.semanticweb.owlapi.util.mansyntax.ManchesterOWLSyntaxParser" %>
<%@ page import="org.semanticweb.owlapi.util.CachingBidirectionalShortFormProvider" %>
<%@ page import="org.semanticweb.owlapi.util.SimpleShortFormProvider" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.ByteArrayInputStream" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.lang.annotation.Annotation" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.ServletContext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>RDF to OWL</title>
</head>
<body>


<%!

private static class Provider extends CachingBidirectionalShortFormProvider {

    private SimpleShortFormProvider provider = new SimpleShortFormProvider();

    @Override
    protected String generateShortForm(OWLEntity entity){
        return provider.getShortForm(entity);
    }

}


%>

<%
String sparqlQuery = request.getParameter("sparqlQuery");
String sparqlEndpoint = request.getParameter("sparqlEndpoint");
String relationalPattern = request.getParameter("RelationalPattern");



final String outOnt = "OutOntologies/testOnt.owl";
final String goOnt = "http://purl.obolibrary.org/obo/go.owl";
final String ncbiOnt  = "http://purl.obolibrary.org/obo/ncbitaxon.owl";

final OWLDataFactory df = OWLManager.getOWLDataFactory();
final OWLOntologyManager manager = OWLManager.createOWLOntologyManager();

final OWLOntologyMerger merger = new OWLOntologyMerger(manager);
manager.loadOntologyFromOntologyDocument(IRI.create(goOnt));
manager.loadOntologyFromOntologyDocument(IRI.create(ncbiOnt));

final OWLOntology ontology = merger.createMergedOntology(manager, IRI.create("http://aber-owl/RDF2OWL.owl"));



Query query = QueryFactory.create(sparqlQuery);
QueryExecution queryExec = QueryExecutionFactory.sparqlService(sparqlEndpoint,sparqlQuery);
ResultSet results = queryExec.execSelect();
List<String> classList = results.getResultVars();
ResultSet results2 = queryExec.execSelect();
ResultSetFormatter.out(results2);

try {
 
while (results.hasNext()) {
    QuerySolution qs = results.next();
    String str1 = qs.get(classList.get(0)).toString();
    String str2 = qs.get(classList.get(1)).toString();

    int i = str1.indexOf('/', 1 + str1.indexOf('/', 1 + str1.indexOf('/', 1 + str1.indexOf('/'))));
    int j = str2.indexOf('/', 1 + str2.indexOf('/', 1 + str2.indexOf('/', 1 + str2.indexOf('/'))));

    String var1 = str1.substring(i + 1);
    String var2 = str2.substring(j + 1);


    Provider shortFormProvider = new Provider();
    OWLEntityChecker entityChecker = new ShortFormEntityChecker(shortFormProvider);
    shortFormProvider.add(df.getOWLClass(IRI.create(str1)));
    shortFormProvider.add(df.getOWLClass(IRI.create(str2)));
    shortFormProvider.add(df.getOWLObjectProperty(IRI.create("http://aber-owl.org/hasFunction")));
    String input = var1+relationalPattern+var2+")";
    ManchesterOWLSyntaxParser parser = OWLManager.createManchesterParser();
    parser.setOWLEntityChecker(entityChecker);
    parser.setStringToParse(input);
    OWLAxiom axiom = parser.parseAxiom();
    manager.addAxiom(ontology,axiom);

}

manager.saveOntology(ontology,IRI.create(new File( getServletContext().getRealPath(outOnt))));
}catch (Exception e) {

	out.println("An exception occurred: " + e.getMessage());

}
finally {

	 queryExec.close();
   
}

//output a link to created onotology 

out.print("<a href='"+outOnt+"'"+"> ");
out.print(outOnt) ;
out.print("</a>");

%>

 
 

</body>
</html>