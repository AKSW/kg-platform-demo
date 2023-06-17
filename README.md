# KG Platform Tools


## Protégé

Go to https://github.com/protegeproject/protege-distribution/releases

Dowload the version for your system

(Edit Ontology)

## Git

Version control system, e.g. https://github.com/, https://gitlab.com, https://git-scm.com/


## Java

Check your Java version:

```bash
java -version
```

If needed, Java can be downloaded from https://adoptium.net/temurin/releases/


## Docker

Container solution, https://docs.docker.com/engine/install/  (Windows/macOS commercial)

### Docker compose

Putting together multiple containers. To start all services in this demo with Docker compose:

```bash
make
touch _ontologies_for_reasoner.ttl
docker compose up
```


## Widoco

Go to https://github.com/dgarijo/Widoco/releases

Download the version for your Java

Generate Ontology documentation:

```bash
java -jar widoco-1.4.19-jar-with-dependencies_JDK-17.jar \
  -ontFile ontology/world-port-index.ttl \
  -lang en \
  -getOntologyMetadata -rewriteAll \
  -webVowl \
  -includeAnnotationProperties \
  -noPlaceHolderText \
  -outFolder ontology_docs/world-port-index/
```


View Ontology documentation:

```bash
python3 -m http.server -d ontology_docs/world-port-index/
```

With a Docker image:

```bash
docker run --rm \
  -p 8000:3000 \
  -v $PWD/ontology_docs/:/home/static \
  -v /dev/null:/home/static/httpd.conf:ro \
  --init \
  lipanski/docker-static-website
```

Open http://0.0.0.0:8000/world-port-index/index-en.html


The step of publishing the ontology and documentation under the
"right" domain is more involved, first you need to have the domain
(one possibility is to use the https://w3id.org/ redirect service and
Github pages)


## RdfProcessingToolkit

Apache Jena based RDF/SPARQL query tool

Get it at https://github.com/SmartDataAnalytics/RdfProcessingToolkit/releases


## csvlook

Part of csvkit, https://csvkit.readthedocs.io (requires Python)

Create a Markdown table of the dataset catalogue:

```bash
rpt integrate \
  data-catalogue/cat.ttl \
  data-catalogue/instantiate.rq \
  data-catalogue-table-short.rq \
  --out-format=csv \
  | csvlook \
  > data-catalogue.md
```

Paste it on https://demo.hedgedoc.org


## RML

A (complex) standard for mapping tables to RDF, see https://rml.io/


## Tarql & Javascript

A simple standard to run SPARQL queries on a single CSV file, see http://tarql.github.io/

Run the demo mapping:

```bash
cd tarql-demo
rpt sansa tarql mapping.tarql data.csv --out-file=data.ttl
```

Or with the jar file:

```bash
../rpt-wrapper.sh rpt.jar \
    sansa tarql mapping.tarql data.csv --out-file=data.ttl
```


## GeoJSON

Download the dataset ADM0 GeoJSON from https://www.geoboundaries.org/downloadCGAZ.html and put it into the geojson-demo folder

```bash
cd geojson-demo
rpt integrate mapping.rq --out-file=boundaries_adm0.ttl
```


