import { TILES, COLORS, CANVAS_WIDTH, CANVAS_HEIGHT } from "./constants.js";
import { sprites, drawSprite } from "./sprites.js";

function getTileSprite(tile) {
  switch (tile) {
    case TILES.GRASS: return sprites.grass;
    case TILES.WATER: return sprites.water;
    case TILES.TREE: return sprites.tree;
    case TILES.PATH: return sprites.path;
    case TILES.WALL: return sprites.wall;
    case TILES.DUNGEON_FLOOR: return sprites.dungeonFloor;
    case TILES.DUNGEON_WALL: return sprites.dungeonWall;
    case TILES.DOOR: return sprites.door;
    case TILES.STAIRS_DOWN:
    case TILES.STAIRS_UP: return sprites.stairs;
    default: return sprites.grass;
  }
}

export function drawMap(ctx, map, cameraX, cameraY, time, doorOpen) {
  const TILE_SIZE = 32;
  const startCol = Math.floor(cameraX / TILE_SIZE);
  const startRow = Math.floor(cameraY / TILE_SIZE);
  const endCol = startCol + Math.ceil(ctx.canvas.width / TILE_SIZE) + 1;
  const endRow = startRow + Math.ceil(ctx.canvas.height / TILE_SIZE) + 1;

  for (let row = startRow; row <= endRow; row++) {
    for (let col = startCol; col <= endCol; col++) {
      if (row < 0 || col < 0 || row >= map.length || col >= map[0].length) continue;

      let tile = map[row][col];
      if (tile === TILES.DOOR && doorOpen) tile = TILES.PATH;

      const x = col * TILE_SIZE - cameraX;
      const y = row * TILE_SIZE - cameraY;

      const sprite = getTileSprite(tile);
      ctx.drawImage(sprite, x, y, TILE_SIZE, TILE_SIZE);

      if (tile === TILES.WATER) {
        const wave = Math.sin(time * 2 + col * 0.5) * 2;
        ctx.fillStyle = "rgba(66, 153, 225, 0.3)";
        ctx.fillRect(x + 4, y + 12 + wave, TILE_SIZE - 8, 3);
      }
    }
  }
}

export function drawDialog(ctx, text) {
  const padding = 12;
  const boxHeight = 48;
  const boxY = ctx.canvas.height - boxHeight - 16;

  ctx.fillStyle = "rgba(0, 0, 0, 0.75)";
  ctx.fillRect(16, boxY, ctx.canvas.width - 32, boxHeight);
  ctx.strokeStyle = "#ffd700";
  ctx.lineWidth = 2;
  ctx.strokeRect(16, boxY, ctx.canvas.width - 32, boxHeight);

  ctx.fillStyle = "#fff";
  ctx.font = "14px Courier New, monospace";
  const maxW = ctx.canvas.width - 64;
  if (ctx.measureText(text).width > maxW) {
    const words = text.split(" ");
    let line = "";
    let lineY = boxY + 22;
    for (const word of words) {
      const test = line + word + " ";
      if (ctx.measureText(test).width > maxW) {
        ctx.fillText(line, 16 + padding, lineY);
        line = word + " ";
        lineY += 16;
      } else {
        line = test;
      }
    }
    ctx.fillText(line, 16 + padding, lineY);
  } else {
    ctx.fillText(text, 16 + padding, boxY + 28);
  }
}

export function drawHud(ctx, player, mapName) {
  // Map name
  ctx.fillStyle = "rgba(0,0,0,0.5)";
  ctx.fillRect(8, 8, 100, 22);
  ctx.fillStyle = "#ffd700";
  ctx.font = "12px Courier New, monospace";
  ctx.fillText(mapName, 14, 23);

  // HP bar
  const barX = 8;
  const barY = 36;
  const barW = 120;
  const barH = 14;
  const ratio = player.hp / player.maxHp;

  ctx.fillStyle = COLORS.hpBarBg;
  ctx.fillRect(barX, barY, barW, barH);
  ctx.fillStyle = ratio > 0.3 ? COLORS.hpBar : "#ff0000";
  ctx.fillRect(barX, barY, barW * ratio, barH);
  ctx.strokeStyle = "#fff";
  ctx.lineWidth = 1;
  ctx.strokeRect(barX, barY, barW, barH);

  ctx.fillStyle = "#fff";
  ctx.font = "10px Courier New, monospace";
  ctx.fillText(`HP ${player.hp}/${player.maxHp}`, barX + 4, barY + 11);
}

export function drawGameOver(ctx) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.7)";
  ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
  ctx.fillStyle = "#e53e3e";
  ctx.font = "bold 28px Courier New, monospace";
  ctx.textAlign = "center";
  ctx.fillText("GAME OVER", CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 - 10);
  ctx.fillStyle = "#aaa";
  ctx.font = "14px Courier New, monospace";
  ctx.fillText("Refresh to try again", CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 20);
  ctx.textAlign = "left";
}

export function drawPrompt(ctx, x, y, text) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.6)";
  const w = ctx.measureText(text).width + 8;
  ctx.fillRect(x - 4, y - 14, w, 18);
  ctx.fillStyle = "#fff";
  ctx.font = "11px Courier New, monospace";
  ctx.fillText(text, x, y);
}
