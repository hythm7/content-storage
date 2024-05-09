document.addEventListener('DOMContentLoaded', function () {

  var dropArea = document.getElementById('drop-area');
  var fileInput = document.getElementById('file-input');

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
    console.log(files);

    // Create FormData object and append files to it
    var formData = new FormData();
    for (var i = 0; i < files.length; i++) {
      formData.append('file-input', files[i]);
    }

    // Use Fetch API to send files to the server
    fetch('/distribution/add', {
      method: 'POST',
      body: formData
    })
      //.then(response => response.json()) // Assuming the server responds with JSON
      .then(data => {
        console.log('Upload successful:', data);
				window.location.reload();
        // Handle the server response as needed
      })
      .catch(error => {
        console.error('Error uploading files:', error);
        // Handle errors
      });
  });

	fileInput.addEventListener('change', function (event) {

		var files = fileInput.files;
		showDropzoneFiles(files)

	});

	function showDropzoneFiles( files ) {

    var fileInputLabel = document.querySelector('.form-label');

		if (files.length > 0) {

			files = [...files];
			fileInputLabel.innerText = '';
			files.forEach((file) => {
				fileInputLabel.innerText += file.name + "\n";
			});
			submitButton.classList.remove('disabled');
		} else {

			fileInputLabel.innerText = 'Drag and drop your distribution here or click to select a file.';
			submitButton.classList.add('disabled');

		}


	}


	const evtSource = new EventSource('/distribution/build');

	evtSource.onerror = (err) => {
		console.error("EventSource failed:", err);
	};


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

		evtSource.addEventListener(buildId, buildEvent, false)

	})

	buildModal.addEventListener('hidden.bs.modal', event => {

		var buildId = buildModal.getAttribute('data-build-id')

		evtSource.removeEventListener(buildId, buildEvent, false)

		var buildModalBody = buildModal.querySelector('.modal-body')
		buildModalBody.innerHTML = '';

	})
});
