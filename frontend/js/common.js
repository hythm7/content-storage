
const status = Object.freeze({

  SUCCESS: 0,
  ERROR:   1,
  RUNNING: 2,
  UNKNOWN: 3,

});

const iconDownloadHTML            = '<i class="bi bi-download text-primary">';
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


export const createDistributionTableRow = function (data) {

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

export const createBuildTableRow = function (data) {

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




export const updateTablePagination = function ( query, headers ) {

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

