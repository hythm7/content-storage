import {
  searchBuild,
  updateBuildTable,
  updateBuildTableRow,

} from './common.js';

import { AnsiUp } from 'ansi_up';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const build_search_input = document.getElementById('search-input');

  const build_log_modal = document.getElementById('build-log-modal')
  const build_log_div   = document.getElementById('build-log-div')

  const buildLogModalBody = build_log_modal.querySelector('.modal-body')

  const build_event_source = new EventSource('/server-sent-events');

  const table_pagination = document.getElementById( 'table-pagination' );

  const ansi = new AnsiUp;

  build_search_input.addEventListener("input", (event) => {

    clearTimeout(timeout);

    timeout = setTimeout(function() {

      const name = event.target.value.trim();

      searchBuild( name )

  }, 800);

  });


  build_event_source.onerror = (err) => {
    console.error("EventSource failed:", err);
  }


  build_event_source.addEventListener('message',  (event) => {

    var message = JSON.parse(event.data);

    if ( message.target == 'BUILD' ) {

      if ( message.operation == 'UPDATE' ) {
        updateBuildTableRow( message.ID, message.build );
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


  table_pagination.addEventListener('click', function (event) { 
    updateBuildTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
  });

  updateBuildTable( new URLSearchParams( { page: 1 } ) )

});
