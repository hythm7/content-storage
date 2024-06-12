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

  const pagination = document.getElementsByClassName("pagination")[0];

  const elementFirstPage    = document.getElementById('first-page');
  const elementPreviousPage = document.getElementById('previous-page');
  const elementCurrentPage  = document.getElementById('current-page');
  const elementNextPage     = document.getElementById('next-page');
  const elementLastPage     = document.getElementById('last-page');

  var buildUpdate = function (id, data) {

    var row = tableBody.querySelector('[data-build-id="' + id + '"]');

    if ( row ) {
      var tds  = row.getElementsByTagName('td');

      Object.keys(data).forEach( (key) => {

        var td = tds[tableHeadThs.indexOf(key)];

        td.innerHTML = data[key];

      } );
    }

  }


  evtSource.onerror = (err) => {
    console.error("EventSource failed:", err);
  }


  evtSource.addEventListener('message',  (event) => {

    var message = JSON.parse(event.data);

    if ( message.target == 'BUILD' ) {

      if ( message.operation == 'UPDATE' ) {
        buildUpdate( message.ID, message.build );
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
    var buildRow = event.relatedTarget.parentNode;

    var buildId = buildRow.getAttribute('data-build-id')

    buildLogModal.setAttribute('data-build-id', buildId)

    var buildRunning = buildRow.querySelector('.spinner-grow');

    if ( buildRunning ) {

      buildLogModalBody.classList.add('autoscrollable-wrapper');
      evtSource.addEventListener(buildId, buildEvent)

    } else {

      buildLogModalBody.classList.remove('autoscrollable-wrapper');

      fetch('api/v1/build/' + buildId + '/log', {
        method: 'GET',
      })
        .then(response => response.json()) // Assuming the server responds with JSON
        .then(data => {

          const element = document.createElement('div');

          const log = ansi.ansi_to_html( data.log ).replace(/(?:\n)/g, '<br>')

          element.innerHTML = log;

          buildLog.appendChild(element);

        })
        .catch(error => {
          console.error('Error Processing:', error);
        });
    }

  });

  buildLogModal.addEventListener('hidden.bs.modal', event => {

    var buildId = buildLogModal.getAttribute('data-build-id')

    evtSource.removeEventListener(buildId, buildEvent)

    var buildLogModalBody = buildLogModal.querySelector('.modal-body')
    buildLog.innerHTML = '';

  });

  const buildUpdateTable = function (event) {

    const page = event.target.getAttribute('data-page')

    if (page === null) { return false }

    fetch('api/v1/build?page=' + page, {
      method: 'GET',
    })
      .then( (response) => {

        const first    = response.headers.get('x-first');
        const previous = response.headers.get('x-previous');
        const current  = response.headers.get('x-current');
        const next     = response.headers.get('x-next');
        const last     = response.headers.get('x-last');

        buildUpdatePagination( first, previous, current, next, last );

        return response.json();

      } )
      .then(data => {

        tableBody.innerHTML = '';

        data.forEach( function( obj ) {

        const row = createBuildRow( obj );

        tableBody.appendChild( row )

        } );

      })
      .catch(error => {
        console.error('Error Processing:', error);
      });

  }

  const buildUpdatePagination = function ( first, previous, current, next, last) {

        elementFirstPage.dataset.page    = first;
        elementPreviousPage.dataset.page = previous;
        elementCurrentPage.dataset.page  = current;
        elementNextPage.dataset.page     = next;
        elementLastPage.dataset.page     = last;

        if ( first == current ) {
          elementFirstPage.classList.add( "disabled" );
        } else {

          elementFirstPage.classList.remove( "disabled" );
        }

        if ( previous == current ) {
          elementPreviousPage.classList.add( "disabled" );
        } else {

          elementPreviousPage.classList.remove( "disabled" );
        }

        if ( next == current ) {
          elementNextPage.classList.add( "disabled" );
        } else {

          elementNextPage.classList.remove( "disabled" );
        }

        if ( last == current ) {
          elementLastPage.classList.add( "disabled" );
        } else {

          elementLastPage.classList.remove( "disabled" );
        }

  }

  pagination.addEventListener('click', buildUpdateTable )

});

  const createBuildRow = function (data) {

    const row = document.createElement("tr")

    row.dataset.buildId = data.id;

    const status    = document.createElement('td');
    const user      = document.createElement('td');
    const identity  = document.createElement('td');
    const meta      = document.createElement('td');
    const test      = document.createElement('td');
    const started   = document.createElement('td');
    const completed = document.createElement('td');
    const log       = document.createElement('td');

    status.className    = "text-center";
    meta.className      = "text-center";
    test.className      = "text-center";
    started.className   = "text-center";
    completed.className = "text-center";
    log.className       = "text-center";

    status.innerText = data.status;
    user.innerText = data.user;
    identity.innerText = data.identity;
    meta.innerText = data.meta;
    test.innerText = data.test;
    started.innerText = data.started;
    completed.innerText = data.completed;

    log.innerHTML = '<i class="bi-eye">';
    log.dataset.bsToggle = 'modal';
    log.dataset.bsTarget = '#buildLogModal';

    row.appendChild( status );
    row.appendChild( user );
    row.appendChild( identity );
    row.appendChild( meta );
    row.appendChild( test );
    row.appendChild( started );
    row.appendChild( completed );
    row.appendChild( log );

    return row;

  }


