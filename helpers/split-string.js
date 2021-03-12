//splits string at target character;
function splitString(string, target) {
  list = [];
  lastTagert = 0;
  for (var i = 0; i < string.length; i++) {
    if (string[i] == target) {
      list.push(string.slice(lastTagert, i));
      lastTagert = i + 1;
    }
  }
  list.push(string.slice(lastTagert, string.length));
  return(list);
}

module.exports = splitString;
