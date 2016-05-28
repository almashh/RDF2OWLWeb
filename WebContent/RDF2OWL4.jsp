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

public  OWLOntology createOntologyFromSparql(ResultSet results,String relationalPattern,String operator, OWLOntology ontology,OWLDataFactory dataFactory,OWLOntologyManager manager){

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
          String patternURL = relationalPattern;
        
          
          shortFormProvider.add(dataFactory.getOWLObjectProperty(IRI.create("http://aber-owl.org/"+patternURL)));
          String input = var1[var1.length-1] + " subClassOf("+relationalPattern+operator+var2[var2.length-1] + ")";
        
         
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

try{

	String sparqlQuery = request.getParameter("sparqlQuery");
	String relPattern = request.getParameter("relPattern");
	relPattern.trim();

    String operator = request.getParameter("operator");
	
	String sparqlEndpoint = request.getParameter("sparqlEndpoint");
	
	String SubmitQuery = request.getParameter("SubmitQuery");
	String SaveOntology = request.getParameter("SaveOntology");
	String Reset = request.getParameter("Reset");

	final  String mergedOnt = "OutOntologies/mergedOnt"+session.getId()+".owl";

	final  OWLDataFactory dataFactory = OWLManager.getOWLDataFactory();
	final  OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
	
Integer queryCounter = (Integer)session.getAttribute("queryCounter");
OWLOntology ontology = manager.createOntology(IRI.create("http://aber-owl.net/RDF2OWLAll.owl"));
	
if (Reset !=null) {
	
	session.invalidate();
	response.sendRedirect("index.jsp?msg="+java.net.URLEncoder.encode("Web Application session is resetted"));

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
 session.setAttribute("operator"+queryCounter,operator);
 session.setAttribute("relPattern"+queryCounter,relPattern);
 response.sendRedirect("index.jsp?msg="+java.net.URLEncoder.encode("Query Completed successfully"));
 
}

if (SaveOntology !=null) {

	
	for (int i=1; i< queryCounter+1; i++){
		   // out.println(" <br>" +i );
			ResultSet results=  (ResultSet)session.getAttribute("results"+i);
			String rp=  (String) session.getAttribute("relPattern"+i);
			String op = (String) session.getAttribute("operator"+i); 
		    //out.println(" <br>" + "?X"+ " subClassOf("+rp+ op+ "?Y" + ")" );
		
			OWLOntology newontology = createOntologyFromSparql(results,rp,op,ontology,dataFactory,manager);	
			OWLOntologyMerger merger = new OWLOntologyMerger(manager);
			//out.println("New ontologies merged .......");
			//
		}
			
	manager.saveOntology(ontology,IRI.create(new File( getServletContext().getRealPath(mergedOnt))));
	
	if (request.getParameter("refOntology") != null) {

		String[] refOntologies = request.getParameterValues("refOntology");

		//out.print(refOntologies.length);

		for (int i = 0; i < refOntologies.length; i++) {

			//out.print(refOntologies[i] + "<br>");
			OWLImportsDeclaration imports = manager.getOWLDataFactory().getOWLImportsDeclaration(IRI.create(refOntologies[i]));
			manager.applyChange(new AddImport(ontology, imports));
			
		}
	}
		
	
		//resave the ontnolgy 
		manager.saveOntology(ontology,IRI.create(new File( getServletContext().getRealPath(mergedOnt))));
		//out.println("New Ontology saved to: "+ mergedOnt); 
		
		// //output a link to created onotology 
		
	out.print("<a href='"+mergedOnt+"'"+"> ");
	out.print("Here is the merged ontology") ;
	out.print("<img  alt=\"ontology\" src=\"dw.png\" width=\"50\" height=\"50\">");
	out.print("</a>");
}


}catch (Exception e) {
	
	
	out.print("<br>");

	out.println("An exception occurred: " + e.getMessage());
	out.print("<br>");
	e.printStackTrace(new  java.io.PrintWriter(out));
	//response.sendRedirect("index.jsp?msg="+java.net.URLEncoder.encode("Query failed"));

}
finally {

	 
   
}



%>




</body>
</html>