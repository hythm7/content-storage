// Import our custom CSS
import '../scss/styles.scss'

// Import all of Bootstrap's JS
import * as bootstrap from 'bootstrap'


const form = document.getElementById('distribution-add-form');

if (form) {
  form.addEventListener('submit', handleSubmit);
}

/** @param {Event} event */
function handleSubmit(event) {
  console.log('handling')
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

  fetch(url, fetchOptions);

  console.log('prevent default')
  event.preventDefault();
  console.log('prevented')
}

  let dropArea                = document.getElementById('drop-area');
  let fileElem                = document.getElementById('fileElem');
  let distributionsProcessing = document.getElementById('distributions-processing');

  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false);
    document.body.addEventListener(eventName, preventDefaults, false);
  });

  ['dragenter', 'dragover'].forEach(eventName => {
    dropArea.addEventListener(eventName, highlight, false);
  });

  ['dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, unhighlight, false);
  });

  dropArea.addEventListener('drop', handleDrop, false);

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  function highlight(e) {
    dropArea.classList.add('highlight');
  }

  function unhighlight(e) {
    dropArea.classList.remove('highlight');
  }

  function handleDrop(e) {
    let dt = e.dataTransfer;
    let files = dt.files;
    handleFiles(files);
  }

  dropArea.addEventListener('click', () => {
    fileElem.click();
  });

  fileElem.addEventListener('change', function (e) {
    handleFiles(this.files);
  });

  function handleFiles(files) {
    files = [...files];
    files.forEach(distributionProcessing);
  }

  function distributionProcessing(file) {
		console.log(file.name)
    let reader = new FileReader();
    reader.readAsText(file);
    reader.onloadend = function () {
      let distribution = document.createElement('label');
      distribution.text = reader.result;
      distributionsProcessing.appendChild(distribution);
    }
  }
