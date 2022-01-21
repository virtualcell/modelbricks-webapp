function extractContent(s, space=false) {
  var span= document.createElement('span');
  span.innerHTML= s;
  if(space) {
    var children= span.querySelectorAll('*');
    for(var i = 0 ; i < children.length ; i++) {
      if(children[i].textContent)
        children[i].textContent+= ' ';
      else
        children[i].innerText+= ' ';
    }
  }
  return [span.textContent || span.innerText].toString().replace(/ +/g,' ');
};

function sort(ascending, columnClassName, tableId, hasNonSortableRows=false, count=0) {
  var tbody = document.getElementById(tableId).getElementsByTagName("tbody")[0];
  if (!hasNonSortableRows) {
    var rows = tbody.getElementsByTagName("tr");
  } else {
    var rows = document.querySelectorAll(".sortable-row");
  }
  let n = rows.length;
  var i, j;
  for (i = 0; i < n-1; i++) {
    var row = rows[i];
    var nextRow = rows[i + 1];
    var value = extractContent(row.getElementsByClassName(columnClassName)[0].innerHTML);
    var nextValue = extractContent(nextRow.getElementsByClassName(columnClassName)[0].innerHTML);
    //arr[j] > arr[j+1]
    if (ascending ? value > nextValue : value < nextValue) {
      tbody.insertBefore(nextRow, row);
    }
  }
  //big O(n^2) baby
  if (count < rows.length) {
    sort(ascending, columnClassName, tableId, hasNonSortableRows, count + 1);
  }
}
