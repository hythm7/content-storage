import {
  searchUser,
  updateUserTable,
} from './common.js';

document.addEventListener('DOMContentLoaded', function () {

  let timeout;

  const user_search_input = document.getElementById('search-input');

  const table_pagination = document.getElementById( 'table-pagination' );

  user_search_input.addEventListener("input", (event) => {

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

});
