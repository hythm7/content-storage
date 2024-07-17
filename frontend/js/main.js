// Import our custom CSS
import '../scss/style.scss'

// Import all of Bootstrap's JS
import * as bootstrap from 'bootstrap'

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
})()

document.addEventListener('DOMContentLoaded', function () {

  const register_alert_element = document.getElementById("register-alert");
  const login_alert_element    = document.getElementById("login-alert");
  const logout_alert_element   = document.getElementById("logout-alert");

  const register_form_element = document.getElementById('register-form');
  const login_form_element    = document.getElementById('login-form');
  const logout_form_element   = document.getElementById('logout-form');

  const register_modal_element = document.getElementById('register-modal');
  const login_modal_element    = document.getElementById('login-modal');
  const logout_modal_element   = document.getElementById('logout-modal');

  const register_modal = new bootstrap.Modal( register_modal_element );
  const login_modal    = new bootstrap.Modal( login_modal_element );
  const logout_modal   = new bootstrap.Modal( logout_modal_element );

  const dropzone_modal_element = document.getElementById('dropzone-modal');

  const dropzone_modal = new bootstrap.Modal( dropzone_modal_element );

  const drop_area = document.getElementById('drop-area');
  const drop_area_input = document.getElementById('drop-area-input');


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
    fetch('/api/v1/build', {
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

  register_modal_element.addEventListener('show.bs.modal', event => {
    register_alert_element.classList.remove( 'alert-success' );
    register_alert_element.classList.remove( 'alert-danger'  );
    register_alert_element.classList.add(    'alert-primary' );

    register_alert_element.innerHTML = 'Please enter username and password'

  })

  register_form_element.addEventListener("submit", (event) => {

    event.preventDefault();

    let username = document.getElementById("register-username");
    let password = document.getElementById("register-password");

    const body = new URLSearchParams({ 'username': username.value, 'password': password.value })

    fetch('/api/v1/auth/register', {
      method: 'POST',
      body: body,
    })
    .then( response => response.json().then( data => ( { ok: response.ok, body: data } ) ) )
    .then( data => {

      if ( data.ok ) {

        register_alert_element.classList.remove( 'alert-primary' );
        register_alert_element.classList.remove( 'alert-danger'  );
        register_alert_element.classList.add(    'alert-success' );

        register_alert_element.innerText = 'Success!';

        setTimeout( function( ) {

          register_modal.hide();
          login_modal.show();

        }, 777 );

      } else {

        register_alert_element.classList.remove( 'alert-primary' );
        register_alert_element.classList.remove( 'alert-success' );
        register_alert_element.classList.add(    'alert-danger'  );

        register_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + data.body.message;

      }

    } )
    .catch(error => {

      console.error('Error Processing:', error);
      // Handle errors
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

    fetch('/api/v1/auth/login', {
      method: 'POST',
      body: body,
    })
    .then( response => response.json().then( data => ( { ok: response.ok, body: data } ) ) )
    .then( data => {

      if ( data.ok ) {

        login_alert_element.classList.remove( 'alert-primary' );
        login_alert_element.classList.remove( 'alert-danger'  );
        login_alert_element.classList.add(    'alert-success' );

        login_alert_element.innerText = 'Success!';

        setTimeout( function( ) { window.location.reload(); }, 777 );

      } else {

        login_alert_element.classList.remove( 'alert-primary' );
        login_alert_element.classList.remove( 'alert-success' );
        login_alert_element.classList.add(    'alert-danger'  );

        login_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + data.body.message;

      }

    } )
    .catch(error => {

      console.error('Error Processing:', error);
      // Handle errors
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

    fetch( '/api/v1/auth/logout' )
    .then( response => response.json().then( data => ( { ok: response.ok, body: data } ) ) )
    .then( data => {

      if ( data.ok ) {

        logout_alert_element.classList.remove( 'alert-primary' );
        logout_alert_element.classList.remove( 'alert-danger'  );
        logout_alert_element.classList.add(    'alert-success' );

        logout_alert_element.innerText = 'Success!';

        setTimeout( function( ) { window.location.reload(); }, 777 );

      } else {

        logout_alert_element.classList.remove( 'alert-primary' );
        logout_alert_element.classList.remove( 'alert-success' );
        logout_alert_element.classList.add(    'alert-danger'  );

        logout_alert_element.innerHTML = '<i class="bi bi-x-circle"> ' + data.body.message;

      }

    } )
    .catch(error => {

      console.error('Error Processing:', error);
      // Handle errors
    } );

  });

});
