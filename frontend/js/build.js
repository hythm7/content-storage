document.addEventListener('DOMContentLoaded', function () {

  const buildLogModal = document.getElementById('buildLogModal')
  const buildLogModalBody = buildLogModal.querySelector('.modal-body')
  const evtSource = new EventSource('/server-sent-events');

  var buildAdd = function (data) {

    var buildTable = document.getElementById('distributions-builds-table');
    var tableBody  = buildTable.getElementsByTagName('tbody')[0];

    var bodyHTML = tableBody.innerHTML;

    var rowHTML  = '<tr data-bs-toggle="modal" data-bs-target="#buildLogModal" data-build-id="' + data.id + '">';

    rowHTML += '<td>' + data.status   + '</td>';
    rowHTML += '<td>' + data.username + '</td>';
    rowHTML += '<td>' + data.filename + '</td>';
    rowHTML += '</tr>';


    tableBody.innerHTML = rowHTML + bodyHTML;

  }




  evtSource.onerror = (err) => {
    console.error("EventSource failed:", err);
  };


  evtSource.addEventListener('message',  (event) => {

    var message = JSON.parse(event.data);

    if ( message.target == 'BUILD' ) {

      if ( message.operation == 'ADD' ) {
        console.log('BUILD ADD');

        buildAdd( message.build );

      }

    }
  });

  var buildEvent = function (event) {

      const newElement = document.createElement("li");

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
