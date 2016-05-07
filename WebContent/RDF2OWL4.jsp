<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.jena.query.*"%>
<%@ page import="org.semanticweb.owlapi.apibinding.OWLManager"%>
<%@ page import="org.semanticweb.owlapi.expression.OWLEntityChecker"%>
<%@ page
	import="org.semanticweb.owlapi.expression.ShortFormEntityChecker"%>
<%@ page import="org.semanticweb.owlapi.model.*"%>
<%@ page import="org.semanticweb.owlapi.util.OWLOntologyMerger"%>
<%@ page
	import="org.semanticweb.owlapi.util.mansyntax.ManchesterOWLSyntaxParser"%>
<%@ page
	import="org.semanticweb.owlapi.util.CachingBidirectionalShortFormProvider"%>
<%@ page import="org.semanticweb.owlapi.util.SimpleShortFormProvider"%>
<%@ page import="java.util.List"%>
<%@ page import="java.io.ByteArrayInputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.io.InputStream"%>
<%@ page import="java.lang.annotation.Annotation"%>
<%@ page import="java.util.List"%>
<%@ page import="javax.servlet.ServletContext"%>
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

	<%!

public ResultSet getSparqlResults(String sparqlQuery, String sparqlEndpoint){

    Query query = QueryFactory.create(sparqlQuery);
    QueryExecution queryExec = QueryExecutionFactory.sparqlService(sparqlEndpoint, query);
    ResultSet results = queryExec.execSelect();
    ResultSet results2 = queryExec.execSelect();
    ResultSetFormatter.out(results2);

    return results;
}

public  OWLOntology createOntologyFromSparql(ResultSet results,String relationalPattern, OWLOntology ontology,OWLDataFactory dataFactory,OWLOntologyManager manager){

	  List<String> classList = results.getResultVars();

      while (results.hasNext()) {
          QuerySolution qs = results.next();
          String str1 = qs.get(classList.get(0)).toString();
          String str2 = qs.get(classList.get(1)).toString();
          //String str2 = "http://purl.uniprot.org/taxonomy/9606";  //to check humans only when using has_part

          String[] var1 = str1.split("/");
          String[] var2 = str2.split("/");

          Provider shortFormProvider = new Provider();
          OWLEntityChecker entityChecker = new ShortFormEntityChecker(shortFormProvider);
          shortFormProvider.add(dataFactory.getOWLClass(IRI.create(str1)));
          shortFormProvider.add(dataFactory.getOWLClass(IRI.create(str2)));
          shortFormProvider.add(dataFactory.getOWLObjectProperty(IRI.create("http://aber-owl.org/"+relationalPattern)));
          String input = var1[var1.length-1] + " subClassOf("+relationalPattern+" some " + var2[var2.length-1] + ")";
          ManchesterOWLSyntaxParser parser = OWLManager.createManchesterParser();
          parser.setOWLEntityChecker(entityChecker);
          parser.setStringToParse(input);
          OWLAxiom axiom = parser.parseAxiom();
          manager.addAxiom(ontology,axiom);
      }
      return ontology;
  }

%>


	<%
String sparqlQuery = request.getParameter("sparqlQuery");
String relationalPattern = request.getParameter("RelationalPattern");

String sparqlEndpoint = request.getParameter("sparqlEndpoint");

String SubmitQuery = request.getParameter("SubmitQuery");
String SaveOntology = request.getParameter("SaveOntology");
String Reset = request.getParameter("Reset");


final  String goOnt = "http://purl.obolibrary.org/obo/go.owl";
final  String ncbiOnt = "http://purl.obolibrary.org/obo/ncbitaxon.owl";
final  String mergedOnt = "OutOntologies/mergedOnt"+session.getId()+".owl";

final  OWLDataFactory dataFactory = OWLManager.getOWLDataFactory();
final  OWLOntologyManager manager = OWLManager.createOWLOntologyManager();




try{

	
Integer queryCounter = (Integer)session.getAttribute("queryCounter");
OWLOntology ontology = manager.createOntology(IRI.create("http://aber-owl.net/RDF2OWLAll.owl"));
	
if (Reset !=null) {
	
	session.invalidate();
	response.sendRedirect("index.jsp?msg=Web Application session is resetted ");

}

if (SubmitQuery !=null) {

 ResultSet results = getSparqlResults(sparqlQuery, sparqlEndpoint);

 if( queryCounter ==null || queryCounter == 0 ){
       /* First query */
      
       queryCounter = 1;
     
    }else{
       
       queryCounter += 1;
       out.println(" <br>" +queryCounter );
    }
 session.setAttribute("queryCounter",queryCounter);
//save the result as session object
 session.setAttribute("results"+queryCounter,results);
 response.sendRedirect("index.jsp?msg=Query Completed successfully ");
 
}

if (SaveOntology !=null) {

	
	for (int i=1; i< queryCounter+1; i++){
		out.println(" <br>" +i );
			ResultSet results=  (ResultSet)session.getAttribute("results"+i);
			OWLOntology newontology = createOntologyFromSparql(results,relationalPattern,ontology,dataFactory,manager);	
			OWLOntologyMerger merger = new OWLOntologyMerger(manager);
			out.println("New ontologies merged .......");
			manager.saveOntology(ontology,IRI.create(new File( getServletContext().getRealPath(mergedOnt))));
		}
			
		
	OWLImportsDeclaration importsGo = manager.getOWLDataFactory().getOWLImportsDeclaration(IRI.create("http://purl.obolibrary.org/obo/go.owl"));
	manager.applyChange(new AddImport(ontology, importsGo));
	OWLImportsDeclaration importsNCBI = manager.getOWLDataFactory().getOWLImportsDeclaration(IRI.create("http://purl.obolibrary.org/obo/ncbitaxon.owl"));
	manager.applyChange(new AddImport(ontology, importsNCBI));
		
		// manager.saveOntology(ontology,IRI.create(new File( getServletContext().getRealPath(mergedOnt))));
		// out.println("New Ontology saved to: "+ mergedOnt); 
		
		// //output a link to created onotology 
		
	out.print("<a href='"+mergedOnt+"'"+"> ");
	out.print(mergedOnt) ;
	out.print("</a>");
}


}catch (Exception e) {
	
	
	out.print("<br>");

	//out.println("An exception occurred: " + e.getMessage());
	out.print("<br>");
	e.printStackTrace(new  java.io.PrintWriter(out));
	response.sendRedirect("index.jsp?msg=Query failed ");

}
finally {

	 
   
}



%>




</body>
</html>