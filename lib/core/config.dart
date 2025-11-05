const String tmdbReadAccessToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3ODExZTZhNDExNWQwNmNlNmQ1MmVkNWU2ZDk3OWQ2OCIsIm5iZiI6MTc2MjM4NDk0My4zMzcsInN1YiI6IjY5MGJkYzJmZDhmMTg0ODgxY2Y2ZDIwNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Oj62tMQM1ksemktuadInxHBbY7-0Scuf_KOLK52sAW4';

const String tmdbLanguage = String.fromEnvironment(
  'TMDB_LANGUAGE',
  defaultValue: 'es-ES',
);

const String imageBaseUrl = 'https://image.tmdb.org/t/p';
const String posterSize = 'w500';
const String backdropSize = 'w780';
