const fs = require("fs");
const express = require("express");
const app = express();
const exphbs = require("express-handlebars");
const handlebars = require("handlebars");
const axios = require("axios");
const path = require("path");
const xml2js = require("xml2js");
const fetch = require("node-fetch");
const aPrs = require("./helpers/annotation-parser.js");
const PORT = process.env.PORT || 3000;

var indexRouter = require("./routes/index");

//todo:
//fix column arrow search in biomodel name

app.use(express.json());

//read publications and curated file and store for use in curated list
//publications
var pubRaw = fs.readFileSync('json-data/publications.json');
const pubs = JSON.parse(pubRaw);
delete pubRaw;
//curated
var curatedRaw = fs.readFileSync('json-data/curated.json');
const curated = JSON.parse(curatedRaw);
delete curatedRaw;
//education
var educationRaw = fs.readFileSync('json-data/education.json');
const education = JSON.parse(educationRaw);
delete educationRaw;
//map
var mapRaw = fs.readFileSync('json-data/pub-map.json');
const pubMap = JSON.parse(mapRaw);
delete mapRaw;

// view engine setup
const hbs = exphbs.create({
  extname: "hbs",
  defaultLayout: "main",

  // create custom helper
  helpers: {
    //the pubmed solutiuon implemented assumes any 8 digit num in model name is a pubmed num
    getPubmedModelNum: function(name) {
      try {
        let lastIndex = name.indexOf("::") - 1;
        if (!lastIndex || lastIndex < 0) {
          throw 'No Pubmed Model Num';
        }
        let index = lastIndex
        //while char is not number
        while (!isNaN(name.charAt(index))) {
          index --;
        }
        if (name.slice(index - 2, index + 1) != '_MB') {
          throw 'No Pubmed Model Num';
        }
        return name.slice(index + 1, lastIndex + 1);
      } catch (e) {
        return "";
      }
    },
    getPubmedID: function(name, alternateID) {
      try {
        if (alternateID) {
          return alternateID;
        } else {
          let firstNum = 0;
          //while char is not number
          while (isNaN(name.charAt(firstNum))) {
            firstNum ++;
            if (firstNum > 10000) {
              throw 'infinite loop in getPubmedID';
            }
          }
          let lastNum = firstNum;
          //while char is number
          while (!isNaN(name.charAt(lastNum))) {
            lastNum ++;
            if (lastNum > 10000) {
              throw 'infinite loop in getPubmedID';
            }
          }
          let pubmedID = name.slice(firstNum, lastNum);
          return pubmedID;
        }
      } catch (e) {
        return false;
      }
    },
    getPubmedLink: function(pubmedID) {
      try {
        if (!pubmedID || pubmedID.length != 8) {
          throw 'undefined pubmed id';
        }
        let link = "https://pubmed.ncbi.nlm.nih.gov/" + pubmedID + '/';
        return link;
      } catch (e) {
        return false;
      }
    },
    trimString: function (passedString) {
      if (passedString && passedString.includes("::")) {
        var indexToSlice = passedString.indexOf("::") + 2;
        var length = passedString.length;
        var theString = passedString.slice(indexToSlice, length);
        return theString;
      } else {
        return passedString;
      }
    },
    trimVcid: function (passedString) {
      if (passedString.includes("(")) {
        var indexToSlice = passedString.indexOf("(") + 1;
        var length = passedString.length - 1;
        var theString = passedString.slice(indexToSlice, length);
        return theString;
      } else {
        return passedString;
      }
    },
    toDate: function (timeStamp) {
      let date = new Date(timeStamp);
      let year = date.getYear().toString();
      year = year.substring(1, 3);
      let month = date.getMonth();
      month += 1;
      month = month.toString();
      if(month.length === 1) {
        month = "0" + month;
      }
      let day = date.getDate().toString();
      if(day.length === 1) {
        day = "0" + day;
      }
      return (month + "/" + day + "/" + year);
    },
    convertSpace: function (s) {
      //convert spaces to %20 for use in URLs
      return s.replace(/\s/g, '%20');
    },
    convertTrigger: function (eventObj) {
      let params = eventObj.Parameter;
      let timeList = 'at times: [';
      let observable = 'Error';

      //loop through params
      for (let i = 0; i < params.length; i++) {
        let param = params[i];
        let name = param.$.Name;
        let val = param._
        if (name == 'triggerTime') {
          return('at time ' + val);
        } else if (name == 'threshold') {
          return('when ' + observable + ' is above/below ' + val);
        } else if (name == 'observable') {
          observable = val;
        } else if (name == 'triggerFunction') {
          return('on condition: ' + val);
        } else if (param.$.Role == 'TimeListItem') {
          timeList += val + ',';
        }
      }

      //only reach here for time list
      timeList = timeList.slice(0, timeList.length - 1) + ']';
      return timeList;
    },
    nullCheck: function (inputString) {
      var string = inputString;
      if (string) {
        return string;
      } else {
        string = "Null";
        return string;
      }
    },
    getSpeciesStructure: function (compList, name) {
      for (let i = 0; i < compList.length; i++) {
        let elm = compList[i].$;
        let elmName = elm.Name;
        if (name == elmName) {
          return elm.Structure;
        }
      }
    },
    initUnits: function (conc, count, volUnit, lumpUnit) {
      if (conc) {
        let pair = volUnit.split('.');
        return pair[0];
      } else if (count){
        return lumpUnit;
      } else {
        return 'unknown unit';
      }
    },
    shortString: function (s, length, dots=false) {
      if (dots) {
        if (s) {
          if (s.length > length - 3) {
            return s.slice(0, length - 3) + '...';
          } else {
            return s.slice(0, length) + '...';
          }
        } else {
          return "";
        }
      } else {
        if (s) {
          if (s.length > length - 3) {
            return s.slice(0, length - 3) + '...';
          } else {
            return s.slice(0, length);
          }
        } else {
          return "";
        }
      }
    },
    isListNotNull: function (list) {
      return !!list.length;
    },
    listIndex: function (list, index) {
      return list[index];
    },
    and: function (a, b) {
      let result = a && b;
      if (!result) {
        return false;
      } else {
        return true;
      }
    },
    or: function (a, b) {
      return (a || b);
    },
    not: function(a) {
      return !a;
    },
    isNull: function (s) {
      return (s == null);
    },
    add: function (a, b) {
      return (parseInt(a) + parseInt(b));
    },
    sub: function (a, b) {
      return (parseInt(a) - parseInt(b));
    },
    greater: function (a, b) {
      return (a > b);
    },
    eq: function (a, b) {
      return (a == b);
    },
    includes: function (a, b) {
      return (a.includes(b));
    }
  },
});

