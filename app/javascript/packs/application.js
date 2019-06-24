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
  console.log(data)
  const movie = `<li>
    <img src="${data.Poster}" alt="" />
    <p>${data.Title}</p>
    <p>${data.Ratings[0].Value}</p>
  </li>`;
  list.insertAdjacentHTML('beforeend', movie);
};

const fetchMovies = (query) => {
  fetch(`http://www.omdbapi.com/?t=${query}&apikey=b4f8e5fe`)
    .then(response => response.json())
    .then(insertMovies);
};


form.addEventListener('submit', (event) => {
  event.preventDefault();
  fetchMovies(query.value)
});

