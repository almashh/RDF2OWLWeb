package sa.edu.kaust;

import org.apache.jena.base.Sys;
import org.apache.jena.query.*;
import org.apache.jena.sparql.SystemARQ;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.expression.OWLEntityChecker;
import org.semanticweb.owlapi.expression.ShortFormEntityChecker;
import org.semanticweb.owlapi.model.*;
import org.semanticweb.owlapi.util.OWLOntologyMerger;
import org.semanticweb.owlapi.util.mansyntax.ManchesterOWLSyntaxParser;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class RDF2OWL {
	
	    final static String goOnt = "/home/mona/Documents/OntologyProject/MyRDF2OWL/data/go.owl";
	    final static String ncbiOnt = "/home/mona/Documents/OntologyProject/MyRDF2OWL/data/ncbitaxon.owl";
	    final static String mergedOnt = "/home/mona/Documents/OntologyProject/MyRDF2OWL/data/mergedOnt.owl";

	    final static OWLDataFactory dataFactory = OWLManager.getOWLDataFactory();
	    final static OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
	    
	    private List<ResultSet> SparqlResults = new ArrayList<ResultSet>() ;
		public RDF2OWL() {
			
		}
		
		
	    
	    


}
