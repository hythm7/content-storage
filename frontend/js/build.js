document.addEventListener('DOMContentLoaded', function () {

  const buildTable = document.getElementById('distributions-builds-table');
  const tableHead  = buildTable.getElementsByTagName('thead')[0];
  const tableBody  = buildTable.getElementsByTagName('tbody')[0];

  const tableHeadThs = Array.from(tableHead.getElementsByTagName('th')).map( (elem) => { return elem.innerText.toLowerCase() } );

  const buildLogModal = document.getElementById('buildLogModal')
  const buildLogModalBody = buildLogModal.querySelector('.modal-body')
  const evtSource = new EventSource('/server-sent-events');

  //var buildAdd = function (id, data) {

  //  const newRow = tableBody.insertRow(0);

  //  var rowHTML  = '<tr data-bs-toggle="modal" data-bs-target="#buildLogModal" data-build-id="' + id + '">';

  //  rowHTML += '<td>' + data["status"]    + '</td>';
  //  rowHTML += '<td>' + data["username"]  + '</td>';
  //  rowHTML += '<td>' + data["filename"]  + '</td>';
  //  rowHTML += '<td>' + data["meta"]      + '</td>';
  //  rowHTML += '<td>' + data["name"]      + '</td>';
  //  rowHTML += '<td>' + data["version"]   + '</td>';
  //  rowHTML += '<td>' + data["auth"]      + '</td>';
  //  rowHTML += '<td>' + data["api"]       + '</td>';
  //  rowHTML += '<td>' + data["test"]      + '</td>';
  //  rowHTML += '<td></td>';

  //  rowHTML += '</tr>';


  //  newRow.outerHTML = rowHTML;

  //}


  var buildUpdate = function (id, data) {

    var row = tableBody.querySelector('[data-build-id="' + id + '"]');

    var tds  = row.getElementsByTagName('td');

    Object.keys(data).forEach( (key) => {

      var td = tds[tableHeadThs.indexOf(key)];

      td.innerHTML = data[key];

    } );

  }


  evtSource.onerror = (err) => {
    console.error("EventSource failed:", err);
  };


  evtSource.addEventListener('message',  (event) => {

    //console.log(event.data);

    var message = JSON.parse(event.data);

    if ( message.target == 'BUILD' ) {

      if ( message.operation == 'UPDATE' ) {
			  console.log(message.build)
        buildUpdate( message.ID, message.build );
      }
    }
  });

  var buildEvent = function (event) {

      const newElement = document.createElement('span');

      newElement.textContent = event.data;
      buildLogModalBody.appendChild(newElement);

  }

  buildLogModal.addEventListener('show.bs.modal', event => {

    var build = event.relatedTarget;

    var buildId = build.getAttribute('data-build-id')

    //buildLogModal.setAttribute('data-build-id', buildId)

    evtSource.addEventListener(buildId, buildEvent, false)

  })

  buildLogModal.addEventListener('hidden.bs.modal', event => {

    var buildId = buildLogModal.getAttribute('data-build-id')

    evtSource.removeEventListener(buildId, buildEvent, false)

    var buildLogModalBody = buildLogModal.querySelector('.modal-body')
    buildLogModalBody.innerHTML = '';

  })

});
