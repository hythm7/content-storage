import {
  build_status,
  build_status_to_HTML,
  searchBuild,
  updateBuildTable,
  updateBuildTableRow,

} from './common.js';

import { AnsiUp } from 'ansi_up';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const build_search_input = document.getElementById('search-input');

  const build_modal       = document.getElementById('build-modal')
  const build_modal_badge = document.getElementById('build-modal-badge')

  const build_log = document.getElementById('build-log')


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
    build_log.appendChild(element);

  }

  build_modal.addEventListener('show.bs.modal', event => {


    const buildRow = event.relatedTarget;

    const buildId = buildRow.getAttribute('data-build-id')

    const build_modal_body = build_modal.querySelector('.modal-body')


    build_modal.setAttribute('data-build-id', buildId)

    fetch( 'api/v1/build/' + buildId )
      .then(response => response.json())
      .then(data => {

        if ( data.identity ) { build_modal_badge.innerText = data.identity }

        if ( data.status == build_status.RUNNING ) {

          build_modal_body.classList.add('autoscrollable-wrapper');

          build_event_source.addEventListener(buildId, buildEvent)

        } else {

          build_modal_body.classList.remove('autoscrollable-wrapper');

          const element = document.createElement('div');

          const log = ansi.ansi_to_html( data.log ).replace(/(?:\n)/g, '<br>')

          element.innerHTML = log;

          build_log.appendChild(element);
        }

      })
      .catch(error => {
        console.error('Error Processing:', error);
      });

  });

  build_modal.addEventListener('hidden.bs.modal', event => {

    var buildId = build_modal.getAttribute('data-build-id')

    build_event_source.removeEventListener(buildId, buildEvent)

    build_modal_badge.innerHTML = '';
    build_log.innerHTML         = '';

  });


  table_pagination.addEventListener('click', function (event) { 
    updateBuildTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
  });

  updateBuildTable( new URLSearchParams( { page: 1 } ) )

});
