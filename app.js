const fs = require("fs");
const express = require("express");
const app = express();
const exphbs = require("express-handlebars");
const handlebars = require("handlebars");
const path = require("path");
const xml2js = require("xml2js");
// const util = require("util");
const fetch = require("node-fetch");
// const htmlparser2 = require("htmlparser2");
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
      var theDate = new Date(timeStamp);
      dateString = theDate.toGMTString();
      date = dateString.slice(5, 16);
      return dateString;
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
      return (parseInt(a) == parseInt(b))
    }
  },
});

app.engine("hbs", hbs.engine);
app.set("view engine", "hbs");

// some pages for development purposes
// for viewing model json file in browser
app.get("/json", (req, res) => {
  var parser = new xml2js.Parser();
  fs.readFile("./biomodels/Biomodel_176191843.vcml", (err, data) => {
    parser.parseString(data, (err, result) => {
      res.send(result);
    });
  });
});
// for viewing model's annotation json file
app.get("/ajson", (req, res) => {
  var parser = new xml2js.Parser();
  fs.readFile(
    "./files/CM_PM25628036_MB4::Rho_GDI_binding_annoations.xml",
    (err, data) => {
      parser.parseString(data, (err, result) => {
        res.send(result);
      });
    }
  );
});

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
  const maxModels = 5;
  const APIrow = termMap['page'] * maxModels - maxModels - 1;

  //used for actual data
  const api_url =
    "https://vcellapi-beta.cam.uchc.edu:8080/biomodel?bmName=" + termMap["bmName"] + "&bmId=" + termMap["bmId"] + "&category=" + termMap["category"] + "&owner=" + termMap["owner"] + "&savedLow=" + termMap["savedLow"] + "&savedHigh=" + termMap["savedHigh"] + "&startRow=" + APIrow + "&maxRows=" + maxModels + "&orderBy=" + termMap["orderBy"];

  const fetch_response = await fetch(api_url);
  const json = await fetch_response.json();

  //if page is empty
  let isNotEmpty = true;
  if (json.length == 0) {
    isNotEmpty = false;
  }

  res.render("curatedList", {
    title: "ModelBricks - Curated List",
    json,
    termMap,
    isNotEmpty,
  });
});

// main Dashboard for dynamic models selected from curated list page
app.get("/curatedList/model/:name", (req, res) => {
  // var info = "null";
  const api_url =
    'https://vcellapi-beta.cam.uchc.edu:8080/biomodel/' + req.params.name + '/biomodel.vcml';
  var parser = new xml2js.Parser();
  fetch(api_url).then(function(response) {
    return response.text().then(function(text) {
      parser.parseString(text, (err, result) => {
        data = result;
        let annoObj = new aPrs.AnnParser(data);
        let annoData = annoObj.getString();
        fs.writeFileSync("./public/json/" + "annotations" + ".json", annoData);
        res.render("model", {
          title: "ModelBricks - Model Page",
          data,
        });
      });
    });
  });
  /*fs.readFile(
    "./files/" + req.params.name + "_annotations.xml",
    (err, data) => {
      parser.parseString(data, (err, result) => {
        info = result;
        let jsonData = JSON.stringify(info);
        fs.writeFileSync("./public/json/" + "annotations" + ".json", jsonData);
      });
    }
  );*/
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
        fs.writeFileSync("./public/json/" + "annotations" + ".json", annoData);
        res.render("printModel", {
          title: "ModelBricks - Model Print Page",
          data,
          modelName,
        });
      });
    });
  });
  /*fs.readFile("./files/" + req.params.name + ".vcml", (err, data) => {
    parser.parseString(data, (err, result) => {
      const data = result;
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
      res.render("printModel", {
        title: "ModelBricks - Model Print Page",
        data,
        modelName,
      });
    });
  });
  var parser = new xml2js.Parser();
  fs.readFile(
    "./files/" + req.params.name + "_annotations.xml",
    (err, data) => {
      parser.parseString(data, (err, result) => {
        info = result;
        let jsonData = JSON.stringify(info);
        fs.writeFileSync(
          "./public/json/" + req.params.name + ".json",
          jsonData
        );
      });
    }
  );*/
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

// Server Port
app.listen(PORT, (err) => {
  if (err) {
    return console.log("ERROR", err);
  }
  console.log(`Listening on port ${PORT}...`);
});

module.exports = app;
