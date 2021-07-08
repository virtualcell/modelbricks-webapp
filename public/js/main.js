fetch("/json/annotations.json")
  .then((response) => response.json())
  .then((json) => {
    //console.log('json annos:', json.BioModel);
    return (json)})
  .then((json) => {

    // getting global publications and UID's
    for (i in json.BioModel.url) {

      //define link, name, and qual
      var link = json.BioModel.url[i]._;
      //fix formatting for links
      link = link.replace('obo.go:', 'go/');
      link = link.replace('sbo:', 'sbo/');
      link = link.replace('%3A', ':');
      let prefixes = ['miriam:obo.go', 'miriam'];
      for (p in prefixes) {
        let pre = prefixes[p];
        if (link.includes(pre)) {
          var indexToSlice = link.indexOf(pre) + pre.length + 1;
          link = 'http://identifiers.org/' + link.slice(indexToSlice, link.length);
        }
      }

      var name = json.BioModel.url[i].$.name;
      name = name.replace('%3', ':');

      var qual = json.BioModel.url[i].qualifier;

      //map vcml name to html element name
      let nameMap = new Object();
      nameMap["BioModel"] = 'globalPublications';
      nameMap["ReactionStep"] = "reactionUID-!";
      nameMap["Structure"] = "structureUID-!";
      nameMap["MolecularType"] = "moleculesUID-!";
      nameMap["Species"] = "speciesUID-!";
      nameMap["RbmObservable"] = "observableUID-!";
      nameMap["ModelParameter"] = "parameterUID-!";

      let vcmlNames = Object.keys(nameMap);

      for (i in vcmlNames) {
        vcmlName = vcmlNames[i];
        if (name.includes(vcmlName)) {

          //get the html element
          let indexToSlice = name.indexOf("(") + 1;
          let length = name.indexOf(")");
          let idenitifier = name.slice(indexToSlice, length);
          let elementName = nameMap[vcmlName];
          elementName = elementName.replace('!', idenitifier);
          let element = document.getElementById(elementName);

          //add annotation
          indexToSlice = link.lastIndexOf("identifiers.org/") + 16;
          let linkId = link.slice(indexToSlice, link.length);
          if (element != null) {
            element.innerHTML += `
        <p class="p-UID">${qual} <a href="${link}">${linkId}</a>
        </p>
        `;
          }

          break;
        }
      }
    }

    // UID COMPLETED ---------------------->

    // getting Text Annotation

    for (i in json.BioModel.text) {
      var text = json.BioModel.text[i]._;
      var name = json.BioModel.text[i].$.name;

      // global annotations
      let globalAnnotations = document.getElementById("globalAnnotations");
      if (name.includes("BioModel")) {
        if (globalAnnotations != null) {
          globalAnnotations.innerHTML += `
            <p class="textAnnotationP">${text}</p>
            `;
        }
      }

      // for Reactions
      if (name.includes("ReactionStep")) {
        var indexToSlice = name.indexOf("(") + 1;
        var length = name.indexOf(")");
        var elementName = name.slice(indexToSlice, length);

        let annotationDiv = document.getElementById(
          `reactionTA-${elementName}`
        );
        if (annotationDiv != null) {
          annotationDiv.innerHTML += `
        <p class="textAnnotationP">${text}</p>
        `;
        }
      }

      // for Structures
      if (name.includes("Structure")) {
        var indexToSlice = name.indexOf("(") + 1;
        var length = name.indexOf(")");
        var elementName = name.slice(indexToSlice, length);

        let annotationDiv = document.getElementById(
          `structureTA-${elementName}`
        );
        if (annotationDiv != null) {
          annotationDiv.innerHTML += `
        <p class="textAnnotationP">${text}</p>
        `;
        }
      }

      // for Molecules
      if (name.includes("MolecularType")) {
        var indexToSlice = name.indexOf("(") + 1;
        var length = name.indexOf(")");
        var elementName = name.slice(indexToSlice, length);

        let annotationDiv = document.getElementById(
          `moleculeTA-${elementName}`
        );
        if (annotationDiv != null) {
          annotationDiv.innerHTML += `
        <p class="textAnnotationP">${text}</p>
        `;
        }
      }

      // for species
      if (name.includes("Species")) {
        var indexToSlice = name.indexOf("(") + 1;
        var length = name.indexOf(")");
        var elementName = name.slice(indexToSlice, length);

        let annotationDiv = document.getElementById(`speciesTA-${elementName}`);
        if (annotationDiv != null) {
          annotationDiv.innerHTML += `
        <p class="textAnnotationP">${text}</p>
        `;
        }
      }

      // for observables
      if (name.includes("RbmObservable")) {
        var indexToSlice = name.indexOf("(") + 1;
        var length = name.indexOf(")");
        var elementName = name.slice(indexToSlice, length);

        let annotationDiv = document.getElementById(
          `observableTA-${elementName}`
        );
        if (annotationDiv != null) {
          annotationDiv.innerHTML += `
        <p class="textAnnotationP">${text}</p>
        `;
        }
      }

      // for Parameters
      if (name.includes("ModelParameter")) {
        var indexToSlice = name.indexOf("(") + 1;
        var length = name.indexOf(")");
        var elementName = name.slice(indexToSlice, length);

        let annotationDiv = document.getElementById(
          `parameterTA-${elementName}`
        );
        if (annotationDiv != null) {
          annotationDiv.innerHTML += `
        <p class="textAnnotationP">${text}</p>
        `;
        }
      }
    }

    // Math Type -------------------------->

    for (i in json.BioModel.math) {
      var text = json.BioModel.math[i]._;
      var name = json.BioModel.math[i].$.name;
      let mathType = document.getElementById("mathType");
      if (mathType != null) {
        mathType.innerHTML += `
            <p>${text}</p>
            `;
      }
    }
  }
);
