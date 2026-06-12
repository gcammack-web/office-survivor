import { TILES, TILE_SIZE, MAP_IDS } from "./constants.js";

export const OVERWORLD_MAP = [
  [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4],
  [4,0,0,0,0,0,2,0,0,3,3,3,0,0,2,0,0,0,0,4],
  [4,0,2,0,0,0,2,0,0,3,0,3,0,0,0,0,2,0,0,4],
  [4,0,0,0,1,1,1,0,0,3,0,3,0,1,1,0,0,0,0,4],
  [4,0,0,0,1,1,1,0,0,3,3,3,0,1,1,0,0,2,0,4],
  [4,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
  [4,0,0,0,0,0,0,2,0,0,0,0,2,0,0,0,0,0,0,4],
  [4,3,3,3,3,3,0,0,0,2,0,0,0,0,3,3,3,3,0,4],
  [4,3,0,0,0,3,0,0,0,0,0,0,0,0,3,0,0,3,0,4],
  [4,3,0,0,0,3,0,0,0,0,0,0,0,0,3,0,0,3,7,4],
  [4,3,3,3,0,3,0,2,0,0,0,0,2,0,3,0,3,3,0,4],
  [4,0,0,3,0,3,0,0,0,0,0,0,0,0,3,0,3,0,0,4],
  [4,0,0,3,0,3,3,3,3,3,3,3,3,3,3,0,3,0,0,4],
  [4,2,0,3,0,0,0,0,0,0,0,0,0,0,0,0,3,0,2,4],
  [4,0,0,3,3,3,0,0,0,0,0,0,0,0,3,3,3,0,0,4],
  [4,0,0,0,0,0,0,2,0,0,0,0,2,0,0,0,0,0,0,4],
  [4,0,2,0,0,0,0,0,0,1,1,0,0,0,0,0,0,2,0,4],
  [4,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,4],
  [4,0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0,0,0,4],
  [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4],
];

export const DUNGEON_MAP = [
  [6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6],
  [6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,5,5,5,6,6,6,5,5,6,6,6,5,5,5,6],
  [6,5,5,5,6,5,5,5,5,5,5,6,5,5,5,6],
  [6,5,5,5,6,5,5,5,5,5,5,6,5,5,5,6],
  [6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,5,5,6,6,5,5,5,5,5,5,6,6,5,5,6],
  [6,5,5,6,5,5,5,5,5,5,5,5,6,5,5,6],
  [6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,5,5,5,5,5,6,6,6,6,5,5,5,5,5,6],
  [6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,8,5,5,5,5,5,5,5,5,5,5,5,5,5,6],
  [6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6],
];

export const MAPS = {
  [MAP_IDS.OVERWORLD]: {
    id: MAP_IDS.OVERWORLD,
    data: OVERWORLD_MAP,
    name: "Village",
    spawn: { x: 5 * TILE_SIZE + 2, y: 5 * TILE_SIZE + 2 },
    musicTheme: "overworld",
  },
  [MAP_IDS.DUNGEON]: {
    id: MAP_IDS.DUNGEON,
    data: DUNGEON_MAP,
    name: "Dungeon",
    spawn: { x: 1 * TILE_SIZE + 2, y: 14 * TILE_SIZE + 2 },
    musicTheme: "dungeon",
  },
};

export function isSolid(tile, doorOpen = false) {
  if (tile === TILES.DOOR) return !doorOpen;
  return (
    tile === TILES.WATER ||
    tile === TILES.TREE ||
    tile === TILES.WALL ||
    tile === TILES.DUNGEON_WALL
  );
}

export function getTile(map, col, row) {
  if (row < 0 || col < 0 || row >= map.length || col >= map[0].length) {
    return TILES.WALL;
  }
  return map[row][col];
}

export function checkCollision(map, x, y, size, doorOpen = false) {
  const margin = 2;
  const left = Math.floor((x + margin) / TILE_SIZE);
  const right = Math.floor((x + size - margin - 1) / TILE_SIZE);
  const top = Math.floor((y + margin) / TILE_SIZE);
  const bottom = Math.floor((y + size - margin - 1) / TILE_SIZE);

  for (let row = top; row <= bottom; row++) {
    for (let col = left; col <= right; col++) {
      if (isSolid(getTile(map, col, row), doorOpen)) {
        return true;
      }
    }
  }
  return false;
}

export function getTileAt(map, x, y) {
  const col = Math.floor(x / TILE_SIZE);
  const row = Math.floor(y / TILE_SIZE);
  return getTile(map, col, row);
}

export function getDoorPosition(mapId) {
  if (mapId === MAP_IDS.OVERWORLD) return { col: 18, row: 9 };
  return null;
}

export function getStairsPosition(mapId) {
  if (mapId === MAP_IDS.DUNGEON) return { col: 1, row: 14 };
  return null;
}
