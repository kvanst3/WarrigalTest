import "bootstrap";
// import { fetchMovies } from './omdb';

// console.log('Hello World from Webpacker')

//   const form = document.getElementById("keyword");
//   const search = document.getElementById("search-button")

//   search.addEventListener('click', (event) => {
//     event.preventDefault();
//     console.log('Hello World from Webpacker')
// });
const list = document.querySelector('#results');
const form = document.querySelector('#search-movies');
const query = document.getElementById("keyword");

const insertMovies = (data) => {
  data.Search.forEach((result) => {
    const movieTitle = result.Title;
    const movie = `<li class="card">
      <img class="search-img" src="${result.Poster}" alt="" />
      <div id='popup'>Extended info about a user</div>
      <p>${result.Title}</p>
      <div id="create-button"><a data-method="post" href="/movies?title=[${result.Title}]"> Add to Wishlist </a></div>
    </li>`;
    list.insertAdjacentHTML('beforeend', movie);
  });


};

const fetchMovies = (query) => {
  fetch(`http://www.omdbapi.com/?s=${query}&apikey=b4f8e5fe`)
    .then(response => response.json())
    .then(insertMovies);
};


form.addEventListener('submit', (event) => {
  event.preventDefault();
  fetchMovies(query.value)
});



