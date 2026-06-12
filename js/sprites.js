// Pixel-art sprites: each row is a string of hex chars (0 = transparent)
const PALETTE = {
  a: "#ffd700", b: "#b8860b", c: "#333333", d: "#ffffff",
  e: "#e53e3e", f: "#742a2a", g: "#48bb78", h: "#276749",
  i: "#e2e8f0", j: "#718096", k: "#00ffff", l: "#7fdbff",
  m: "#3d8c40", n: "#2d6b30", o: "#22543d", p: "#744210",
  q: "#2b6cb0", r: "#4299e1", s: "#c4a35a", t: "#a08040",
  u: "#4a5568", v: "#2d3748", w: "#3d3d5c", x: "#4a4a6a",
  y: "#2d2d44", z: "#8b4513", "1": "#ff6b6b", "2": "#c53030",
};

function buildSprite(rows, scale = 2) {
  const h = rows.length;
  const w = rows[0].length;
  const canvas = document.createElement("canvas");
  canvas.width = w * scale;
  canvas.height = h * scale;
  const ctx = canvas.getContext("2d");
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const ch = rows[y][x];
      if (ch === "0") continue;
      ctx.fillStyle = PALETTE[ch] || "#ff00ff";
      ctx.fillRect(x * scale, y * scale, scale, scale);
    }
  }
  return canvas;
}

