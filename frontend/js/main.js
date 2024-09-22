// Import config
import config from '../../config.json';
// Import our custom CSS
import '../scss/style.scss';

// Import all of Bootstrap's JS
import * as bootstrap from 'bootstrap';

import DOMPurify from 'dompurify';
import { marked } from 'marked';
import { AnsiUp } from 'ansi_up';


/*!
 * Color mode toggler for Bootstrap's docs (https://getbootstrap.com/)
 * Copyright 2011-2024 The Bootstrap Authors
 * Licensed under the Creative Commons Attribution 3.0 Unported License.
 */

(() => {
  'use strict'

  const getStoredTheme = () => localStorage.getItem('theme')
  const setStoredTheme = theme => localStorage.setItem('theme', theme)

  const getPreferredTheme = () => {
    const storedTheme = getStoredTheme()
    if (storedTheme) {
      return storedTheme
    }

    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
  }

  const setTheme = theme => {
    if (theme === 'auto') {
      document.documentElement.setAttribute('data-bs-theme', (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'))
    } else {
      document.documentElement.setAttribute('data-bs-theme', theme)
    }
  }

  setTheme(getPreferredTheme())

  const showActiveTheme = (theme, focus = false) => {
    const themeSwitcher = document.querySelector('#bd-theme')

    if (!themeSwitcher) {
      return
    }

    const themeSwitcherText = document.querySelector('#bd-theme-text')
    const activeThemeIcon = document.querySelector('.theme-icon-active')
    const btnToActive = document.querySelector(`[data-bs-theme-value="${theme}"]`)

    const iOfCurrentActiveClassList = activeThemeIcon.classList;
    const iOfCurrentActiveClass     = Array.from(iOfCurrentActiveClassList).filter(word => word.startsWith("bi-"))[0];

    const iOfToBeActiveclassList = btnToActive.querySelector('i').classList;
    const iOfToBeActiveClass     = Array.from(iOfToBeActiveclassList).filter(word => word.startsWith("bi-"))[0];


    document.querySelectorAll('[data-bs-theme-value]').forEach(element => {
      element.classList.remove('active')
      element.setAttribute('aria-pressed', 'false')
    })

    btnToActive.classList.add('active')
    btnToActive.setAttribute('aria-pressed', 'true')
    activeThemeIcon.classList.replace( iOfCurrentActiveClass, iOfToBeActiveClass );

    const themeSwitcherLabel = `${themeSwitcherText.textContent} (${btnToActive.dataset.bsThemeValue})`
    themeSwitcher.setAttribute('aria-label', themeSwitcherLabel)

    if (focus) {
      themeSwitcher.focus()
    }
  }

  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    const storedTheme = getStoredTheme()
    if (storedTheme !== 'light' && storedTheme !== 'dark') {
      setTheme(getPreferredTheme())
    }
  })

  window.addEventListener('DOMContentLoaded', () => {
    showActiveTheme(getPreferredTheme())

    document.querySelectorAll('[data-bs-theme-value]')
      .forEach(toggle => {
        toggle.addEventListener('click', () => {
          const theme = toggle.getAttribute('data-bs-theme-value')
          setStoredTheme(theme)
          setTheme(theme)
          showActiveTheme(theme, true)
        })
      })
  })
})();


const api_version = config.api.version;