//function used in curated list to generate json model list
async function getModelList(termMap) {
  //handle special case for publucations
  if (termMap['category'] == 'publications') {
    //get index range
    let page = termMap['page'];
    let modelsPerPage = termMap['maxModels'];
    let indexStart = (page - 1) * modelsPerPage;
    let indexEnd = page * modelsPerPage;
    //idk why pubs needs to be wrapped in async func, but it does
    const func = async ()=> {return pubs.slice(indexStart, indexEnd);};
    var json = await func();
  } else if (termMap['category'] == 'curated') {
    //get index range
    let page = termMap['page'];
    let modelsPerPage = termMap['maxModels'];
    let indexStart = (page - 1) * modelsPerPage;
    let indexEnd = page * modelsPerPage;
    //same as pubs above
    const func = async ()=> {return curated.slice(indexStart, indexEnd);};
    var json = await func();
  } else if (termMap['category'] == 'education') {
    //get index range
    let page = termMap['page'];
    let modelsPerPage = termMap['maxModels'];
    let indexStart = (page - 1) * modelsPerPage;
    let indexEnd = page * modelsPerPage;
    //same as pubs above
    const func = async ()=> {return education.slice(indexStart, indexEnd);};
    var json = await func();
  } else {
    //calculate row var API uses
    const APIrow = termMap['page'] * termMap['maxModels'] - termMap['maxModels'] - 1;

    //create link and fetch from API
    const api_url =
      "https://vcell.cam.uchc.edu/api/v0/biomodel?bmName=" + termMap["bmName"] + "&bmId=" + termMap["bmId"] + "&category=" + termMap["category"] + "&owner=" + termMap["owner"] + "&savedLow=" + termMap["savedLow"] + "&savedHigh=" + termMap["savedHigh"] + "&startRow=" + APIrow + "&maxRows=" + termMap['maxModels'] + "&orderBy=" + termMap["orderBy"];
    const fetch_response = await fetch(api_url);
    json = await fetch_response.json();
  }
  return json;
}

