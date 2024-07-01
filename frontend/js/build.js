import {
  updateTablePagination,
  createBuildTableRow,
} from './common.js';

import { AnsiUp } from 'ansi_up';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const build_search_input = document.getElementById('search-input');

  const build_table      = document.getElementById('build-table');
  const build_table_head = build_table.getElementsByTagName('thead')[0];
  const build_table_body = build_table.getElementsByTagName('tbody')[0];

  const tableBuildHeadThs = Array.from(build_table_head.getElementsByTagName('th')).map( (elem) => { return elem.innerText.toLowerCase() } );

  const build_log_modal = document.getElementById('build-log-modal')
  const build_log_div   = document.getElementById('build-log-div')

  const buildLogModalBody = build_log_modal.querySelector('.modal-body')

  const build_event_source = new EventSource('/server-sent-events');

  const build_table_navigation = document.getElementById( 'build-table-navigation' );

  const ansi = new AnsiUp;

  build_search_input.addEventListener("input", (event) => {

    clearTimeout(timeout);

    timeout = setTimeout(function() {

      const name = event.target.value.trim();

      searchBuild( name )

  }, 800);

  });

  const searchBuild = function ( name ) {

    updateBuildTable( new URLSearchParams( { name: name, page: 1 } ) )

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
        else { console.error( 'Invalid ' + value ) }

      } );
    }

  }


  build_event_source.onerror = (err) => {
    console.error("EventSource failed:", err);
  }


  build_event_source.addEventListener('message',  (event) => {

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
      build_event_source.addEventListener(buildId, buildEvent)

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

    build_event_source.removeEventListener(buildId, buildEvent)

    var buildLogModalBody = build_log_modal.querySelector('.modal-body')
    build_log_div.innerHTML = '';

  });

  const updateBuildTable = function (query) {

    if ( ! query.has('page') ) { return false }

    fetch('api/v1/build?' + query.toString(), {
      method: 'GET',
    })
      .then( (response) => {

        updateTablePagination( query, response.headers );

        return response.json();

      } )
      .then(data => {

        build_table_body.innerHTML = '';

        data.forEach( function( obj ) {

        const row = createBuildTableRow( obj );

        build_table_body.appendChild( row )

        } );

      })
      .catch(error => {
        console.error('Error Processing:', error);
      });


  }

  build_table_navigation.addEventListener('click', function (event) { 
    updateBuildTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
  });


  updateBuildTable( new URLSearchParams( { page: 1 } ) )

});
