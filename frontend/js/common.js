
export const build_status = Object.freeze({

  SUCCESS: 0,
  ERROR:   1,
  RUNNING: 2,
  UNKNOWN: 3,

});

const iconDownloadHTML            = '<i class="bi bi-download text-primary"></i>';
const iconEyeHTML                 = '<i class="bi bi-eye text-primary"></i>';
const iconCheckHTML               = '<i class="bi bi-check text-success"></i>';
const iconXHTML                   = '<i class="bi bi-x text-danger"></i>';
const iconExclamationTriangleHTML = '<i class="bi bi-exclamation-triangle text-warning"></i>';
const spinnerGrowHTML             = '<div class="spinner-grow spinner-grow-sm text-primary"></div>';

export const build_status_to_HTML = function ( value ) {

  if      ( value === build_status.SUCCESS ) { return iconCheckHTML                }
  else if ( value === build_status.ERROR   ) { return iconXHTML                    }
  else if ( value === build_status.UNKNOWN ) { return iconExclamationTriangleHTML  }
  else if ( value === build_status.RUNNING ) { return spinnerGrowHTML              }

}


const table_body = document.getElementsByTagName('tbody')[0];
const table_head = document.getElementsByTagName('thead')[0];

const table_head_ths = Array.from(table_head.getElementsByTagName('th')).map( (elem) => { return elem.innerText.toLowerCase() } );

export const searchDistribution = function ( name ) {

  updateDistributionTable( new URLSearchParams( { name: name, page: 1 } ) )

}

export const searchBuild = function ( name ) {

  updateBuildTable( new URLSearchParams( { name: name, page: 1 } ) )

}

export const searchUser = function ( name ) {

  updateUserTable( new URLSearchParams( { name: name, page: 1 } ) )

}


export const updateDistributionTable = function ( query = new URLSearchParams( { page: 1 } ) ) {

  if ( ! query.has('page') ) { return false }

  const distribution_table = document.getElementById('distribution-table');
  const api                = distribution_table.dataset.api;

  fetch( api + '?' + query.toString() )
    .then( (response) => {

      updateTablePagination( query, response.headers );

      return response.json();

    } )
    .then(data => {

      table_body.innerHTML = '';

      data.forEach( function( obj ) {

        const row = createDistributionTableRow( obj );

        table_body.appendChild( row )

      } );

    })
    .catch(error => {
      console.error('Error Processing:', error);
    });

}

export const updateBuildTable = function ( query = new URLSearchParams( { page: 1 } ) ) {

  if ( ! query.has('page') ) { return false }

  const build_table = document.getElementById('build-table');
  const api         = build_table.dataset.api;

  fetch( api + '?' + query.toString() )
    .then( (response) => {

      updateTablePagination( query, response.headers );

      return response.json();

    } )
    .then(data => {

      table_body.innerHTML = '';

      data.forEach( function( obj ) {

        const row = createBuildTableRow( obj );

        table_body.appendChild( row )

      } );

    })
    .catch(error => {
      console.error('Error Processing:', error);
    });


}

export const updateUserTable = function ( query = new URLSearchParams( { page: 1 } ) ) {

  if ( ! query.has('page') ) { return false }

  const user_table = document.getElementById('user-table');
  const api        = user_table.dataset.api;

  fetch( api + '?' + query.toString() )
    .then( (response) => {

      updateTablePagination( query, response.headers );

      return response.json();

    } )
    .then(data => {

      table_body.innerHTML = '';

      data.forEach( function( obj ) {

        const row = createUserTableRow( obj );

        table_body.appendChild( row )

      } );

    })
    .catch(error => {
      console.error('Error Processing:', error);
    });

}


