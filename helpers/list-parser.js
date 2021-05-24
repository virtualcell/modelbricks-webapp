class listParser {
  constructor(link);
  this.link = link;

  convertPair(pair) {
    let a = pair[0];
    let b = pair[1];
    //remove dangerous chars
    a.replace('=', '');
    a.replace('&', '');
    b.replace('=', '');
    b.replace('&', '');
    return (pair[0] + '=' + pair[1]);
  }

  setTermMap() {
    var terms = this.link.split("&");
    for (let i = 0; i < terms.length; i++) {
      terms[i] = terms[i].split("=");
    }
    this.termMap = termMap = Object.fromEntries(terms);
  }

  newLink() {
    let out = '';
    for (pair of this.termMap) {
      out += this.convertPair(pair);
    }
    return (out);
  }
}
