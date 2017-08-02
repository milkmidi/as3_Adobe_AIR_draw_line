import '../css/app.scss';
import Game from './Game';

console.log('-------- app.js ---------');


const startClickHandler = () => {
  let { value } = document.querySelector('input');
  if (value === '') {
    value = 10;
  }
  console.log('start', value);
  document.body.classList.add('game');
  const game = new Game(value / 1);
  game.start();
};

document.querySelector('button').addEventListener('click', startClickHandler);

if (process.env.NODE_ENV === 'development') {
  // eslint-disable-next-line
  require('!!raw-loader!../html/index.pug');
  startClickHandler();
}

