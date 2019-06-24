const form = document.querySelector('#keyword');
const list = document.querySelector('#results');

form.addEventListener('submit', (event) => {
  event.preventDefault();
  list.innerHTML = '';
  const input = document.querySelector('#keyword');
  fetchMovies(input.value);
});
