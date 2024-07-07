
import {
  searchDistribution,
  updateDistributionTable,
} from './common.js';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const distribution_search_input = document.getElementById('search-input');

  const distribution_modal       = document.getElementById('distribution-modal')
  const distribution_modal_badge = document.getElementById('distribution-modal-badge')

  const distribution_readme  = document.getElementById('distribution-readme')
  const distribution_changes = document.getElementById('distribution-changes')
  const distribution_build   = document.getElementById('distribution-build')

  const table_pagination = document.getElementById( 'table-pagination' );

  distribution_modal.addEventListener('show.bs.modal', event => {

    const distribution_row = event.relatedTarget;

    const distribution_id = distribution_row.getAttribute('data-distribution-id')

    const distribution_modal_body = distribution_modal.querySelector('.modal-body')

    distribution_modal.setAttribute('data-distribution-id', distribution_id)

    fetch( 'api/v1/distribution/' + distribution_id )
      .then(response => response.json())
      .then(data => {

        distribution_modal_badge.innerText = data.identity;

        distribution_readme.innerHTML = data.readme;

      })
      .catch(error => {
        console.error('Error Processing:', error);
      });

  });

  distribution_modal.addEventListener('hidden.bs.modal', event => {

    distribution_modal_badge.innerHTML = '';
    distribution_readme.innerHTML = '';

  });



  distribution_search_input.addEventListener("input", (event) => {

    clearTimeout(timeout);

    timeout = setTimeout(function() {

      const name = event.target.value.trim();

      searchDistribution( name )

    }, 800);

  });

  table_pagination.addEventListener('click', function (event) { 
    updateDistributionTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
  });

  updateDistributionTable( new URLSearchParams( { page: 1 } ) )

});
