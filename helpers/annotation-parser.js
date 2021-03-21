/*The Plan-
1. use AnnParser object to extract and format annoation data from vcml Object
2. use object augmentation to add reformatted data to correct section of vcml
3. pass object onto model.hbs like is already being done
3. change model.hbs to use this instead of main.js for annotations
*/

//classes to correctly format annotaiton data
class Name {
  constructor(name) {
    this.name = name
  }
}

class VCMLElement {
  constructor(name, freetext) {
    this.$ = new Name(name);
    this._ = freetext;
  }
}

class Url {
  constructor(name, link = '') {
    this.$ = new Name(name);
    this._ = link;
  }
}

class ModelWrapper {
  constructor(name, text, urls) {
    this.$ = new Name(name);
    this.math = [];
    this.text = text;
    this.url = urls;
  }
}

class BioModel {
  constructor(biomodel) {
    this.BioModel = biomodel
  }
}

//todo:
//add capacity for more than 1 anno and urls
//fix functionality for complex models like "Initial_events_EGFR_signaling"
//remove try catch block

//class to process annotations and urls from vcml
class AnnParser {

  constructor(vcml) {
    this.vcmlObj = vcml;
    this.uriBinds = this.vcmlObj.vcml.BioModel[0].vcmetadata[0].uriBindingList[0].uriBinding;
    this.txtAnnos = this.vcmlObj.vcml.BioModel[0].vcmetadata[0].nonrdfAnnotationList[0].nonrdfAnnotation;
    this.annotations = new Object();

    try {
      //retrieve uri bindings
      let urls = new Object;
      for (let i = 0; i < this.uriBinds.length; i++) {
        let thisBind = this.uriBinds[i].$;
        urls[thisBind.uri] = new Url(thisBind.vcid);
      }
      let bindings = this.vcmlObj.vcml.BioModel[0].vcmetadata[0]['rdf:RDF'][0]['rdf:Description'];
      //compare binding in "uriBinding" to that in "rdf" and find matches
      for (let i = 0; i < bindings.length; i ++) {
        let binding = bindings[i]['$']['rdf:about'];
        let thisURI = bindings[i]['bqbiol:isVersionOf'][0]['rdf:Bag'][0]['rdf:_1'][0]['rdf:Description'][0]['$']['rdf:about'];
        urls[binding]._ = thisURI;
      }

      //get vcids
      for (let i = 0; i < this.txtAnnos.length; i++) {
        let vcid = this.txtAnnos[i].$.vcid;
        this.annotations[vcid] = new VCMLElement(vcid, this.txtAnnos[i].freetext[0]);
      }

      //organize data into JSON file that will be used by main.js
      let values = Object.values(this.annotations);
      this.JSONwrapper = new ModelWrapper('PLACEHOLDER', values, urls);
    } catch(err) {}
  }

  getString() {
    return (JSON.stringify(new BioModel(this.JSONwrapper)));
  }
}

//export this object to app.js
exports.AnnParser = AnnParser;
