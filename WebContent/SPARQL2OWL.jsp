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
<title>SPARQL2OWL</title>
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
	

public boolean checkInput(List<String> list, String[] strArr){
        int countVar = 0;
        int countMatch = 0;
        for (int i=0; i < strArr.length; i++){
            if (strArr[i].startsWith("?")) {
                countVar++;
            }
            if (list.contains(strArr[i].replace("?",""))){
                countMatch++;
            }
        }

        if (countMatch == countVar && countVar <= list.size())
	        return true;
        else
            return false;
    }


public  OWLOntology createOntologyFromSparql(ResultSet results,String relationalPattern, OWLOntology ontology,OWLDataFactory dataFactory,OWLOntologyManager manager){

	
	  String iri = "www.aber-owl.net/";
	  Provider shortFormProvider = new Provider();
      OWLEntityChecker entityChecker = new ShortFormEntityChecker(shortFormProvider);
	
	  List<String> classList = results.getResultVars();	  
	  String input1 = relationalPattern.replaceAll("\\("," ").replaceAll("\\)"," ");
      System.out.println(input1);
      String[] strArr = input1.split(" ");

      //System.out.println(checkInput(classList,strArr));
      //check #input and match with SPARQL query
      //if (checkInput(classList,strArr)) {
          while (results.hasNext()) {
        	  
              QuerySolution querySolution = results.next();
              relationalPattern = relationalPattern.replaceAll("\\?","");
              for (int i = 0; i < strArr.length; i++) {  //create OWLclasses and OWLObject

                  if (strArr[i].startsWith("?")) {

                      int ind = classList.indexOf(strArr[i].replace("?",""));
                      String str = querySolution.get(classList.get(ind)).toString();
                      System.out.println(str);
                      shortFormProvider.add(dataFactory.getOWLClass(IRI.create(str)));
                      String[] srcArr = str.split("/");
                      String var1 = srcArr[srcArr.length-1];
                      System.out.println(strArr[i].replace("?",""));
                      relationalPattern = relationalPattern.replace(strArr[i].replace("?",""),var1);

                  }
                  if (strArr[i].startsWith("has")) {
                      shortFormProvider.add(dataFactory.getOWLObjectProperty(IRI.create(iri + strArr[i])));
                  }
              }

              ManchesterOWLSyntaxParser parser = OWLManager.createManchesterParser();
              parser.setOWLEntityChecker(entityChecker);
              parser.setStringToParse(relationalPattern);
              OWLAxiom axiom = parser.parseAxiom();
              //System.out.println(axiom.toString());
              manager.addAxiom(ontology, axiom);
              
              
          }
      //}
        //  else{//wrong input, doesn't match with either SPARQL variables, or wrong variables format
          //   System.out.println("wrong input");
          //}

		return ontology;
      }	  

%>

<%

try{

	String sparqlQuery = request.getParameter("sparqlQuery");
	String relPattern = request.getParameter("relPattern");
	out.println(relPattern);
	
	relPattern.trim();

   //String operator = request.getParameter("operator");
	
	String sparqlEndpoint = request.getParameter("sparqlEndpoint");
	
	String SubmitQuery = request.getParameter("SubmitQuery");
	String SaveOntology = request.getParameter("SaveOntology");
	String Reset = request.getParameter("Reset");

	final  String mergedOnt = "OutOntologies/mergedOnt"+session.getId()+".owl";

	final  OWLDataFactory dataFactory = OWLManager.getOWLDataFactory();
	final  OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
	
Integer queryCounter = (Integer)session.getAttribute("queryCounter");
OWLOntology ontology = manager.createOntology(IRI.create("http://aber-owl.net/SPARQL2OWL.owl"));
	
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
 
    //save the result as session object
    session.setAttribute("queryCounter",queryCounter);
    session.setAttribute("results"+queryCounter,results);
    session.setAttribute("relPattern"+queryCounter,relPattern);
    
    
    //check entered relational pattern and match it with SPARQL query variables
	List<String> classList = results.getResultVars(); 
	String input1 = relPattern.replaceAll("\\("," ").replaceAll("\\)"," ");

	String[] strArr = input1.split(" ");
    
    if (!checkInput(classList,strArr)){
  	 //out.print("wrong relational pattern input");
     response.sendRedirect("index.jsp?msg="+java.net.URLEncoder.encode("Wrong relational pattern entered !"));
    }
    else
    response.sendRedirect("index.jsp?msg="+java.net.URLEncoder.encode("Query Completed successfully"));
}


if (SaveOntology !=null) {
	for (int i=1; i< queryCounter+1; i++){
		   // out.println(" <br>" +i );
			ResultSet results=  (ResultSet)session.getAttribute("results"+i);
			String rp=  (String) session.getAttribute("relPattern"+i);
	  	      
			OWLOntology newontology = createOntologyFromSparql(results,rp,ontology,dataFactory,manager);	
			OWLOntologyMerger merger = new OWLOntologyMerger(manager);
		
		}
			
	//manager.saveOntology(ontology,IRI.create(new File( getServletContext().getRealPath(mergedOnt))));

	
	
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
	//e.printStackTrace(new  java.io.PrintWriter(out));
	//response.sendRedirect("index.jsp?msg="+java.net.URLEncoder.encode("Query failed "));

}
finally {

	 
   
}



%>




</body>
</html>