//hbs + express param setup
app.engine("hbs", hbs.engine);
app.set("view engine", "hbs");

// single model page for development purposes
app.get("/curatedList/model", (req, res) => {
  var parser = new xml2js.Parser();
  fs.readFile("Biomodel_147699816.xml", (err, data) => {
    parser.parseString(data, (err, result) => {
      const data = result;
      res.render("model", {
        title: "ModelBricks - Model Page",
        data,
      });
    });
  });
});

// main pages with dynamic content starts from here
// Fetching Curated List of models from Vcel API
app.get("/curatedList/:search", async (req, res) => {
  //TODO how to get max num of pages?
  //search parameter mirror the format of API Urls except for page term
  const search = req.params.search;
  //format search string into object
  var terms = search.split("&");
  for (let i = 0; i < terms.length; i++) {
    terms[i] = terms[i].split("=");
  }
  var termMap = Object.fromEntries(terms);

  //get model list
  const json = await getModelList(termMap);

  //if there are no models in list
  let isNotEmpty = true;
  let modelsPerPage = termMap['maxModels'];
  if (json.length == 0) {
    isNotEmpty = false;
  }
  //make json string for use in filters
  let jsonString = (JSON.stringify(json));

  //replace / escape char in date param
  termMap["savedLow"] = termMap["savedLow"].replace(/%2F/g, "/");
  termMap["savedHigh"] = termMap["savedHigh"].replace(/%2F/g, "/");

  //render
  res.render("curatedList", {
    title: "ModelBricks - Curated List",
    json,
    termMap,
    isNotEmpty,
    modelsPerPage,
    jsonString,
  });
});

//advanced search page
app.get("/advancedSearch/:search", async (req, res) => {
  //search parameter mirror the format of API Urls except for page term
  const search = req.params.search;
  //format search string into object
  var terms = search.split("&");
  for (let i = 0; i < terms.length; i++) {
    terms[i] = terms[i].split("=");
  }
  var termMap = Object.fromEntries(terms);

  //some vars for startRow and maxRow terms
  const APIrow = termMap['page'] * termMap['maxModels'] - termMap['maxModels'] - 1;
  let modelsPerPage = termMap['maxModels'];

  res.render("advancedSearch", {
    title: "ModelBricks - Search",
    termMap,
    modelsPerPage,
  });
});

// Curated List offline copy for testing
app.get("/testCuratedList/:search", async (req, res) => {
  //read list json file
  var json = fs.readFileSync('json-data/offlineList.json');
  json = JSON.parse(json);

  //TODO how to get max num of pages?
  //search parameter mirror the format of API Urls except for page term
  const search = req.params.search;
  //format search string into object
  var terms = search.split("&");
  for (let i = 0; i < terms.length; i++) {
    terms[i] = terms[i].split("=");
  }
  var termMap = Object.fromEntries(terms);

  //some vars for startRow and maxRow terms
  const APIrow = termMap['page'] * termMap['maxModels'] - termMap['maxModels'] - 1;

  //const json = await fetch_response.json();

  //if page is empty
  let isNotEmpty = true;
  let modelsPerPage = termMap['maxModels'];
  if (json.length == 0) {
    isNotEmpty = false;
  }

  res.render("curatedList", {
    title: "ModelBricks - Curated List",
    json,
    termMap,
    isNotEmpty,
    modelsPerPage,
  });
});

