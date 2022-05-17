const fs = require("fs");

//script for maching curated API to models from normal search API
//probably needs to be changed more than publications

//get modelbricks
const modelbricksRaw = fs.readFileSync('../json-data/modelbricks.json');
const modelbricks = JSON.parse(modelbricksRaw);
console.log(modelbricks.length);

//get education models
const eduRaw = fs.readFileSync('../json-data/education.json');
const edus = JSON.parse(eduRaw);
console.log(edus.length);

//get tutorials
const tutorialsRaw = fs.readFileSync('../json-data/tutorials.json');
const tutorials = JSON.parse(tutorialsRaw);
console.log(tutorials.length);

//get matches
var matches = modelbricks.concat(edus, tutorials);

//save models
fs.writeFileSync('../json-data/curated.json', JSON.stringify(matches));
console.log('Saved', matches.length, 'curated biomodels.');