const SPRITE_DATA = {
  playerDown: [
    "000000000000",
    "0000bbbb0000",
    "000bbbbbbb00",
    "000bbbbbbb00",
    "0000aaaa0000",
    "0000aaaa0000",
    "00bbaaaabb00",
    "00bbaaaabb00",
    "0000aaaa0000",
    "0000aaaa0000",
    "000abbba0000",
    "000000000000",
  ],
  playerUp: [
    "000000000000",
    "0000bbbb0000",
    "000bbbbbbb00",
    "000bbbbbbb00",
    "0000aaaa0000",
    "0000aaaa0000",
    "00bbaaaabb00",
    "00bbaaaabb00",
    "000ccccc0000",
    "000ccccc0000",
    "000000000000",
    "000000000000",
  ],
  playerLeft: [
    "000000000000",
    "0000bbbb0000",
    "000bbbbbbb00",
    "000bbbbbbb00",
    "0000aaaa0000",
    "0000aaaa0000",
    "00bbaaaabb00",
    "00bbaaaabb00",
    "0000aaaa0000",
    "000ccccc0000",
    "000000000000",
    "000000000000",
  ],
  playerRight: [
    "000000000000",
    "0000bbbb0000",
    "000bbbbbbb00",
    "000bbbbbbb00",
    "0000aaaa0000",
    "0000aaaa0000",
    "00bbaaaabb00",
    "00bbaaaabb00",
    "0000aaaa0000",
    "000ccccc0000",
    "000000000000",
    "000000000000",
  ],
  npc: [
    "000000000000",
    "0000ffff0000",
    "000feeeee000",
    "000feeeee000",
    "0000eeee0000",
    "0000eeee0000",
    "00eeeee00000",
    "00eeeee00000",
    "0000eeee0000",
    "0000eeee0000",
    "000000000000",
    "000000000000",
  ],
  slime: [
    "000000000000",
    "000000000000",
    "0000gggg0000",
    "000gggggg000",
    "00gggggggg00",
    "00ggccgggg00",
    "00gggggggg00",
    "000gggghg000",
    "0000gggg0000",
    "000000000000",
    "000000000000",
    "000000000000",
  ],
  skeleton: [
    "000000000000",
    "0000iiii0000",
    "000iiiiii000",
    "000iiiiii000",
    "0000cccc0000",
    "0000iiii0000",
    "00iiiiiiii00",
    "00iiiiiiii00",
    "0000iiii0000",
    "000jjjj00000",
    "000000000000",
    "000000000000",
  ],
  gem: [
    "000000000000",
    "00000kk00000",
    "0000kllk0000",
    "000kllllk000",
    "000kllllk000",
    "0000kllk0000",
    "00000kk00000",
    "000000000000",
    "000000000000",
    "000000000000",
    "000000000000",
    "000000000000",
  ],
  potion: [
    "000000000000",
    "00000dd00000",
    "0000dddd0000",
    "000011110000",
    "000011110000",
    "000011110000",
    "000011110000",
    "000011110000",
    "000011110000",
    "000000000000",
    "000000000000",
    "000000000000",
  ],
  sword: [
    "000000000000",
    "0000000d0000",
    "000000dd0000",
    "00000ddd0000",
    "0000ddd00000",
    "000ddd000000",
    "00ddd0000000",
    "00bb00000000",
    "00bb00000000",
    "000000000000",
    "000000000000",
    "000000000000",
  ],
  grass: [
    "mmmmmmmmmmmm",
    "mnnmnnmnnmnn",
    "mmmmmmmmmmmm",
    "mnnmnnmnnmnn",
    "mmmmmmmmmmmm",
    "mnnmnnmnnmnn",
    "mmmmmmmmmmmm",
    "mnnmnnmnnmnn",
    "mmmmmmmmmmmm",
    "mnnmnnmnnmnn",
    "mmmmmmmmmmmm",
    "mnnmnnmnnmnn",
  ],
  tree: [
    "0000oooo0000",
    "00oooooooo00",
    "0oooooooooo0",
    "0oooooooooo0",
    "00oooooooo00",
    "0000oooo0000",
    "0000pppp0000",
    "0000pppp0000",
    "0000pppp0000",
    "0000pppp0000",
    "0000pppp0000",
    "000000000000",
  ],
  water: [
    "qqqqqqqqqqqq",
    "qqrrqqrrqqrr",
    "qqqqqqqqqqqq",
    "qqrrqqrrqqrr",
    "qqqqqqqqqqqq",
    "qqrrqqrrqqrr",
    "qqqqqqqqqqqq",
    "qqrrqqrrqqrr",
    "qqqqqqqqqqqq",
    "qqrrqqrrqqrr",
    "qqqqqqqqqqqq",
    "qqrrqqrrqqrr",
  ],
  path: [
    "ssssssssssss",
    "stststststst",
    "ssssssssssss",
    "stststststst",
    "ssssssssssss",
    "stststststst",
    "ssssssssssss",
    "stststststst",
    "ssssssssssss",
    "stststststst",
    "ssssssssssss",
    "stststststst",
  ],
  wall: [
    "uuuuuuuuuuuu",
    "uvuvuvuvuvuv",
    "uuuuuuuuuuuu",
    "uvuvuvuvuvuv",
    "uuuuuuuuuuuu",
    "uvuvuvuvuvuv",
    "uuuuuuuuuuuu",
    "uvuvuvuvuvuv",
    "uuuuuuuuuuuu",
    "uvuvuvuvuvuv",
    "uuuuuuuuuuuu",
    "uvuvuvuvuvuv",
  ],
  dungeonFloor: [
    "wwwwwwwwwwww",
    "wxwxwxwxwxwx",
    "wwwwwwwwwwww",
    "wxwxwxwxwxwx",
    "wwwwwwwwwwww",
    "wxwxwxwxwxwx",
    "wwwwwwwwwwww",
    "wxwxwxwxwxwx",
    "wwwwwwwwwwww",
    "wxwxwxwxwxwx",
    "wwwwwwwwwwww",
    "wxwxwxwxwxwx",
  ],
  dungeonWall: [
    "yyyyyyyyyyyy",
    "yzyzyzyzyzyz",
    "yyyyyyyyyyyy",
    "yzyzyzyzyzyz",
    "yyyyyyyyyyyy",
    "yzyzyzyzyzyz",
    "yyyyyyyyyyyy",
    "yzyzyzyzyzyz",
    "yyyyyyyyyyyy",
    "yzyzyzyzyzyz",
    "yyyyyyyyyyyy",
    "yzyzyzyzyzyz",
  ],
  door: [
    "zzzzzzzzzzzz",
    "z0000000000z",
    "z0zzzzzzzz0z",
    "z0zzzzzzzz0z",
    "z0zzzzzzzz0z",
    "z0zzzzzzzz0z",
    "z0zzzzzzzz0z",
    "z0zzzzzzzz0z",
    "z0zz0000zz0z",
    "z0zz0000zz0z",
    "z0000000000z",
    "zzzzzzzzzzzz",
  ],
  stairs: [
    "000000000000",
    "000jjjj00000",
    "00jjjjjj0000",
    "0jjjjjjjj000",
    "0jjjjjjjj000",
    "00jjjjjj0000",
    "000jjjj00000",
    "000000000000",
    "000000000000",
    "000000000000",
    "000000000000",
    "000000000000",
  ],
};

export const sprites = {};
for (const [name, rows] of Object.entries(SPRITE_DATA)) {
  sprites[name] = buildSprite(rows, 2);
}

export function drawSprite(ctx, sprite, x, y, w = 24, h = 24) {
  ctx.drawImage(sprite, x, y, w, h);
}

export function getPlayerSprite(facing) {
  switch (facing) {
    case "up": return sprites.playerUp;
    case "left": return sprites.playerLeft;
    case "right": return sprites.playerRight;
    default: return sprites.playerDown;
  }
}

export function getItemSprite(itemId) {
  switch (itemId) {
    case "potion": return sprites.potion;
    case "sword": return sprites.sword;
    case "gem": return sprites.gem;
    case "key": return sprites.door;
    default: return sprites.gem;
  }
}
