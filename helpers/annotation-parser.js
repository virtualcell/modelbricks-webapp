/*The Plan-
1. use AnnParser object to extract and format annoation data from vcml Object
2. pass vcml object into main.js through json file
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
    this.vcid = name;
  }
}

class ModelWrapper {
  constructor(name, text, urls) {
    this.$ = new Name(name);
    this.math = [];
    this.text = text;
    this.url = urls;
    this.qualifier = '';
  }
}

class BioModel {
  constructor(biomodel) {
    this.BioModel = biomodel
  }
}

//todo:
//some rdf bindings don't map to anything, I need to find out why
//multiple links mapped to one element still arent processed correctly
//^ because im only looking at multiple uris in a bag
//stop using annotations.json, use different files for each model

//class to process annotations and urls from vcml
class AnnParser {

  constructor(vcml) {
    this.vcmlObj = vcml;
    this.uriBinds = this.vcmlObj.vcml.BioModel[0].vcmetadata[0].uriBindingList[0].uriBinding;
    this.txtAnnos = this.vcmlObj.vcml.BioModel[0].vcmetadata[0].nonrdfAnnotationList[0].nonrdfAnnotation;
    this.annotations = new Object();

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
      let thisRDF = bindings[i];
      //get all the keys, which are <rdf:qualifier> elements in vcml
      let RDFkeys = Object.keys(thisRDF);

      for (let i = 0; i < RDFkeys.length; i++) {
        //some rdf bindings don't map to anything, I need to find out why
        if (binding in urls) {
          let URLObj = urls[binding];
          let vcid = URLObj.vcid;

          //make sure we get keys we want
          if (RDFkeys[i].includes('bqbiol') || RDFkeys[i].includes('bqmodel')) {

            //each key mapping can have >1 rdf:bag
            let keyMap = thisRDF[RDFkeys[i]];
            for (let j = 0; j < keyMap.length; j++) {

              //each rdf:Bag obj can have >1 key
              let rdfBag = keyMap[j]['rdf:Bag'][0];
              let bagKeys = Object.keys(rdfBag);
              for (let u = 0; u < bagKeys.length; u++) {
                if (bagKeys[u].includes('rdf:')) {
                  let thisURI = rdfBag[bagKeys[u]][0]['rdf:Description'][0]['$']['rdf:about'];

                  //push all the next keys as new url objects onto urls
                  let key = '$' + j.toString() + u.toString() + i.toString() + vcid;
                  urls[key] = new Url(vcid);
                  urls[key]._ = thisURI;
                  urls[key].qualifier = '(' + RDFkeys[i].replace(':', ') ');
                  urls[key].qualifier = urls[key].qualifier.replace('bqbiol', 'bio');
                  urls[key].qualifier = urls[key].qualifier.replace('bqmodel', 'model');
                }
              }
            }
          }
        }
      }
    }
    console.log(urls);

    //get vcids
    for (let i = 0; i < this.txtAnnos.length; i++) {
      let vcid = this.txtAnnos[i].$.vcid;
      try {
        this.annotations[vcid] = new VCMLElement(vcid, this.txtAnnos[i].freetext[0]);
      } catch{}
    }

    //organize data into JSON file that will be used by main.js
    let values = Object.values(this.annotations);
    this.JSONwrapper = new ModelWrapper('PLACEHOLDER', values, urls);
  }

  getString() {
    return (JSON.stringify(new BioModel(this.JSONwrapper)));
  }

  getName() {
    //get name of model
    let temp = this.vcmlObj.vcml.BioModel[0].$.Name;
    let tempIndex = temp.indexOf('::');
    this.name = temp.slice(tempIndex + 2, temp.length);

    return (this.name);
  }
}

//export this object to app.js
exports.AnnParser = AnnParser;