const createDistributionTableRow = function (data) {

  const row = document.createElement("tr")

  row.dataset.distributionId = data.id;

  const name     = document.createElement('td');
  const version  = document.createElement('td');
  const auth     = document.createElement('td');
  const api      = document.createElement('td');
  const created  = document.createElement('td');
  const download = document.createElement('td');

  name.dataset.bsToggle = 'modal';
  name.dataset.bsTarget = '#distribution-modal';

  name.className  = "text-primary";

  created.className  = "text-center";
  download.className = "text-center";

  name.innerText     = data.name;
  version.innerText  = data.version;
  auth.innerText     = data.auth;
  api.innerText      = data.api;
  created.innerText  = formatDate( data.created );
  download.innerHTML = iconDownloadHTML;

  row.appendChild( name );
  row.appendChild( version );
  row.appendChild( auth );
  row.appendChild( api );
  row.appendChild( created );
  row.appendChild( download );

  return row;

}

const createBuildTableRow = function (data) {

  const row = document.createElement("tr")

  row.dataset.buildId = data.id;


  const build_status = document.createElement('td');
  const user         = document.createElement('td');
  const identity     = document.createElement('td');
  const meta         = document.createElement('td');
  const test         = document.createElement('td');
  const started      = document.createElement('td');
  const completed    = document.createElement('td');

  identity.dataset.bsToggle = 'modal';
  identity.dataset.bsTarget = '#build-modal';

  identity.className = "text-primary";

  build_status.className = "text-center";
  meta.className         = "text-center";
  test.className         = "text-center";
  started.className      = "text-center";
  completed.className    = "text-center";

  build_status.innerHTML = build_status_to_HTML( data.status );

  user.innerText = data.user;
  identity.innerText = data.identity;
  meta.innerHTML = build_status_to_HTML( data.meta );
  test.innerHTML = build_status_to_HTML( data.test );
  started.innerText   = formatDate( data.started   );
  completed.innerText = formatDate( data.completed );

  row.appendChild( build_status );
  row.appendChild( user );
  row.appendChild( identity );
  row.appendChild( meta );
  row.appendChild( test );
  row.appendChild( started );
  row.appendChild( completed );

  return row;

}

export const updateBuildTableRow = function (id, data) {

  const row = table_body.querySelector('[data-build-id="' + id + '"]');

  if ( row ) {

    const tds  = row.getElementsByTagName('td');

    Object.keys(data).forEach( (key) => {

      const td = tds[table_head_ths.indexOf(key)];

      const value = data[key];

      if      ( typeof value === 'string' ) { td.innerText = value                 }
      else if ( typeof value === 'number' ) { td.innerHTML = build_status_to_HTML( value ) }
      else { console.error( 'Invalid ' + value ) }

    } );
  }

}

const createUserTableRow = function (data) {

  const row = document.createElement("tr")


  const username  = document.createElement('td');
  const firstname = document.createElement('td');
  const lastname  = document.createElement('td');
  const email     = document.createElement('td');
  const admin     = document.createElement('td');
  const created   = document.createElement('td');

  username.dataset.userId = data.id;
  username.dataset.bsToggle = 'modal';
  username.dataset.bsTarget = '#user-modal';

  username.className = "text-primary";
  admin.className    = "text-center";
  created.className  = "text-center";

  username.innerText  = data.username;
  firstname.innerText = data.firstname;
  lastname.innerText  = data.lastname;
  email.innerText     = data.email;
  created.innerText   = formatDate( data.created );

  if ( data.admin ) { admin.innerHTML = iconCheckHTML }

  row.appendChild( username );
  row.appendChild( firstname );
  row.appendChild( lastname );
  row.appendChild( email );
  row.appendChild( admin );
  row.appendChild( created );

  return row;

}


const updateTablePagination = function ( query, headers ) {

  const elementFirstPage    = document.getElementById('first-page');
  const elementPreviousPage = document.getElementById('previous-page');
  const elementCurrentPage  = document.getElementById('current-page');
  const elementNextPage     = document.getElementById('next-page');
  const elementLastPage     = document.getElementById('last-page');

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

const formatDate = (dateString) => {

  const date = dateString.split('T')[0];
  const time = dateString.split('T')[1].split('.')[0];

  return date + ' ' + time;

}

