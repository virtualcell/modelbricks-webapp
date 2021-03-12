const ss = require("./split-string.js");

class VCMLElement {
  constructor(label, freetext) {
    this.label = label;
    this.freetext = freetext;
  }
}

//todo:
//text annos are assigned randomly, but they should be assigned to their element
//add capacity to link text anno and UIDs
class AnnParser {

  //annotations are given as html, so they must be stripped
  stripHTML(html) {
    let end = html.indexOf('</p>');
    let temp = end;
    while (html[temp] != '>') {
      temp --;
    }
    return (html.slice(temp + 1, end));
  }

  constructor(vcml) {
    //this implementation changes orriginal vcml parameter through pointers
    this.vcmlObj = vcml;
    this.uriBinds = this.vcmlObj.vcml.BioModel[0].vcmetadata[0].uriBindingList[0].uriBinding;
    this.txtAnnos = this.vcmlObj.vcml.BioModel[0].vcmetadata[0].nonrdfAnnotationList[0].nonrdfAnnotation;

    //unfortunitely these must be handled seperatley
    this.reacts = new Object();
    this.structs = new Object();
    this.species = new Object();
    this.molecules = new Object();
    this.obsers = new Object();
    this.diagram = new Object();

    //organize annotaitons into temporary objects
    for (let i = 0; i < this.txtAnnos.length; i++) {
      let vcid = this.txtAnnos[i].$.vcid;
      //console.log(this.txtAnnos[i].freetext[0]);
      let textAnno = this.stripHTML(this.txtAnnos[i].freetext[0]);
      let temp = ss(vcid, '(');
      let section = temp[0];
      let identifier = temp[1].slice(0, temp[1].length - 1);
      //molecules
      if (section == 'MolecularType') {
        this.molecules[vcid] = new VCMLElement(identifier, textAnno.trim());
      }
    }

    //add the annotations into vcml object
    let element = this.vcmlObj.vcml.BioModel[0].Model[0].RbmModelContainer[0].MolecularTypeList[0].MolecularType;
    let values = Object.values(this.molecules);
    for (let i = 0; i < element.length; i++) {
      element[i].annotations = [values[i]];
    }

    console.log(this.vcmlObj.vcml.BioModel[0].Model[0].RbmModelContainer[0].MolecularTypeList[0].MolecularType[0].annotations);
  }
}


exports.AnnParser = AnnParser;
exports.VCMLElement = VCMLElement;

/*The Plan-
1. use AnnParser object to extract and format annoation data from vcml Object
2. use object augmentation to add reformatted data to correct section of vcml
3. pass object onto model.hbs like is already being done
3. change model.hbs to use this instead of main.js for annotations
*/
