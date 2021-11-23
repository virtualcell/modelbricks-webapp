const fs = require("fs");
const express = require("express");
const app = express();
const exphbs = require("express-handlebars");
const handlebars = require("handlebars");
const path = require("path");
const xml2js = require("xml2js");
const fetch = require("node-fetch");
const aPrs = require("./helpers/annotation-parser.js");
const PORT = process.env.PORT || 4002;

var indexRouter = require("./routes/index");

app.use(express.json());

// view engine setup
const hbs = exphbs.create({
  extname: "hbs",
  defaultLayout: "main",

  // create custom helper
  helpers: {
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
    getPubmedID: function(name) {
      try {
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
      } catch (e) {
        return false;
      }
    },
    getPubmedLink: function(name) {
      try {
        let firstNum = 0;
        //while char is not number
        while (isNaN(name.charAt(firstNum))) {
          firstNum ++;
          if (firstNum > 10000) {
            throw 'infinite loop in getPubmedLink';
          }
        }
        let lastNum = firstNum;
        //while char is number
        while (!isNaN(name.charAt(lastNum))) {
          lastNum ++;
          if (lastNum > 10000) {
            throw 'infinite loop in getPubmedLink';
          }
        }
        let pubmedID = name.slice(firstNum, lastNum);
        let link = "https://pubmed.ncbi.nlm.nih.gov/" + pubmedID + '/';
        return link;
      } catch (e) {
        return false;
      }
    },
    trimString: function (passedString) {
      if (passedString.includes("::")) {
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
    listIndex: function (list, index) {
      return list[index];
    },
    and: function (a, b) {
      return (a && b);
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
// Fetching Curated List of models from Vcel Beta API
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

  //some vars for startRow and maxRow terms
  const APIrow = termMap['page'] * termMap['maxModels'] - termMap['maxModels'] - 1;

  //used for actual data
  const api_url =
    "https://vcellapi-beta.cam.uchc.edu:8080/biomodel?bmName=" + termMap["bmName"] + "&bmId=" + termMap["bmId"] + "&category=" + termMap["category"] + "&owner=" + termMap["owner"] + "&savedLow=" + termMap["savedLow"] + "&savedHigh=" + termMap["savedHigh"] + "&startRow=" + APIrow + "&maxRows=" + termMap['maxModels'] + "&orderBy=" + termMap["orderBy"];

  const fetch_response = await fetch(api_url);
  const json = await fetch_response.json();

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

// Curated List offline copy for testing
app.get("/testCuratedList/:search", async (req, res) => {
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
  const json = [];

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
    'https://vcellapi-beta.cam.uchc.edu:8080/biomodel/' + req.params.name + '/biomodel.vcml';
  var parser = new xml2js.Parser();
  fetch(api_url).then(function(response) {
    return response.text().then(function(text) {
      parser.parseString(text, (err, result) => {
        data = result;
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
    'https://vcellapi-beta.cam.uchc.edu:8080/biomodel/' + modelName + '/biomodel.vcml';
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
// Fetching Curated List of models from Vcel Beta API
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
