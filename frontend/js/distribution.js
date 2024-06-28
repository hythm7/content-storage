
document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const distribution_search_input = document.getElementById('search-input');

  const distribution_table      = document.getElementById('distribution-table');

  const distribution_table_body = distribution_table.getElementsByTagName('tbody')[0];

  const distribution_table_navigation = document.getElementById( 'distribution-table-navigation' );

  const elementFirstPage    = document.getElementById('first-page');
  const elementPreviousPage = document.getElementById('previous-page');
  const elementCurrentPage  = document.getElementById('current-page');
  const elementNextPage     = document.getElementById('next-page');
  const elementLastPage     = document.getElementById('last-page');

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

        updateDistributionTablePagination( query, response.headers );

        return response.json();

      } )
      .then(data => {

        distribution_table_body.innerHTML = '';

        data.forEach( function( obj ) {

        const row = createDistributionRow( obj );

        distribution_table_body.appendChild( row )

        } );

      })
      .catch(error => {
        console.error('Error Processing:', error);
      });


  }

  const updateDistributionTablePagination = function ( query, headers ) {

        query.delete( 'page' );

        let entries = Object.fromEntries( query )

        const first    = headers.get('x-first');
        const previous = headers.get('x-previous');
        const current  = headers.get('x-current');
        const next     = headers.get('x-next');
        const last     = headers.get('x-last');

        elementFirstPage.dataset.query    = new URLSearchParams( { ...entries, page:  first    } );

        elementPreviousPage.dataset.query = new URLSearchParams( { ...entries, page:  previous } );

        elementCurrentPage.dataset.query  = new URLSearchParams( { ...entries, page:  current  } );

        elementNextPage.dataset.query     = new URLSearchParams( { ...entries, page:  next     } );

        elementLastPage.dataset.query     = new URLSearchParams( { ...entries, page:  last     } );

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

  distribution_table_navigation.addEventListener('click', function (event) { 
    updateDistributionTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
  });


  updateDistributionTable( new URLSearchParams( { page: 1 } ) )

});

  const createDistributionRow = function (data) {

    const row = document.createElement("tr")

    row.dataset.distributionId = data.id;

    const name     = document.createElement('td');
    const version  = document.createElement('td');
    const auth     = document.createElement('td');
    const api      = document.createElement('td');
    const created  = document.createElement('td');
    const download = document.createElement('td');

    created.className  = "text-center";
    download.className = "text-center";

    name.innerText     = data.name;
    version.innerText  = data.version;
    auth.innerText     = data.auth;
    api.innerText      = data.api;
    created.innerText  = data.created;
    download.innerHTML = iconDownloadHTML;

    row.appendChild( name );
    row.appendChild( version );
    row.appendChild( auth );
    row.appendChild( api );
    row.appendChild( created );
    row.appendChild( download );

    return row;

  }


const iconDownloadHTML = '<i class="bi bi-download text-primary">';

