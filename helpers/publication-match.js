const fs = require("fs");

//script for maching publications from publication API to models from normal search API
//since publications change rarley, only needs to be used occationally

//get publications
const pubRaw = fs.readFileSync('../json-data/publication-data.json');
const pubs = JSON.parse(pubRaw);

//get all models
const modelRaw = fs.readFileSync('../json-data/all-models-2021.json');
const models = JSON.parse(modelRaw);


console.log("models:", models.length);
console.log("pubs:", pubs.length);

//get matches
var matches = [];
for (let p = 0; p < pubs.length; p++) {
  let pub = pubs[p];
  let bmKeys = pub.biomodelReferences;
  for (let m = 0; m < models.length; m++) {
    let model = models[m];
    for (let b = 0; b < bmKeys.length; b++) {
      if (bmKeys[b].bmKey == model.bmKey) {
        matches.push(model);
      }
    }
  }
}

console.log('Saved', matches.length, 'published biomodels.');
fs.writeFileSync('../json-data/publications.json', JSON.stringify(matches));
