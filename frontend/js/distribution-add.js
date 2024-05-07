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


const evtSource = new EventSource('/distribution/build');

evtSource.onerror = (err) => {
	console.error("EventSource failed:", err);
};

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
		//.then(response => response.json()) // Assuming the server responds with JSON
		//.then(data => {
			//const distributionsBuildsTable = document.getElementById("distributions-builds-table");

      //  var tableBody = distributionsBuildsTable.getElementsByTagName('tbody')[0]
			//	data.forEach((build, index) => {

			//	tableBody.innerHTML += '<tr><td>' + index + '</td><td>' + build.status + '</td><td>' + build.filename + '</td></tr>'
			//} )


			// Handle the server response as needed

			//evtSource.addEventListener(data.id, (event) => {
			//	const newElement = document.createElement("li");
			//	const eventList = document.getElementById("distributions-builds");

			//	newElement.textContent = event.data;
			//	eventList.appendChild(newElement);
			//});


		//})
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

evtSource.addEventListener('message',  (event) => {

	console.log(`message: ${event.data}`);
});

	const buildModal = document.getElementById('buildModal')
  const buildModalBody = buildModal.querySelector('.modal-body')

	var buildEvent = function (event) {

			const newElement = document.createElement("li");

			newElement.textContent = event.data;
			buildModalBody.appendChild(newElement);

	}

	buildModal.addEventListener('show.bs.modal', event => {

    var build = event.relatedTarget;
    var buildStatus = build.getAttribute('data-build-status')
    var buildId = build.getAttribute('data-build-id')

    buildModal.setAttribute('data-build-id', buildId)
		// do something...

		evtSource.addEventListener(buildId, buildEvent, false)
		//evtSource.addEventListener(buildId, (event) => {
		//	const newElement = document.createElement("li");

		//	newElement.textContent = event.data;
		//	buildModalBody.appendChild(newElement);
		//});
	})

	buildModal.addEventListener('hidden.bs.modal', event => {

    var buildId = buildModal.getAttribute('data-build-id')

		evtSource.removeEventListener(buildId, buildEvent, false)
    var buildModalBody = buildModal.querySelector('.modal-body')
	  buildModalBody.innerHTML = '';
	})

}
