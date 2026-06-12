const keys = new Set();

window.addEventListener("keydown", (e) => {
  keys.add(e.key.toLowerCase());
  const prevent = ["arrowup", "arrowdown", "arrowleft", "arrowright", " ", "j", "i", "e", "q", "tab"];
  if (prevent.includes(e.key.toLowerCase()) || e.key === "Tab") {
    e.preventDefault();
  }
});

window.addEventListener("keyup", (e) => {
  keys.delete(e.key.toLowerCase());
});

export function isPressed(key) {
  return keys.has(key.toLowerCase());
}

export function getMovement() {
  let dx = 0;
  let dy = 0;

  if (isPressed("w") || isPressed("arrowup")) dy -= 1;
  if (isPressed("s") || isPressed("arrowdown")) dy += 1;
  if (isPressed("a") || isPressed("arrowleft")) dx -= 1;
  if (isPressed("d") || isPressed("arrowright")) dx += 1;

  if (dx !== 0 && dy !== 0) {
    const scale = 1 / Math.SQRT2;
    dx *= scale;
    dy *= scale;
  }

  return { dx, dy };
}

export function isActionPressed() {
  return isPressed(" ");
}

export function isAttackPressed() {
  return isPressed("j");
}

export function isInventoryPressed() {
  return isPressed("i");
}

export function isUseItemPressed() {
  return isPressed("e");
}

export function isQuickPotionPressed() {
  return isPressed("q");
}

export function isInventoryNextPressed() {
  return isPressed("tab");
}

export function anyKeyPressed() {
  return keys.size > 0;
}
