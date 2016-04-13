<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    
    
<%@ page import="org.apache.jena.query.*" %>
<%@ page import="org.semanticweb.elk.owlapi.ElkReasonerFactory" %>
<%@ page import="org.semanticweb.owlapi.apibinding.OWLManager" %>
<%@ page import="org.semanticweb.owlapi.io.*" %>
<%@ page import="org.semanticweb.owlapi.model.*" %>
<%@ page import="org.semanticweb.owlapi.reasoner.NodeSet" %>
<%@ page import="org.semanticweb.owlapi.reasoner.OWLReasoner" %>
<%@ page import="org.semanticweb.owlapi.util.*" %>
<%@ page import="org.coode.owlapi.manchesterowlsyntax.ManchesterOWLSyntaxParserFactory" %>
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
<title>Insert title here</title>
</head>
<body>
<%


 
String sparqlQuery = request.getParameter("sparqlQuery");
String sparqlEndpoint = request.getParameter("sparqlEndpoint");
String relationalPattern = request.getParameter("RelationalPattern");


// out.println(sparqlQuery);
// out.println(sparqlEndpoint);
// out.println(relationalPattern);

 final String outOnt = "OutOntologies/testOnt.owl";
 final String refOnt = "RefOntologies/go.owl";
 
 final OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
 final OWLOntology ontology = manager.createOntology();
 final OWLDataFactory factory = manager.getOWLDataFactory();
 //manager.loadOntologyFromOntologyDocument(IRI.create("file:"+goOnt));
 
  manager.loadOntologyFromOntologyDocument( new File( getServletContext().getRealPath(refOnt)));
 
 
 final OWLParser parser =  new ManchesterOWLSyntaxParserFactory().createParser( manager );
 OWLOntologyMerger merger = new OWLOntologyMerger(manager);
 
 
 Query query = QueryFactory.create();
 
 
 QueryExecution queryExec = QueryExecutionFactory.sparqlService(sparqlEndpoint,sparqlQuery);
 ResultSet results = queryExec.execSelect();
 List<String> classList = results.getResultVars();
 ResultSet results2 = queryExec.execSelect();
 ResultSetFormatter.out(results2);
 
 
 while(results.hasNext()) {
     QuerySolution qs = results.next();
     String str1 = qs.get(classList.get(0)).toString();
     String str2 = qs.get(classList.get(1)).toString();

     int i = str1.indexOf('/', 1+ str1.indexOf('/', 1+str1.indexOf('/', 1+str1.indexOf('/'))));
     int j = str2.indexOf('/', 1+ str2.indexOf('/', 1+str2.indexOf('/', 1+str2.indexOf('/'))));

     String first1 = str1.substring(0,i);
     String second1  = str1.substring(i+1);
     String first2 = str2.substring(0,j);
     String second2 = str2.substring(j+1);
     String proStr = "<www.somewhere.net/>";
     //System.out.println(first2);
     //System.out.println(second2);

     //Relational Pattern
     String input1 ="Prefix: pr1: <"+first1+"/>\n" +
             "Prefix: pr2: <"+first2+"/>\n"+
             "Prefix: pr3: "+proStr+"\n"+
             "Class: pr1:"+second1+"\n"+
             "Class: pr1:"+second2+"\n"+
             "ObjectProperty: "+"pr3:classifiedWith\n"+
             "Class: pr1:"+second1+"\n"+
             "  SubClassOf: (pr3:classifiedWith"+" some pr1:"+second2+")\n";

     try {
    	 final InputStream in = new ByteArrayInputStream(input1.getBytes());
         parser.parse(new StreamDocumentSource(in), ontology);
     }
     catch (Exception e) {

			out.println("An exception occurred: " + e.getMessage());

		}
     finally {
    	   
    	}
 }

 //System.out.print(ResultSetFormatter.asText(results,query));


 out.println( "All axioms:" );
 for ( final OWLAxiom axiom : ontology.getAxioms() ) {
    out.println( axiom + "<br>");
 }



 queryExec.close();

 
 
 final OWLOntology new_ontology = merger.createMergedOntology(manager,IRI.create("http://aber-owl.net/RDF2OWL.owl"));

 //test some methods
 ElkReasonerFactory elkReasonerFact = new ElkReasonerFactory();
 OWLReasoner elkReasoner = elkReasonerFact.createReasoner(ontology);
 OWLClass testClass = factory.getOWLClass(IRI.create("C0948008"));
 
 //this line is giving an error  java.lang.NoSuchMethodError: org.semanticweb.owlapi.model.OWLObjectSomeValuesFrom.getProperty
 //NodeSet<OWLClass> subClasses = elkReasoner.getSubClasses(testClass, false);
 //out.println("Subclasses are: "+subClasses.toString()+ "<br>"); 
 out.println("Logical axioms count: "+new_ontology.getLogicalAxiomCount() + "<br>");
 out.println("all Axioms count: "+new_ontology.getAxiomCount()+ "<br>");



 // save ontology
 File saved_file = new File( getServletContext().getRealPath(outOnt));
 OWLOntologyFormat format = manager.getOntologyFormat(new_ontology);
 OWLXMLOntologyFormat owlxmlFormat = new OWLXMLOntologyFormat();
 if (format.isPrefixOWLOntologyFormat()){
     owlxmlFormat.copyPrefixesFrom(format.asPrefixOWLOntologyFormat());
 }

 manager.saveOntology(new_ontology,owlxmlFormat,IRI.create(saved_file.toURI()));

//output a link to created onotology 

out.print("<a href='"+outOnt+"'"+"> ");
out.print(outOnt) ;
out.print("</a>");

%>

</body>
</html>