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
