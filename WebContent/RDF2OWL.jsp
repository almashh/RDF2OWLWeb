<%@ page language="java" contentType="text/html; charset=windows-1256"
    pageEncoding="windows-1256"%>
    
<%@page 
import="org.apache.jena.query.*" 
import="org.semanticweb.elk.owlapi.ElkReasonerFactory" 
import="org.semanticweb.owlapi.apibinding.OWLManager" 
import="org.semanticweb.owlapi.io.*"
import="org.semanticweb.owlapi.model.*"
import="org.semanticweb.owlapi.reasoner.NodeSet"
import="org.semanticweb.owlapi.reasoner.OWLReasoner"
import="org.semanticweb.owlapi.util.*"
import="org.coode.owlapi.manchesterowlsyntax.ManchesterOWLSyntaxParserFactory"
import="java.io.ByteArrayInputStream"
import ="java.io.File"
import="java."
import ="java.io.IOException"
import ="java.io.InputStream"
import ="java.lang.annotation.Annotation"
import ="java.util.List"
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1256">
<title>Insert title here</title>
</head>
<body>

<%

final String outOnt = "/home/mona/Documents/OntoProject/RDF2OWL/data/testOnt.owl";
final String goOnt = "/home/mona/Documents/OntoProject/RDF2OWL/data/go.owl";
//final String ncbiOnt = "/home/mona/Documents/OntoProject/RDF2OWL/data/ncbitaxon.owl";
final OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
final OWLOntology ontology = manager.createOntology();
final OWLDataFactory factory = manager.getOWLDataFactory();
manager.loadOntologyFromOntologyDocument(IRI.create("file:"+goOnt));
// /manager.loadOntologyFromOntologyDocument(IRI.create("file:"+ncbiOnt));

final OWLParser parser =  new ManchesterOWLSyntaxParserFactory().createParser( manager );
OWLOntologyMerger merger = new OWLOntologyMerger(manager);

//final OWLOntology new_ontology = merger.createMergedOntology(manager,IRI.create("http://aber-owl.net/RDF2OWL.owl"));


//SPARQ Query
String  sparqlQuery = "PREFIX GO: <http://purl.uniprot.org/go/>\n" +
        "PREFIX taxon:<http://purl.uniprot.org/taxonomy/>\n" +
        "PREFIX up: <http://purl.uniprot.org/core/>\n" +
        "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
        "SELECT DISTINCT ?protein ?ontid WHERE {\n" +
        "?protein up:classifiedWith ?ontid .\n" +
        " FILTER regex(str(?ontid),\"GO+\")} LIMIT 10\n";

ParsePattern pt = new ParsePattern(sparqlQuery, "SomePatten", "http://sparql.uniprot.org/");

Query query = QueryFactory.create();
QueryExecution queryExec = QueryExecutionFactory.sparqlService(pt.getSparqlEndpoint(),query);
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

    try (final InputStream in = new ByteArrayInputStream(input1.getBytes())) {
        parser.parse(new StreamDocumentSource(in), ontology);
    }
}

//System.out.print(ResultSetFormatter.asText(results,query));


System.out.println( "All axioms:" );
for ( final OWLAxiom axiom : ontology.getAxioms() ) {
    System.out.println( axiom );
}



queryExec.close();




final OWLOntology new_ontology = merger.createMergedOntology(manager,IRI.create("http://aber-owl.net/RDF2OWL.owl"));

//test some methods
ElkReasonerFactory elkReasonerFact = new ElkReasonerFactory();
OWLReasoner elkReasoner = elkReasonerFact.createReasoner(ontology);
OWLClass testClass = factory.getOWLClass(IRI.create("C0948008"));
NodeSet<OWLClass> subClasses = elkReasoner.getSubClasses(testClass, false);
System.out.println("Subclasses are: "+subClasses.toString());
System.out.println("Logical axioms count: "+new_ontology.getLogicalAxiomCount());
System.out.println("all Axioms count: "+new_ontology.getAxiomCount());



// save ontology
File saved_file = new File(outOnt);
OWLOntologyFormat format = manager.getOntologyFormat(new_ontology);
OWLXMLOntologyFormat owlxmlFormat = new OWLXMLOntologyFormat();
if (format.isPrefixOWLOntologyFormat()){
    owlxmlFormat.copyPrefixesFrom(format.asPrefixOWLOntologyFormat());
}

manager.saveOntology(new_ontology,owlxmlFormat,IRI.create(saved_file.toURI()));


%>

</body>
</html>