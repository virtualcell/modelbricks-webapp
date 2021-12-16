const fs = require("fs");

//script for maching publications from publication API to models from normal search API
//since publications change rarley, only needs to be used occationally

//get publications
const pubRaw = fs.readFileSync('../json-data/publication-data.json');
const pubs = JSON.parse(pubRaw);

//get all models
const modelRaw = fs.readFileSync('../json-data/all-models-2021.json');
const models = JSON.parse(pubRaw);


//get matches
var matches = [];
for (let m = 0; m < models.length; m++) {
  let model = models[m];
  for (let p = 0; p < pubs.length; p++) {
    if (pubs[p].pubKey == model.pubKey) {
      matches.push(model);
    }
  }
}

console.log(JSON.stringify(matches));
fs.writeFileSync('../json-data/publications.json', JSON.stringify(matches));