// main Dashboard for dynamic models selected from curated list page
app.get("/curatedList/model/:name", (req, res) => {
  const api_url =
    'https://vcell.cam.uchc.edu/api/v0/biomodel/' + req.params.name + '/biomodel.vcml';
  var parser = new xml2js.Parser();
  fetch(api_url).then(function(response) {
    return response.text().then(function(text) {
      parser.parseString(text, (err, result) => {
        data = result;
        /*if (pubMap.hasOwnProperty(data.vcml.BioModel[0].Model[0].Version[0].$.KeyValue)) {
          console.log(true);
        } else {
          console.log(false);
        }*/
        let annoObj = new aPrs.AnnParser(data);
        let annoData = annoObj.getString();
        let outputOptions = annoObj.getOutputOptions();
        let geometryList = annoObj.getGeometry();
        fs.writeFileSync("./public/json/" + "annotations" + ".json", annoData);
        res.render("model", {
          title: "ModelBricks - Model Page",
          data,
          outputOptions,
          geometryList,
        });
      });
    });
  });
});

//page for offline testing
app.get("/test/:name", (req, res) => {
  var parser = new xml2js.Parser();
  fs.readFile("./files/" + req.params.name + ".vcml", (err, data) => {
    parser.parseString(data, (err, result) => {
      data = result;
      if (!data) {
        res.send('no filed named ' + req.params.name + ".vcml");
      } else {
        let annoObj = new aPrs.AnnParser(data);
        let annoData = annoObj.getString();
        let outputOptions = annoObj.getOutputOptions();
        let geometryList = annoObj.getGeometry();
        fs.writeFileSync("./public/json/" + "annotations" + ".json", annoData);
        res.render("model", {
          title: "ModelBricks - Model Page",
          data,
          outputOptions,
          geometryList,
        });
      };
    });
  });
});

// dynamic printable pages, option available on dashboard page
app.get("/curatedList/printModel/:name", (req, res) => {
  modelName = req.params.name;
  const api_url =
    'https://vcell.cam.uchc.edu/api/v0/biomodel/' + modelName + '/biomodel.vcml';
  var parser = new xml2js.Parser();
  fetch(api_url).then(function(response) {
    return response.text().then(function(text) {
      parser.parseString(text, (err, result) => {
        data = result;
        let annoObj = new aPrs.AnnParser(data);
        let annoData = annoObj.getString();
        let outputOptions = annoObj.getOutputOptions();
        let geometryList = annoObj.getGeometry();
        // generating static html pages in ./public/html
        var template = handlebars.compile(
          fs.readFileSync("./temp/modelTemplate.html", "utf8")
        );
        var generated = template({ data: data });
        fs.writeFileSync(
          "./views/" + "static_" + req.params.name + ".hbs",
          generated,
          "utf-8"
        );
        fs.writeFileSync("./public/json/" + "annotations" + ".json", annoData);
        res.render("printModel", {
          title: "ModelBricks - Model Print Page",
          data,
          modelName,
          outputOptions,
          geometryList,
        });
      });
    });
  });
});

// displaying static pages (searched by GOOGLE)
// Fetching Curated List of models from Vcel API
app.get("/static/:name", async (req, res) => {
  res.render(`static_${req.params.name}`);
});

//Declaring static informative pages folder (Home, About, motivation etc) - public
app.use(express.static(path.join(__dirname, "public")));

// Routing of informative pages - routes/index.js
app.use("/", indexRouter);

//catch all route, make sure its defined last
app.get("*", async (req, res) => {
  let search = req.params;
  res.render("catch-all", {
    search
  });
});

// Server Port
app.listen(PORT, (err) => {
  if (err) {
    return console.log("ERROR", err);
  }
  console.log(`Listening on port ${PORT}...`);
});

module.exports = app;
