/**
 * 
 */


function example1()
      {
         
         var query= 	"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n\
						PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n\
						PREFIX owl: <http://www.w3.org/2002/07/owl#>\n\
						PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n\
						PREFIX dcterms: <http://purl.org/dc/terms/>\n\
						PREFIX foaf: <http://xmlns.com/foaf/0.1/>\n\
						PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n\
						PREFIX void: <http://rdfs.org/ns/void#>\n\
						PREFIX sio: <http://semanticscience.org/resource/>\n\
						PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>\n\
						PREFIX up: <http://purl.uniprot.org/core/>\n\
						PREFIX dcat: <http://www.w3.org/ns/dcat#>\n\
						PREFIX dctypes: <http://purl.org/dc/dcmitype/>\n\
						PREFIX wi: <http://http://purl.org/ontology/wi/core#>\n\
						PREFIX eco: <http://http://purl.obolibrary.org/obo/eco.owl#>\n\
						PREFIX prov: <http://http://http://www.w3.org/ns/prov#>\n\
						PREFIX pav: <http://http://http://purl.org/pav/>\n\
						PREFIX obo: <http://purl.obolibrary.org/obo/>\n\
						PREFIX wp: <http://vocabularies.wikipathways.org/wp#>\n\
						SELECT DISTINCT ?gene ?disease  WHERE {\n\
						\n\
						?gda sio:SIO_000628 ?disease,?gene .\n\
						?gene rdf:type ncit:C16612 .\n\
						?disease dcterms:title ?diseaseName . FILTER (str(?diseaseName) = \"Obesity\")\n\
						?disease rdf:type ncit:C7057 } limit 1000";
         document.getElementById('sparqlQuery').value = query;
         document.getElementById('relPattern').value= "has-causation some";
         document.getElementById('sparqlEndpoint').value='http://rdf.disgenet.org/sparql/';
      }


function example2()
      {
	
	     var query="PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n\
					PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n\
					PREFIX owl: <http://www.w3.org/2002/07/owl#>\n\
					PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n\
					PREFIX dcterms: <http://purl.org/dc/terms/>\n\
					PREFIX foaf: <http://xmlns.com/foaf/0.1/>\n\
					PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n\
					PREFIX void: <http://rdfs.org/ns/void#>\n\
					PREFIX sio: <http://semanticscience.org/resource/>\n\
					PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>\n\
					PREFIX up: <http://purl.uniprot.org/core/>\n\
					PREFIX dcat: <http://www.w3.org/ns/dcat#>\n\
					PREFIX dctypes: <http://purl.org/dc/dcmitype/>\n\
					PREFIX wi: <http://http://purl.org/ontology/wi/core#>\n\
					PREFIX eco: <http://http://purl.obolibrary.org/obo/eco.owl#>\n\
					PREFIX prov: <http://http://http://www.w3.org/ns/prov#>\n\
					PREFIX pav: <http://http://http://purl.org/pav/>\n\
					PREFIX obo: <http://purl.obolibrary.org/obo/>\n\
					PREFIX wp: <http://vocabularies.wikipathways.org/wp#>\n\
					\n\
					SELECT DISTINCT ?disease ?phenotype WHERE {\n\
					?gda sio:SIO_000628 ?disease,?gene .\n\
					?disease rdf:type ncit:C7057 .\n\
					?disease skos:exactMatch ?test .\n\
					?test sio:SIO_001279 ?phenotype .\n\
					?disease dcterms:title ?diseaseName . FILTER (str(?diseaseName) = \"Obesity\")\n\
					} limit 1000"
         document.getElementById('sparqlQuery').value = query;
         document.getElementById('relPattern').value= "has-phenotype some";
         document.getElementById('sparqlEndpoint').value='http://rdf.disgenet.org/sparql/';
      }

