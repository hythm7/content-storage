import { AnsiUp } from 'ansi_up';

document.addEventListener('DOMContentLoaded', function () {

  const ansi = new AnsiUp;

  const buildTable = document.getElementById('distributions-build-table');
  const tableHead  = buildTable.getElementsByTagName('thead')[0];
  const tableBody  = buildTable.getElementsByTagName('tbody')[0];

  const tableHeadThs = Array.from(tableHead.getElementsByTagName('th')).map( (elem) => { return elem.innerText.toLowerCase() } );

  const buildLogModal = document.getElementById('buildLogModal')
  const buildLog      = document.getElementById('build-log')

  const buildLogModalBody = buildLogModal.querySelector('.modal-body')

  const evtSource = new EventSource('/server-sent-events');

  var buildAdd = function (id, data) {

    const newRow = tableBody.insertRow(0);

    var rowHTML  = '<tr data-bs-toggle="modal" data-bs-target="#buildLogModal" data-build-id="' + id + '">';

    rowHTML += '<td>' + data["status"]    + '</td>';
    rowHTML += '<td>' + data["user"]      + '</td>';
    rowHTML += '<td>' + data["filename"]  + '</td>';
    rowHTML += '<td>' + data["meta"]      + '</td>';
    rowHTML += '<td></td>';
    rowHTML += '<td>' + data["test"]      + '</td>';
    rowHTML += '<td></td>';
    rowHTML += '<td></td>';

    rowHTML += '</tr>';


    newRow.outerHTML = rowHTML;

  }


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
  }


  evtSource.addEventListener('message',  (event) => {

    var message = JSON.parse(event.data);

    if ( message.target == 'BUILD' ) {

      if ( message.operation == 'UPDATE' ) {
        console.log(message.build)
        buildUpdate( message.ID, message.build );
      } else if ( message.operation == 'ADD' ) {
        buildAdd( message.ID, message.build );
      }
    }
  });

  var buildEvent = function (event) {

    const element = document.createElement('div');

    element.innerHTML = ansi.ansi_to_html( event.data );
    buildLog.appendChild(element);

  }

  buildLogModal.addEventListener('show.bs.modal', event => {


    // TODO: Set modal title
    var buildRow = event.relatedTarget;

    var buildId = buildRow.getAttribute('data-build-id')

    buildLogModal.setAttribute('data-build-id', buildId)

    var buildRunning = buildRow.querySelector('.spinner-grow');

    if ( buildRunning ) {
      console.log(buildId)
      buildLogModalBody.classList.add('autoscrollable-wrapper');
      evtSource.addEventListener(buildId, buildEvent)
    } else {
      console.log('build not running')
    }

  });

  buildLogModal.addEventListener('hidden.bs.modal', event => {

    var buildId = buildLogModal.getAttribute('data-build-id')
      console.log(buildId)

    evtSource.removeEventListener(buildId, buildEvent)

    var buildLogModalBody = buildLogModal.querySelector('.modal-body')
    buildLog.innerHTML = '';

  });

});
