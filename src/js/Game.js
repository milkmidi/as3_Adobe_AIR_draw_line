// import range from 'lodash/range';

const {
  Application,
  Container,
  Graphics,
  Rectangle,
  Text,
} = PIXI;

const WIDTH = 1136;
const HEIGHT = 640;
const DEBUG = process.env.NODE_ENV === 'development';
const FLAT_COLOR = [
  0xb3d01e, 0xf9644e, 0x117ab1, 0x9b6aea, 0xf0da6b, 0xf9c7d2, 0x0199a4,
  0xc2e2f7, 0xa69162,
  0x1bc6b0, 0xed6464, 0x3498db,
];

/**
 * @typedef {Object} LineData
 * @property {number} y
 * @property {number} id
 * @property {number} toID
 */


class Line extends Container {
  /** @type {number}  */
  color;
  /** @type {number}  */
  id;
  constructor(id, color) {
    super();
    this.id = id;
    this.color = color;
    const g = new Graphics();
    g.beginFill(0x2bbcb5, 1);
    g.drawRect(-15, 20, 30, HEIGHT - 80);
    this.addChild(g);

    const style = new PIXI.TextStyle({
      fill: color,
    });
    const text = new Text(`${id + 1}`, style);
    text.y = HEIGHT - 30;
    text.anchor.set(0.5);
    this.addChild(text);
  }
}
const round2 = (value) => {
  const r = Math.round(value);
  return r - (r % 10);
};

class Game {
  app;
  stage;
  startPoint = {
    x: 0,
    y: 0,
    id: -1,
  }

  /** @type {LineData[]} */
  lineObjArr = [];

  /** @type {Line[]} */
  lineArr = [];

  isBallMoving = false;
  currentBallID = 0;

  constructor(count = 14) {
    console.log(count);
    const app = new Application(WIDTH, HEIGHT, {
      backgroundColor: 0xe3e3e3,
      view: document.getElementById('canvas-wrap'),
    });
    this.app = app;
    const { stage } = app;
    stage.interactive = true;
    stage.hitArea = new Rectangle(0, 0, WIDTH, HEIGHT);
    this.stage = stage;


    this.createLine(count);

    this.bridgeGraphic = new Graphics();

    stage.addChild(this.bridgeGraphic);

    this.lineAvator = new Graphics();
    stage.addChild(this.lineAvator);

    this.moveBall = new Graphics();
    this.moveBall.beginFill(0);
    this.moveBall.drawCircle(0, 0, 10);
    this.stage.addChild(this.moveBall);
    this.createStartButton();

    if (DEBUG) {
      this.debugMode();
    }
  }
  debugMode() {
    console.log('Debug Mode');
    for (let i = 0; i < 30; i++) {
      let index = Math.random() * this.lineArr.length | 0;
      let line = this.lineArr[index];
      const y = Math.random() * (HEIGHT - 100) + 40;
      this.startDrawMode({ x: line.x, y }, line.id);
      //
      index = Math.random() * this.lineArr.length | 0;
      line = this.lineArr[index];
      this.createBridgeLine({ x: line.x, y }, line.id);
    }
    this.stageMouseupHandler();
  }
  createStartButton() {
    const startBTN = new Graphics();
    startBTN.beginFill(0xFFFF0B);
    startBTN.drawCircle(40, 40, 30);
    startBTN.endFill();
    startBTN.interactive = true;
    startBTN.on('click', () => {
      this.lineObjArr.sort((a, b) => a.y - b.y);
      console.log(this.lineObjArr);
      const index = (Math.random() * this.lineArr.length) | 0; // eslint-disable-line
      this.currentBallID = index;
      this.moveBall.x = this.lineArr[index].x;
      this.isBallMoving = true;
    });
    this.stage.addChild(startBTN);
  }
  start() {
    console.log('start');
    this.app.ticker.add((delta) => {
      if (!this.isBallMoving) {
        return;
      }
      const ballY = Math.floor(this.moveBall.y + 1);
      this.moveBall.y = ballY;
      if (this.lineObjArr.length === 0) {
        this.isBallMoving = false;
        return;
      }
      const obj = this.lineObjArr[0];
      const { id, toID, y } = obj;
      let targetX = -1;
      if (ballY === y) {
        if (this.currentBallID === id) {
          targetX = this.lineArr[toID].x;
          this.currentBallID = toID;
        } else if (this.currentBallID === toID) {
          targetX = this.lineArr[id].x;
          this.currentBallID = id;
        }
        this.lineObjArr.shift();
        if (targetX !== -1) {
          this.isBallMoving = false;
          TweenMax.to(this.moveBall, 1, { x: targetX,
            onComplete() { this.isBallMoving = true; },
            onCompleteScope: this,
          });
        }
      }
    });
  }
  removeUnuseLineData() {

  }
  stageMouseupHandler = () => {
    this.stage.off('mouseup', this.stageMouseupHandler);
    this.stage.off('mousemove', this.stageMousemoveHandler);
    this.lineAvator.clear();
  }
  stageMousemoveHandler = (e) => {
    const { x, y } = e.data.global;
    this.lineAvator.clear();
    this.lineAvator.lineStyle(10, 0);
    this.lineAvator.moveTo(this.startPoint.x, this.startPoint.y);
    this.lineAvator.lineTo(x, y);
  }
  startDrawMode({ x, y }, id) {
    this.startPoint = { x, y, id };
    this.stage.on('mouseup', this.stageMouseupHandler);
    this.stage.on('mousemove', this.stageMousemoveHandler);
  }

  createBridgeLine({ x, y }, toID) {
    const { id } = this.startPoint;
    const sx = round2(this.startPoint.x);
    const sy = round2(this.startPoint.y);
    const x2 = sx - x;
    const y2 = sy - y;
    const length = Math.sqrt((x2 * x2) + (y2 * y2));
    if (length > 40 && toID !== id) {
      const index = Math.random() * FLAT_COLOR.length | 0;
      const color = FLAT_COLOR[index];
      this.bridgeGraphic.lineStyle(5, color);
      this.bridgeGraphic.moveTo(sx, sy);
      this.bridgeGraphic.lineTo(round2(x), sy);
      this.lineObjArr.push({ y: sy, toID, id });
    }
  }

  createLine(count) {
    const gap = WIDTH / (count + 1);
    for (let i = 0; i < count; i++) {
      const color = FLAT_COLOR[i % FLAT_COLOR.length];
      const line = new Line(i, color);
      line.x = gap * (i + 1);
      line.interactive = true;
      line.on('mousedown', (e) => {
        this.startDrawMode(e.data.global, e.currentTarget.id);
      });
      line.on('mouseup', (e) => {
        this.createBridgeLine(e.data.global, e.currentTarget.id);
      });
      this.stage.addChild(line);
      this.lineArr.push(line);
    }
  }
}

export default Game;
