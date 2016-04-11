package sa.edu.kaust;

/**
 * Created by alshahmm on 2/29/16.
 */

import java.io.File;

import org.apache.jena.rdf.model.*;
import org.apache.jena.sparql.SystemARQ;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.*;
import org.semanticweb.owlapi.reasoner.*;
import org.semanticweb.owlapi.util.DefaultPrefixManager;
import org.semanticweb.elk.owlapi.*;

public class ConvertRDF {

    private static  OWLOntologyManager owlmanager;
    private  static OWLDataFactory owlfact;
    private static OWLOntology ont;
    private static OWLOntology ont1;
    private static String outDir = "/home/mona/Documents/OntoProject/RDF2OWL/data/RDFOnt.owl";
    //private static PrefixManager pm = new DefaultPrefixManager("http://www.aber-owl.net/ontologies/#");

    public void run(String[] args) {

        try{
            owlmanager = OWLManager.createOWLOntologyManager();
            owlfact = owlmanager.getOWLDataFactory();
            ont = owlmanager.createOntology(IRI.create("http://www.aber-owl.net/ontologies/RDFOnt"));

        }catch(OWLOntologyCreationException e){
            e.getMessage();
        }


        Model model = ModelFactory.createDefaultModel();
        model.read("data/model.rdf");
        //model.read("data/ex1","TURTLE");
        StmtIterator iter = model.listStatements();
        while (iter.hasNext()) {
            Statement stmt      = iter.nextStatement();
            System.out.print(stmt.toString());
            Resource subject   = stmt.getSubject();
            Property  predicate = stmt.getPredicate();
            RDFNode   object    = stmt.getObject();
            String objLabel = null;
            if (object instanceof Resource) {
                objLabel = object.toString();
            }

            String subLabel = subject.toString();
            OWLClass owlclass1 = owlfact.getOWLClass(IRI.create(subLabel));
            new ConvertRDF().createOWLDeclarationAxiom(owlclass1);
            OWLClass owlclass2 = owlfact.getOWLClass(IRI.create(objLabel));
            new ConvertRDF().createOWLDeclarationAxiom(owlclass2);
            OWLObjectProperty hasRelation = owlfact.getOWLObjectProperty(IRI.create(predicate.toString()));

            //create OWL Pattern
            OWLClassExpression hasRelationSome = owlfact.getOWLObjectSomeValuesFrom(hasRelation,owlclass2);
            OWLSubClassOfAxiom axiomPattern = owlfact.getOWLSubClassOfAxiom(owlclass1,hasRelationSome);
            owlmanager.addAxiom(ont,axiomPattern);
        }
        try {
            owlmanager.saveOntology(ont, IRI.create(new File(outDir).toURI()));
        }catch(OWLOntologyStorageException e){
            e.getMessage();
        }


        //test reasoner

        ElkReasonerFactory elkReasonerFact = new ElkReasonerFactory();
        OWLReasoner elkReasoner = elkReasonerFact.createReasoner(ont);
        OWLClass testClass = owlfact.getOWLClass(IRI.create("C0948008"));
        NodeSet<OWLClass> subClasses = elkReasoner.getSubClasses(testClass, false);
        System.out.print(subClasses.toString());
    }

    public void createOWLDeclarationAxiom(OWLClass owlclass){

        OWLDeclarationAxiom declarationAxiom = owlfact.getOWLDeclarationAxiom(owlclass);
        owlmanager.addAxiom(ont, declarationAxiom);
    }
}
