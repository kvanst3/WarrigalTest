import "bootstrap";

require('dotenv').config();

// import { fetchMovies } from './omdb';


const list = document.querySelector('#results');
const form = document.querySelector('#search-movies');
const query = document.getElementById("keyword");
const omdbkey = document.getElementById('search-movies').dataset.omdbid;

const insertMovies = (data) => {
  list.innerHTML = "";
  data.Search.forEach((result) => {
    const movieTitle = result.Title;
    const movie = `<li class="card">
      <img class="search-img" src="${result.Poster}" alt="" />
      <p>${result.Title}</p>
      <div id="create-button"><a data-method="post" href="/movies?id=${result.imdbID}"> Add to Wishlist </a></div>
    </li>`;
    list.insertAdjacentHTML('beforeend', movie);
  });


};

const fetchMovies = (query) => {
  fetch(`https://www.omdbapi.com/?s=${query}&apikey=${omdbkey}`)
    .then(response => response.json())
    .then(insertMovies);
};
//process.env['OMDB_KEY']

form.addEventListener('submit', (event) => {
  event.preventDefault();
  fetchMovies(query.value)
});



