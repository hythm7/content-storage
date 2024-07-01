
import {
  updateTablePagination,
  createDistributionTableRow,
} from './common.js';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const distribution_search_input = document.getElementById('search-input');

  const distribution_table      = document.getElementById('distribution-table');

  const distribution_table_body = distribution_table.getElementsByTagName('tbody')[0];

  const distribution_table_navigation = document.getElementById( 'distribution-table-navigation' );

  distribution_search_input.addEventListener("input", (event) => {

    clearTimeout(timeout);

    timeout = setTimeout(function() {

      const name = event.target.value.trim();

      searchDistribution( name )

  }, 800);

  });

  const searchDistribution = function ( name ) {

    updateDistributionTable( new URLSearchParams( { name: name, page: 1 } ) )

  }

  const updateDistributionTable = function (query) {

    if ( ! query.has('page') ) { return false }

    fetch('api/v1/distribution?' + query.toString(), {
      method: 'GET',
    })
      .then( (response) => {

        updateTablePagination( query, response.headers );

        return response.json();

      } )
      .then(data => {

        distribution_table_body.innerHTML = '';

        data.forEach( function( obj ) {

        const row = createDistributionTableRow( obj );

        distribution_table_body.appendChild( row )

        } );

      })
      .catch(error => {
        console.error('Error Processing:', error);
      });

  }


  distribution_table_navigation.addEventListener('click', function (event) { 
    updateDistributionTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
  });


  updateDistributionTable( new URLSearchParams( { page: 1 } ) )

});