const build_status = Object.freeze({

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

const build_status_to_HTML = function ( value ) {

  if      ( value === build_status.SUCCESS ) { return iconCheckHTML                }
  else if ( value === build_status.ERROR   ) { return iconXHTML                    }
  else if ( value === build_status.UNKNOWN ) { return iconExclamationTriangleHTML  }
  else if ( value === build_status.RUNNING ) { return spinnerGrowHTML              }

}



const searchDistribution = function ( name ) {

  updateDistributionTable( new URLSearchParams( { name: name, page: 1 } ) )

}

const searchBuild = function ( name ) {

  updateBuildTable( new URLSearchParams( { name: name, page: 1 } ) )

}

const searchUser = function ( name ) {

  updateUserTable( new URLSearchParams( { name: name, page: 1 } ) )

}


const updateDistributionTable = function ( query = new URLSearchParams( { page: 1 } ) ) {

  const distribution_table = document.getElementById('distribution-table');
  const table_body = document.getElementsByTagName('tbody')[0];
  const table_head = document.getElementsByTagName('thead')[0];
  const api                = distribution_table.dataset.api;

  if ( ! query.has('page') ) { return false }

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

const updateBuildTable = function ( query = new URLSearchParams( { page: 1 } ) ) {

  const build_table = document.getElementById('build-table');
  const table_body = document.getElementsByTagName('tbody')[0];
  const table_head = document.getElementsByTagName('thead')[0];
  const api         = build_table.dataset.api;

  if ( ! query.has('page') ) { return false }


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

const updateUserTable = function ( query = new URLSearchParams( { page: 1 } ) ) {

  const user_table = document.getElementById('user-table');
  const table_body = document.getElementsByTagName('tbody')[0];
  const table_head = document.getElementsByTagName('thead')[0];

  const api        = user_table.dataset.api;

  if ( ! query.has('page') ) { return false }


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

  const download_link = document.createElement('a');

  download_link.className = 'btn';
  download_link.href      = 'archive/' + data.identity;
  download_link.innerHTML = iconDownloadHTML;

  download.appendChild( download_link );

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
  if ( data.started ) {
    started.innerText   = formatDate( data.started   );
  }
  if ( data.completed ) {
    completed.innerText = formatDate( data.completed );
  }

  row.appendChild( build_status );
  row.appendChild( user );
  row.appendChild( identity );
  row.appendChild( meta );
  row.appendChild( test );
  row.appendChild( started );
  row.appendChild( completed );

  return row;

}

const updateBuildTableRow = function (id, data) {

  const row = document.getElementsByTagName('tbody')[0].querySelector('[data-build-id="' + id + '"]');

  if ( row ) {

    const tds  = row.getElementsByTagName('td');

    Object.keys(data).forEach( (key) => {

      const value = data[key];

      if      ( key == 'status'             ) { tds[0].innerHTML = build_status_to_HTML( value ) }
      else if ( key == 'identity'           ) { tds[2].innerText =                       value   }
      else if ( key == 'meta'               ) { tds[3].innerHTML = build_status_to_HTML( value ) }
      else if ( key == 'test'               ) { tds[4].innerHTML = build_status_to_HTML( value ) }
      else if ( key == 'started'            ) { tds[5].innerText = formatDate(           value ) }
      else if ( key == 'completed' && value ) { tds[6].innerText = formatDate(           value ) }

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


document.addEventListener('DOMContentLoaded', function () {

  const search_input = document.getElementById("search-input");
  const search_clear = document.getElementById("search-clear");

  const table    = document.getElementsByTagName('table')[0];
  const table_id = table.getAttribute('id');

  const table_pagination = document.getElementById( 'table-pagination' );

  const user_modal_alert_element    = document.getElementById("user-modal-alert");

  const user_info_alert_element     = document.getElementById("user-info-alert");
  const user_password_alert_element = document.getElementById("user-password-alert");
  const user_admin_alert_element    = document.getElementById("user-admin-alert");
  const register_alert_element      = document.getElementById("register-alert");
  const login_alert_element         = document.getElementById("login-alert");
  const logout_alert_element        = document.getElementById("logout-alert");
  const delete_alert_element        = document.getElementById("delete-alert");


  const user_info_form_element     = document.getElementById('user-info-form');
  const user_password_form_element = document.getElementById('user-password-form');
  const user_admin_form_element    = document.getElementById('user-admin-form');
  const register_form_element      = document.getElementById('register-form');
  const login_form_element         = document.getElementById('login-form');
  const logout_form_element        = document.getElementById('logout-form');
  const delete_form_element        = document.getElementById('delete-form');

  const register_modal_element     = document.getElementById('register-modal');
  const login_modal_element        = document.getElementById('login-modal');
  const logout_modal_element       = document.getElementById('logout-modal');
  const delete_modal_element       = document.getElementById('delete-modal');
  const distribution_modal_element = document.getElementById('distribution-modal')
  const build_modal_element        = document.getElementById('build-modal')
  const user_modal_element         = document.getElementById('user-modal');

  const distribution_modal_badge  = document.getElementById('distribution-modal-badge')
  const build_modal_badge         = document.getElementById('build-modal-badge')
  const user_modal_badge          = document.getElementById('user-modal-badge');

  const distribution_modal_delete = document.getElementById('distribution-modal-delete');
  const build_modal_delete        = document.getElementById('build-modal-delete');
  const user_modal_delete         = document.getElementById('user-modal-delete');

  const delete_modal_target_badge = document.getElementById('delete-modal-target-badge');
  const delete_modal_name_badge   = document.getElementById('delete-modal-name-badge');

  const user_info_firstname = document.getElementById('user-info-firstname');
  const user_info_lastname  = document.getElementById('user-info-lastname');
  const user_info_email     = document.getElementById('user-info-email');

  const user_password         = document.getElementById("user-password");
  const user_confirm_password = document.getElementById("user-confirm-password");

  const user_admin = document.getElementById('user-admin');

  const register_modal = new bootstrap.Modal( register_modal_element );
  const login_modal    = new bootstrap.Modal( login_modal_element );
  const logout_modal   = new bootstrap.Modal( logout_modal_element );
  const delete_modal   = new bootstrap.Modal( delete_modal_element );

  const distribution_modal = new bootstrap.Modal( distribution_modal_element );
  const build_modal        = new bootstrap.Modal( build_modal_element );
  const user_modal         = new bootstrap.Modal( user_modal_element );


  const dropzone_modal_element = document.getElementById('dropzone-modal');

  const dropzone_modal = new bootstrap.Modal( dropzone_modal_element );

  const drop_area = document.getElementById('drop-area');
  const drop_area_input = document.getElementById('drop-area-input');

  const build_log = document.getElementById('build-log')


  const ansi = new AnsiUp;

  let timeout;

  search_clear.addEventListener('click', function (e) { search_input.value = '' });

  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(function (event) {
    drop_area.addEventListener(event, function (e) {
      e.preventDefault();
      e.stopPropagation();
    });
  });

  ['dragenter', 'dragover'].forEach(function (event) {
    drop_area.addEventListener(event, function () {
      drop_area.classList.add('highlight');
    });
  });


  ['dragleave', 'drop'].forEach(function (event) {
    drop_area.addEventListener(event, function () {
      drop_area.classList.remove('highlight');
    });
  });

  // Handle dropped files
  drop_area.addEventListener('drop', function (e) {
    e.preventDefault();
    e.stopPropagation();

    // Access the dropped files
    var files = e.dataTransfer.files;

    // Display the files in the file-input field
    drop_area_input.files = files;

    showDropzoneFiles(files);
  });

  const drop_area_submit = document.getElementById('drop-area-submit');

  drop_area_submit.addEventListener('click', function () {
    // Get the selected files
    let files = drop_area_input.files;

    // Create FormData object and append files to it
    const formData = new FormData();
    for (let i = 0; i < files.length; i++) {
      formData.append('file', files[i]);
    }

    // Use Fetch API to send files to the server
    fetch('/api/v' + api_version + '/build', {
      method: 'POST',
      body: formData
    })
      .then(response => response.json()) // Assuming the server responds with JSON
      .then(data => {
        dropzone_modal.hide();
        //document.location.href="/build"
        //data.forEach(addBuild);
        //window.location.reload();
        // Handle the server response as needed
      })
      .catch(error => {
        console.error('Error Processing:', error);
        // Handle errors
      });
  });

  drop_area_input.addEventListener('change', function (event) {

    var files = drop_area_input.files;
    showDropzoneFiles(files)

  });

  function showDropzoneFiles( files ) {

    const drop_area_input_label = drop_area.querySelector('.form-label');
    const progress = drop_area.querySelector('#progress');

    if (files.length > 0) {

      files = [...files];
      progress.innerHTML = '';

      files.forEach((file) => {
        let max = file.size;
        let file_progress_div = '<div class="progress-bar overflow-visible text-dark" style="width: 0%">' + file.name + '</div>';
        let file_progress = '<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="0" aria-valuemin="0" aria-valuemax="' + max + '">'
        file_progress += file_progress_div + '</div>';

        progress.innerHTML += file_progress;

      });
      drop_area_submit.classList.remove('disabled');
    } else {

      drop_area_input_label.innerText = 'Drag and drop your distribution here or click to select a file.';
      drop_area_submit.classList.add('disabled');

    }
  }

  user_modal_element.addEventListener('show.bs.modal', event => {

    const userid = event.relatedTarget.dataset.userId;

    user_modal_alert_element.classList.add( 'd-none'        );
    user_modal_alert_element.classList.add( 'alert-primary' );

    user_info_alert_element.classList.remove( 'alert-success' );
    user_info_alert_element.classList.remove( 'alert-danger'  );
    user_info_alert_element.classList.add(    'alert-primary' );

    user_password_alert_element.classList.remove( 'alert-success' );
    user_password_alert_element.classList.remove( 'alert-danger'  );
    user_password_alert_element.classList.add(    'alert-primary' );

    user_admin_alert_element.classList.remove( 'alert-success' );
    user_admin_alert_element.classList.remove( 'alert-danger'  );
    user_admin_alert_element.classList.add(    'alert-primary' );

    user_info_alert_element.innerHTML     = 'User info!'
    user_password_alert_element.innerHTML = 'Change password!'
    user_admin_alert_element.innerHTML    = 'Make admin!'

    user_password.value         = '';
    user_confirm_password.value = '';

    fetch( '/api/v' + api_version + '/user/' + userid )
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then(data => {

        const id        = data.id;
        const username  = data.username;
        const firstname = data.firstname;
        const lastname  = data.lastname;
        const email     = data.email;
        const admin     = data.admin;

        user_modal_element.dataset.userId = id;

        if ( admin ) {
          const admin_icon = '<i class="bi-person-gear ms-1 text-success"></i>';
          user_modal_badge.innerHTML = username + admin_icon;
        } else {
          user_modal_badge.innerText = username;
        }

        if ( user_modal_delete ) {
          user_modal_delete.setAttribute('data-delete-target', 'user' )
          user_modal_delete.setAttribute('data-delete-id', id )
          user_modal_delete.setAttribute('data-delete-name', username )
        }

        user_info_firstname.value = firstname;
        user_info_lastname.value  = lastname;
        user_info_email.value     = email;

        user_admin.checked = admin;

      } )
      .catch(error => {
        console.error(error);
        user_modal_alert_element.classList.remove( 'alert-primary' );
        user_modal_alert_element.classList.add(    'alert-danger'  );

        user_modal_alert_element.innerText = '<i class="bi bi-x-circle"> ' + error.message;

        user_modal_alert_element.classList.remove( 'd-none'        );
      });

  })


  register_modal_element.addEventListener('show.bs.modal', event => {
    register_alert_element.classList.remove( 'alert-success' );
    register_alert_element.classList.remove( 'alert-danger'  );
    register_alert_element.classList.add(    'alert-primary' );

    register_alert_element.innerHTML = 'Please enter username and password'

  })

  user_info_form_element.addEventListener("submit", (event) => {

    event.preventDefault();

    const userid = user_modal_element.dataset.userId;

    const firstname = user_info_firstname.value;
    const lastname  = user_info_lastname.value;
    const email     = user_info_email.value;

    const body = new URLSearchParams({ 'firstname': firstname, 'lastname': lastname, 'email': email })

    fetch('/api/v' + api_version + '/user/' + userid + '/info', {
      method: 'PUT',
      body: body,
    })
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then( data => {


        user_info_alert_element.classList.remove( 'alert-primary' );
        user_info_alert_element.classList.remove( 'alert-danger'  );
        user_info_alert_element.classList.add(    'alert-success' );

        user_info_alert_element.innerText = 'Success!';

      } )
      .catch(error => {
        console.error(error);

        user_info_alert_element.classList.remove( 'alert-primary' );
        user_info_alert_element.classList.remove( 'alert-success' );
        user_info_alert_element.classList.add(    'alert-danger'  );

        user_info_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + error.message;
      });

  });


  user_password_form_element.addEventListener("submit", (event) => {

    event.preventDefault();

    const userid = user_modal_element.dataset.userId;

    const password         = user_password.value;
    const confirm_password = user_confirm_password.value;

    if ( password != confirm_password ) {

      user_password_alert_element.classList.add( 'alert-danger'  );

      user_password_alert_element.innerHTML = '<i class="bi bi-x-circle"> Passwords do not match!';

      return false;
    }

    const body = new URLSearchParams({ 'password': password })

    fetch('/api/v' + api_version + '/user/' + userid + '/password', {
      method: 'PUT',
      body: body,
    })
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then( data => {


        user_password_alert_element.classList.remove( 'alert-primary' );
        user_password_alert_element.classList.remove( 'alert-danger'  );
        user_password_alert_element.classList.add(    'alert-success' );

        user_password_alert_element.innerText = 'Success!';

      } )
      .catch(error => {
        console.error(error);

        user_password_alert_element.classList.remove( 'alert-primary' );
        user_password_alert_element.classList.remove( 'alert-success' );
        user_password_alert_element.classList.add(    'alert-danger'  );

        user_password_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + error.message;
      });

  });


  user_admin_form_element.addEventListener("submit", (event) => {

    event.preventDefault();

    const userid = user_modal_element.dataset.userId;

    const admin  = user_admin.checked;

    const body = new URLSearchParams({ 'admin': Number( admin ) })

    fetch('/api/v' + api_version + '/user/' + userid + '/admin', {
      method: 'PUT',
      body: body,
    })
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then( data => {

        user_admin_alert_element.classList.remove( 'alert-primary' );
        user_admin_alert_element.classList.remove( 'alert-danger'  );
        user_admin_alert_element.classList.add(    'alert-success' );

        user_admin_alert_element.innerText = 'Success!';

      } )
      .catch(error => {

        user_admin_alert_element.classList.remove( 'alert-primary' );
        user_admin_alert_element.classList.remove( 'alert-success' );
        user_admin_alert_element.classList.add(    'alert-danger'  );

        user_admin_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + error.message;
      } );

  });


  register_form_element.addEventListener("submit", (event) => {

    event.preventDefault();

    const username = document.getElementById("register-username").value;
    const password = document.getElementById("register-password").value;

    const firstname = document.getElementById("register-firstname").value;
    const lastname  = document.getElementById("register-lastname").value;
    const email     = document.getElementById("register-email").value;

    const body = new URLSearchParams({
      'username':  username,
      'password':  password,
      'firstname': firstname,
      'lastname':  lastname,
      'email':     email
    })

    fetch('/api/v' + api_version + '/auth/register', {
      method: 'POST',
      body: body,
    })
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then( data => {

        register_alert_element.classList.remove( 'alert-primary' );
        register_alert_element.classList.remove( 'alert-danger'  );
        register_alert_element.classList.add(    'alert-success' );

        register_alert_element.innerText = 'Success!';

        setTimeout( function( ) {

          register_modal.hide();
          login_modal.show();

        }, 777 );

      } )
      .catch(error => {

        console.error('Error Processing:', error);
        register_alert_element.classList.remove( 'alert-primary' );
        register_alert_element.classList.remove( 'alert-success' );
        register_alert_element.classList.add(    'alert-danger'  );

        register_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + error.message;
      } );

  });


  login_modal_element.addEventListener('show.bs.modal', event => {
    login_alert_element.classList.remove( 'alert-success' );
    login_alert_element.classList.remove( 'alert-danger'  );
    login_alert_element.classList.add(    'alert-primary' );

    login_alert_element.innerHTML = 'Please enter username and password'

  })

  login_form_element.addEventListener("submit", (event) => {

    event.preventDefault();


    let username = document.getElementById("login-username");
    let password = document.getElementById("login-password");

    const body = new URLSearchParams({ 'username': username.value, 'password': password.value })

    fetch('/api/v' + api_version + '/auth/login', {
      method: 'POST',
      body: body,
    })
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then( data => {

        login_alert_element.classList.remove( 'alert-primary' );
        login_alert_element.classList.remove( 'alert-danger'  );
        login_alert_element.classList.add(    'alert-success' );

        login_alert_element.innerText = 'Success!';

        setTimeout( function( ) { window.location.reload(); }, 777 );




      } )
      .catch(error => {

        console.error('Error Processing:', error);
        login_alert_element.classList.remove( 'alert-primary' );
        login_alert_element.classList.remove( 'alert-success' );
        login_alert_element.classList.add(    'alert-danger'  );

        login_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + error.message;
      } );

  });

  logout_modal_element.addEventListener('show.bs.modal', event => {
    logout_alert_element.classList.remove( 'alert-success' );
    logout_alert_element.classList.remove( 'alert-danger'  );
    logout_alert_element.classList.add(    'alert-primary' );

    logout_alert_element.innerHTML = 'Are you sure you want to logout!'

  })

  logout_form_element.addEventListener("submit", (event) => {

    event.preventDefault();

    fetch( '/api/v' + api_version + '/auth/logout' )
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then( data => {

        logout_alert_element.classList.remove( 'alert-primary' );
        logout_alert_element.classList.remove( 'alert-danger'  );
        logout_alert_element.classList.add(    'alert-success' );

        logout_alert_element.innerText = 'Success!';

        setTimeout( function( ) { window.location.href = "/" }, 777 );




      } )
      .catch(error => {

        console.error('Error Processing:', error);
        logout_alert_element.classList.remove( 'alert-primary' );
        logout_alert_element.classList.remove( 'alert-success' );
        logout_alert_element.classList.add(    'alert-danger'  );

        logout_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + error.message;
      } );

  });

  delete_modal_element.addEventListener('show.bs.modal', event => {

    const related_target = event.relatedTarget;

    const delete_target = related_target.dataset.deleteTarget;
    const delete_name   = related_target.dataset.deleteName;
    const delete_id     = related_target.dataset.deleteId;

    delete_modal_target_badge.innerText = delete_target;
    delete_modal_name_badge.innerText   = delete_name;

    delete_alert_element.innerHTML = 'Are you sure you want to delete!';

    delete_alert_element.classList.remove( 'alert-success' );
    delete_alert_element.classList.remove( 'alert-danger'  );
    delete_alert_element.classList.add(    'alert-primary' );

    delete_modal_element.dataset.deleteTarget = delete_target;
    delete_modal_element.dataset.deleteName   = delete_name;
    delete_modal_element.dataset.deleteId     = delete_id;

  });

  delete_form_element.addEventListener("submit", (event) => {

    event.preventDefault();

    const delete_target = delete_modal_element.dataset.deleteTarget;
    const delete_id     = delete_modal_element.dataset.deleteId;

    fetch('/api/v' + api_version + '/' + delete_target + '/' + delete_id, {
      method: 'DELETE'
    })
      .then((response) => {
        if (!response.ok) {
          return response.json().then(data => {
            throw new Error(data.message || 'Something went wrong');
          });
        }
        return response.json();
      })
      .then( data => {

        if ( table_id == delete_target + '-table' ) {

          const query  = document.getElementById('current-page').dataset.query;

          if      ( delete_target == 'distribution' ) { updateDistributionTable( new URLSearchParams( query ) ) }
          else if ( delete_target == 'build'        ) { updateBuildTable(        new URLSearchParams( query ) ) }
          else if ( delete_target == 'user'         ) { updateUserTable(         new URLSearchParams( query ) ) }

        }



        delete_alert_element.classList.remove( 'alert-primary' );
        delete_alert_element.classList.remove( 'alert-danger'  );
        delete_alert_element.classList.add(    'alert-success' );

        delete_alert_element.innerText = 'Success!';

        setTimeout( function( ) {

          delete_modal.hide();

        }, 777 );

      } )
      .catch(error => {

        console.error('Error Processing:', error);
        delete_alert_element.classList.remove( 'alert-primary' );
        delete_alert_element.classList.remove( 'alert-success' );
        delete_alert_element.classList.add(    'alert-danger'  );

        delete_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + error.message;
      } );

  });


  if ( table_id == 'distribution-table' ) {

    search_input.addEventListener("input", (event) => {

      clearTimeout(timeout);

      timeout = setTimeout(function() {

        const name = event.target.value.trim();

        searchDistribution( name )

      }, 800);

    });

    table_pagination.addEventListener('click', function (event) {
      updateDistributionTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
    });


    const distribution_readme  = document.getElementById('distribution-readme')
    const distribution_changes = document.getElementById('distribution-changes')


    distribution_modal_element.addEventListener('show.bs.modal', event => {

      const distribution_row = event.relatedTarget.parentNode;

      const distribution_id = distribution_row.getAttribute('data-distribution-id')

      const distribution_modal_body = distribution_modal_element.querySelector('.modal-body')

      distribution_modal_element.setAttribute('data-distribution-id', distribution_id)

      fetch( '/api/v' + api_version + '/distribution/' + distribution_id )
        .then(response => response.json())
        .then(data => {

          distribution_modal_badge.innerText = data.identity;

          if ( distribution_modal_delete ) {
            distribution_modal_delete.setAttribute('data-delete-target', 'distribution' );
            distribution_modal_delete.setAttribute('data-delete-id', data.id )
            distribution_modal_delete.setAttribute('data-delete-name', data.identity )
          }


          const readme  = data.readme;
          const changes = data.changes;

          if ( readme ) {
            distribution_readme.innerHTML = DOMPurify.sanitize( marked.parse( readme ) );
          }

          if ( changes ) {
            distribution_changes.innerHTML = DOMPurify.sanitize( changes.replace(/(?:\n)/g, '<br>') );
          }

        })
        .catch(error => {
          console.error('Error Processing:', error);
        });

    });

    distribution_modal_element.addEventListener('hidden.bs.modal', event => {

      distribution_modal_badge.innerHTML = '';

      distribution_readme.innerHTML  = '';
      distribution_changes.innerHTML = '';

    });

    updateDistributionTable( )

  } else if ( table_id == 'build-table' ) {

    search_input.addEventListener("input", (event) => {

      clearTimeout(timeout);

      timeout = setTimeout(function() {

        const name = event.target.value.trim();

        searchBuild( name )

      }, 800);

    });

    table_pagination.addEventListener('click', function (event) { 
      updateBuildTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
    });


    const event_source = new EventSource('/server-sent-events');

    build_modal_element.addEventListener('show.bs.modal', event => {

      const buildRow = event.relatedTarget.parentNode;;

      const buildId = buildRow.getAttribute('data-build-id')

      const build_modal_body = build_modal_element.querySelector('.modal-body')


      build_modal_element.setAttribute('data-build-id', buildId)

      fetch( '/api/v' + api_version + '/build/' + buildId )
        .then(response => response.json())
        .then(data => {

          if ( data.identity ) {
            build_modal_badge.innerText = data.identity
          }

          if ( build_modal_delete ) {

            build_modal_delete.setAttribute('data-delete-target', 'build' );
            build_modal_delete.setAttribute('data-delete-id', data.id )
            build_modal_delete.setAttribute('data-delete-name', data.identity )

          }

          if ( data.status == build_status.RUNNING ) {

            build_modal_body.classList.add('autoscrollable-wrapper');

            event_source.addEventListener(buildId, buildEvent)

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

    build_modal_element.addEventListener('hidden.bs.modal', event => {

      const buildId = build_modal_element.getAttribute('data-build-id')

      event_source.removeEventListener(buildId, buildEvent)

      build_modal_badge.innerHTML = '';
      build_log.innerHTML         = '';

     });


    event_source.addEventListener('message',  (event) => {

      const message = JSON.parse(event.data);

      if ( message.operation == 'UPDATE' ) {

        updateBuildTableRow( message.ID, message.build );

      } else if ( message.operation == 'ADD' ) {

        updateBuildTable( new URLSearchParams( document.getElementById('current-page').dataset.query ) );

      }

    });

    const buildEvent = function (event) {

      const element = document.createElement('div');

      element.innerHTML = ansi.ansi_to_html( event.data );
      build_log.appendChild(element);

    }

    event_source.onerror = (err) => {
      console.error("EventSource failed:", err);
    }


    updateBuildTable( )

  } else if ( table_id == 'user-table' ) {

    search_input.addEventListener("input", (event) => {

      clearTimeout(timeout);

      timeout = setTimeout(function() {

        const name = event.target.value.trim();

        searchUser( name )

      }, 800);

    });

    table_pagination.addEventListener('click', function (event) {
      updateUserTable( new URLSearchParams( event.target.getAttribute('data-query') ) )
    });

    updateUserTable( )

  }

});
