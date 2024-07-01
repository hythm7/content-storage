
import {
  searchDistribution,
  updateDistributionTable,
} from './common.js';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const distribution_search_input = document.getElementById('search-input');

  const table_pagination = document.getElementById( 'table-pagination' );

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
