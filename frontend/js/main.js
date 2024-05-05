// Import our custom CSS
import '../scss/styles.scss'

// Import all of Bootstrap's JS
import * as bootstrap from 'bootstrap'




var dropArea = document.getElementById('drop-area');
var distributionsArchiveFiles = document.getElementById('distributions-archive-files');
var distributionsAddSubmit = document.getElementById('distributions-add');
const form = document.getElementById('distribution-add-form');

if (dropArea) {
  form.addEventListener('submit', handleSubmit);

// drop area

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
	showDropzoneFiles(files);

	distributionsArchiveFiles.files = files;

});


distributionsArchiveFiles.addEventListener('change', function (event) {

  var files = distributionsArchiveFiles.files;
  showDropzoneFiles(files)

});

function showDropzoneFiles( files ) {

	var distributionsArchiveFilesLabel = document.querySelector('.distributions-archive-files-label');

  if (files.length > 0) {

		files = [...files];
		distributionsArchiveFilesLabel.innerText = '';
		files.forEach((file) => {
			distributionsArchiveFilesLabel.innerText += file.name + "\n";
		});
    distributionsAddSubmit.classList.remove('disabled');
	} else {

		distributionsArchiveFilesLabel.innerText = 'Drag and drop your distribution here or click to select a file.';
    distributionsAddSubmit.classList.add('disabled');

	}


}



/** @param {Event} event */
function handleSubmit(event) {
  /** @type {HTMLFormElement} */

  const form = event.currentTarget;
  const url = new URL(form.action);
  const formData = new FormData(form);
  const searchParams = new URLSearchParams(formData);

  /** @type {Parameters<fetch>[1]} */
  const fetchOptions = {
    method: form.method,
  };

  if (form.method.toLowerCase() === 'post') {
    if (form.enctype === 'multipart/form-data') {
      fetchOptions.body = formData;
    } else {
      fetchOptions.body = searchParams;
    }
  } else {
    url.search = searchParams;
  }

	fetch(url, fetchOptions)
		.then(response => response.json()) // Assuming the server responds with JSON
		.then(data => {
			console.log('Upload successful:', data);
			// Handle the server response as needed
		})
		.catch(error => {
			console.error('Error uploading files:', error);
			// Handle errors
		});
	event.preventDefault();
}

//  function distributionProcessing(file) {
//		console.log(file.name)
//    let reader = new FileReader();
//    reader.readAsText(file);
//    reader.onloadend = function () {
//      let distribution = document.createElement('label');
//      distribution.text = reader.result;
//      distributionsProcessing.appendChild(distribution);
//    }
//  }

}
