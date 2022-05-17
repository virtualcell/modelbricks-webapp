const fs = require("fs");

//makes two files:
//1. list of all published biomodels
//2. map of published bmkeys to all publicatation meta data (doi, pubmedID)
//since publications change rarley, only needs to be used occationally

//get publications
const pubRaw = fs.readFileSync('../json-data/publication-data.json');
const pubs = JSON.parse(pubRaw);

//get all models
const modelRaw = fs.readFileSync('../json-data/all-models-2021.json');
const models = JSON.parse(modelRaw);


console.log("models:", models.length);
console.log("pubs:", pubs.length);

//get matches and map
var matches = [];
var map = {};

for (let p = 0; p < pubs.length; p++) {
  let pub = pubs[p];
  let bmKeys = pub.biomodelReferences;
  for (let m = 0; m < models.length; m++) {
    let model = models[m];
    for (let b = 0; b < bmKeys.length; b++) {
      if (bmKeys[b].bmKey == model.bmKey) {
        model['pubmedid'] = pub['pubmedid'];
        matches.push(model);
        //get meta data for map
        let data = {
          "name": model.name,
          "bmkey": model.bmKey,
          "title": pub.title,
          "year": pub.year,
          "authors": pub.authors,
          "citation": pub.citation,
          "date": pub.date,
          "doi": pub.doi,
          "pubmedid": pub.pubmedid,
        };
        map[model.name] = data;
      }
    }
  }
}

fs.writeFileSync('../json-data/pub-map.json', JSON.stringify(map));
fs.writeFileSync('../json-data/publications.json', JSON.stringify(matches));
console.log('Saved', matches.length, 'published biomodels.');
