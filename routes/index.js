var express = require("express");
var router = express.Router();

router.get("/", (req, res) => {
  res.render("index", {
    title: "ModelBricks - Home",
  });
});

router.get("/about", (req, res) => {
  res.render("about", {
    title: "ModelBricks - About",
  });
});

router.get("/motivation", (req, res) => {
  res.render("motivation", {
    title: "ModelBricks - Motivation",
  });
});

router.get("/creating", (req, res) => {
  res.render("creating", {
    title: "ModelBricks - Creation",
  });
});

router.get("/egfr", (req, res) => {
  res.render("egfr", {
    title: "ModelBricks - EGFR",
  });
});

router.get("/tools", (req, res) => {
  res.render("tools", {
    title: "ModelBricks - Tools",
  });
});

router.get("/blog", (req, res) => {
  res.render("blog", {
    title: "ModelBricks - Blog",
  });
});

router.get("/search", (req, res) => {
  res.render("googleSearch", {
    title: "ModelBricks - search",
  });
});

module.exports = router;
