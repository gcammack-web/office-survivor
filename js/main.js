import { Game } from "./game.js";
import { ensureAudio } from "./audio.js";

const canvas = document.getElementById("game");
const game = new Game(canvas);

let lastTime = 0;

window.addEventListener("keydown", () => ensureAudio(), { once: false });

function loop(timestamp) {
  const dt = Math.min((timestamp - lastTime) / 1000, 0.05);
  lastTime = timestamp;

  game.update(dt);
  game.draw();

  requestAnimationFrame(loop);
}

requestAnimationFrame(loop);
