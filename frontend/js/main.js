// Import our custom CSS
import '../scss/styles.scss'

// Import all of Bootstrap's JS
import * as bootstrap from 'bootstrap'

document.addEventListener('DOMContentLoaded', function () {

  const dropzone_modal = new bootstrap.Modal(document.getElementById('dropzone-modal'));
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
      console.log(data);
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

});