Parallel processing the data requires preprocessing the JSON with `jj` (https://github.com/tidwall/jj/releases)

(convert GeoJSON file into JSON-Lines with 1 feature per line:)
```bash
jj -lun \
  -i geoBoundariesCGAZ_ADM0.geojson \
  -o geoBoundariesCGAZ_ADM0.jsonl \
  features
```


## Jena Fuseki

SPARQL server.

Original version: https://jena.apache.org/download/index.cgi

Custom version with GeoSPARQL preconfigured available in Docker:

```bash
mkdir -p fuseki-volume
touch _ontologies_for_reasoner.ttl
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $PWD/fuseki-volume:/data \
  -p 3030:3030 \
  --init \
  aksw/fuseki-coypu
```


- Add data on http://0.0.0.0:3030, e.g. load the `boundaries_adm0.ttl` in the geods

- **Restart Fuseki**

- (Recompute spatial index if it already exists:)

```bash
curl \
  -X POST \
  'http://0.0.0.0:3030/geods/spatial?graph=union&commit'
```


- Run geo search: https://api.triplydb.com/s/clI4Nx5aU

```sparql
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX geo: <http://www.opengis.net/ont/geosparql#>
PREFIX geof: <http://www.opengis.net/def/function/geosparql/>

SELECT ?feature ?geomLitSimple ?myPoint ?myPointColor {
  VALUES (?myPoint ?myPointColor) {
    ("Point(4.895168 52.370216)"^^geo:wktLiteral "red")
    ("Point(12.360103 51.340199)"^^geo:wktLiteral "orange")
  }
  ?geo geo:sfContains ?myPoint ;
       geo:asWKT ?geomLit .
  ?feature geo:hasGeometry ?geo .
  bind(geof:simplifyDp(?geomLit, "0.01"^^xsd:double, true)
       as ?geomLitSimple) . }
```

- Automatic Geo-visualisation available on https://yasgui.triply.cc/


Load some ports data from the CoyPu project

```sparql
insert { ?s ?p ?o }
where { service <https://skynet.coypu.org/ports>
        { ?s ?p ?o }
      }
```


## Linked Data Viewer

The data viewer shows a resource-centric view of RDF resources (all statements about a subject)

Start it with Docker:

```bash
docker run --rm \
  -p 8001:80 \
  -e ENDPOINT_URL=http://localhost:3030/geods \
  --init \
  aksw/ldv
```

Open http://localhost:8001/*?http://example.org/country/DEU


Ideally, this would be used to provide dereferenceable IRIs. For that,
your IRIs need to be on a domain you have control of and where you can
run LDV (you could make all your IRIs start with
http://localhost:8001/ ...)


Add the port ontology to the reasoner ontology document:

```bash
cat ontology/world-port-index.ttl \
  >> _ontologies_for_reasoner.ttl
```

Restart Fuseki to test the RDFS inferencer:
http://localhost:8001/*?https://data.coypu.org/infrastructure/port/DEEME
(the River port and Tide gates port should be inferred now)


Add some owl:sameAs links to the dataset to test the sameAs inferencer

```sparql
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX coydata: <https://data.coypu.org/>
PREFIX p: <http://example.org/schema#>

insert { ?s owl:sameAs ?z }
where {
  ?s p:iso3Code ?code .
  bind(iri(concat(str(coydata:), "country/", ?code)) as ?z)
  filter exists { [] ?p ?z }
}
```

http://localhost:8001/*?https://data.coypu.org/country/DEU (the
boundary map should be inferred now)


## Ontodia Graph Explorer

Start it with Docker:

```bash
docker run --rm \
  -p 8002:80 \
  -e ENDPOINT_URL=http://localhost:3030/geods \
  -e LUCENE_SEARCH=no \
  aksw/ontodia
```

You can interactively explore the graph: http://localhost:8002/#!5x50Q-AkwfTJ7gqZrw2TqUCLWWHM0Rs-r-FT27RHodI


To fill in the Ontology tree on the left, upload the ontology file(s) into the dataset


## More JenaX demos

- Graph Overview + Caching

  https://api.triplydb.com/s/sncOEtZ57
  https://api.triplydb.com/s/yx0-tuRqF

- GADM + FullText Search

  https://api.triplydb.com/s/QCUAAsogz

- Clustering with DBSCAN

  https://api.triplydb.com/s/Luvwnii3l


- Elbe Rail Network

  https://api.triplydb.com/s/c8s-d0FfU

- Global Disaster Alert and Coordination System (GDACS)

  https://api.triplydb.com/s/zsYT5zkEp

- Copernicus Emergency Management System

  https://api.triplydb.com/s/MuKNy_VIe
