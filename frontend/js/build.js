import { AnsiUp } from 'ansi_up';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;
  const search_input = document.getElementById('search-input');

  const build_table      = document.getElementById('build-table');
  const build_table_head = build_table.getElementsByTagName('thead')[0];
  const build_table_body = build_table.getElementsByTagName('tbody')[0];

  const tableBuildHeadThs = Array.from(build_table_head.getElementsByTagName('th')).map( (elem) => { return elem.innerText.toLowerCase() } );

  const build_log_modal = document.getElementById('build-log-modal')
  const build_log_div   = document.getElementById('build-log-div')

  const buildLogModalBody = build_log_modal.querySelector('.modal-body')

  const evtSource = new EventSource('/server-sent-events');

  const pagination = document.getElementsByClassName("pagination")[0];

  const elementFirstPage    = document.getElementById('first-page');
  const elementPreviousPage = document.getElementById('previous-page');
  const elementCurrentPage  = document.getElementById('current-page');
  const elementNextPage     = document.getElementById('next-page');
  const elementLastPage     = document.getElementById('last-page');

  const ansi = new AnsiUp;

  search_input.addEventListener("keyup", (event) => {

    clearTimeout(timeout);

    timeout = setTimeout(function() {

      const query = event.target.value.trim();

      searchBuild( query )

  }, 800);

  });

  const searchBuild = function ( query ) {

    console.log( query )

  }

  const updateBuild = function (id, data) {

    const row = build_table_body.querySelector('[data-build-id="' + id + '"]');

    if ( row ) {

      const tds  = row.getElementsByTagName('td');

      Object.keys(data).forEach( (key) => {

        const td = tds[tableBuildHeadThs.indexOf(key)];

        const value = data[key];

        if      ( typeof value === 'string' ) { td.innerText = value                 }
        else if ( typeof value === 'number' ) { td.innerHTML = statusToHTML( value ) }
        else { console.log( 'Invalid ' + value ) }

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
        updateBuild( message.ID, message.build );
      }
    }
  });

  var buildEvent = function (event) {

    const element = document.createElement('div');

    element.innerHTML = ansi.ansi_to_html( event.data );
    build_log_div.appendChild(element);

  }

  build_log_modal.addEventListener('show.bs.modal', event => {


    // TODO: Set modal title
    var buildRow = event.relatedTarget.parentNode;

    var buildId = buildRow.getAttribute('data-build-id')

    build_log_modal.setAttribute('data-build-id', buildId)

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

          build_log_div.appendChild(element);

        })
        .catch(error => {
          console.error('Error Processing:', error);
        });
    }

  });

  build_log_modal.addEventListener('hidden.bs.modal', event => {

    var buildId = build_log_modal.getAttribute('data-build-id')

    evtSource.removeEventListener(buildId, buildEvent)

    var buildLogModalBody = build_log_modal.querySelector('.modal-body')
    build_log_div.innerHTML = '';

  });

  const updateBuildTable = function (page) {

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

        updateBuildTablePagination( first, previous, current, next, last );

        return response.json();

      } )
      .then(data => {

        build_table_body.innerHTML = '';

        data.forEach( function( obj ) {

        const row = createBuildRow( obj );

        build_table_body.appendChild( row )

        } );

      })
      .catch(error => {
        console.error('Error Processing:', error);
      });

  }

  const updateBuildTablePagination = function ( first, previous, current, next, last) {

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

  pagination.addEventListener('click', function (event) { 
    updateBuildTable( event.target.getAttribute('data-page') )
  });


  updateBuildTable( 1 )

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

    status.innerHTML = statusToHTML( data.status );
    user.innerText = data.user;
    identity.innerText = data.identity;
    meta.innerHTML = statusToHTML( data.meta );
    test.innerHTML = statusToHTML( data.test );
    started.innerText = data.started;
    completed.innerText = data.completed;

    log.innerHTML = iconEyeHTML;
    log.dataset.bsToggle = 'modal';
    log.dataset.bsTarget = '#build-log-modal';

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


const status = Object.freeze({

  SUCCESS: 0,  
  ERROR:   1,  
  RUNNING: 2,  
  UNKNOWN: 3,  

});

const iconEyeHTML                 = '<i class="bi bi-eye text-primary">';
const iconCheckHTML               = '<i class="bi bi-check text-success">';
const iconXHTML                   = '<i class="bi bi-x text-danger">';
const iconExclamationTriangleHTML = '<i class="bi bi-exclamation-triangle text-warning">';
const spinnerGrowHTML             = '<div class="spinner-grow spinner-grow-sm text-primary">';

const statusToHTML = function ( value ) {

  if      ( value === status.SUCCESS ) { return iconCheckHTML                }
  else if ( value === status.ERROR   ) { return iconXHTML                    }
  else if ( value === status.UNKNOWN ) { return iconExclamationTriangleHTML  }
  else if ( value === status.RUNNING ) { return spinnerGrowHTML              }

}
