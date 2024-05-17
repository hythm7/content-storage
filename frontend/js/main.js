// Import our custom CSS
import '../scss/styles.scss'

// Import all of Bootstrap's JS
import * as bootstrap from 'bootstrap'

document.addEventListener('DOMContentLoaded', function () {

  const dropzoneModal = new bootstrap.Modal(document.getElementById('dropzone-modal'));
  const dropArea = document.getElementById('drop-area');
  const fileInput = document.getElementById('file-input');

  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(function (event) {
    dropArea.addEventListener(event, function (e) {
      e.preventDefault();
      e.stopPropagation();
    });
  });

  ['dragenter', 'dragover'].forEach(function (event) {
    dropArea.addEventListener(event, function () {
      dropArea.classList.add('highlight');
    });
  });


  ['dragleave', 'drop'].forEach(function (event) {
    dropArea.addEventListener(event, function () {
      dropArea.classList.remove('highlight');
    });
  });

// Handle dropped files
  dropArea.addEventListener('drop', function (e) {
    e.preventDefault();
    e.stopPropagation();

    // Access the dropped files
    var files = e.dataTransfer.files;

    // Display the files in the file-input field
    fileInput.files = files;

    showDropzoneFiles(files);
  });

  var submitButton = document.getElementById('submit-button');
 // Handle submit button click event
  submitButton.addEventListener('click', function () {
    // Get the selected files
    var files = fileInput.files;

    // Create FormData object and append files to it
    var formData = new FormData();
    for (var i = 0; i < files.length; i++) {
      formData.append('file-input', files[i]);
    }

    // Use Fetch API to send files to the server
    fetch('/build', {
      method: 'POST',
      body: formData
    })
    .then(response => response.json()) // Assuming the server responds with JSON
    .then(data => {
      console.log(data);
      dropzoneModal.hide();
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

  fileInput.addEventListener('change', function (event) {

    var files = fileInput.files;
    showDropzoneFiles(files)

  });

  function showDropzoneFiles( files ) {

    var fileInputLabel = document.querySelector('.form-label');
    var progress = dropArea.querySelector('#progress');

    if (files.length > 0) {

      files = [...files];
      progress.innerHTML = '';

      files.forEach((file) => {
        var max = file.size;
        var fileProgressDiv = '<div class="progress-bar overflow-visible text-dark" style="width: 0%">' + file.name + '</div>';
        var fileProgress = '<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="0" aria-valuemin="0" aria-valuemax="' + max + '">'
        fileProgress += fileProgressDiv + '</div>';
        
        progress.innerHTML += fileProgress;

      });
      submitButton.classList.remove('disabled');
    } else {

      fileInputLabel.innerText = 'Drag and drop your distribution here or click to select a file.';
      submitButton.classList.add('disabled');

    }
  }

});
