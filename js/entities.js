import { TILE_SIZE } from "./constants.js";
import { getPlayerSprite, drawSprite, sprites } from "./sprites.js";

export class Player {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.size = 20;
    this.speed = 120;
    this.facing = "down";
    this.maxHp = 10;
    this.hp = 10;
    this.attackCooldown = 0;
    this.invincible = 0;
    this.attacking = false;
    this.attackTimer = 0;
  }

  heal(amount) {
    this.hp = Math.min(this.maxHp, this.hp + amount);
  }

  takeDamage(amount) {
    if (this.invincible > 0) return false;
    this.hp = Math.max(0, this.hp - amount);
    this.invincible = 1.0;
    return true;
  }

  isAlive() {
    return this.hp > 0;
  }

  update(dt, dx, dy, map, checkCollision, doorOpen) {
    this.attackCooldown = Math.max(0, this.attackCooldown - dt);
    this.invincible = Math.max(0, this.invincible - dt);

    if (this.attacking) {
      this.attackTimer -= dt;
      if (this.attackTimer <= 0) this.attacking = false;
    }

    if (dx === 0 && dy === 0) return;

    if (Math.abs(dx) > Math.abs(dy)) {
      this.facing = dx > 0 ? "right" : "left";
    } else {
      this.facing = dy > 0 ? "down" : "up";
    }

    const nextX = this.x + dx * this.speed * dt;
    const nextY = this.y + dy * this.speed * dt;

    if (!checkCollision(map, nextX, this.y, this.size, doorOpen)) {
      this.x = nextX;
    }
    if (!checkCollision(map, this.x, nextY, this.size, doorOpen)) {
      this.y = nextY;
    }
  }

  attack() {
    if (this.attackCooldown > 0) return false;
    this.attacking = true;
    this.attackTimer = 0.2;
    this.attackCooldown = 0.45;
    return true;
  }

  getAttackHitbox() {
    const reach = 28;
    const cx = this.centerX();
    const cy = this.centerY();
    switch (this.facing) {
      case "up": return { x: cx - 14, y: cy - reach, w: 28, h: reach };
      case "down": return { x: cx - 14, y: cy, w: 28, h: reach };
      case "left": return { x: cx - reach, y: cy - 14, w: reach, h: 28 };
      case "right": return { x: cx, y: cy - 14, w: reach, h: 28 };
      default: return { x: cx - 14, y: cy, w: 28, h: reach };
    }
  }

  draw(ctx, cameraX, cameraY) {
    const screenX = this.x - cameraX - 2;
    const screenY = this.y - cameraY - 2;

    if (this.invincible > 0 && Math.floor(this.invincible * 10) % 2 === 0) {
      ctx.globalAlpha = 0.5;
    }

    drawSprite(ctx, getPlayerSprite(this.facing), screenX, screenY, 24, 24);

    if (this.attacking) {
      ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
      ctx.lineWidth = 2;
      const hb = this.getAttackHitbox();
      ctx.strokeRect(hb.x - cameraX, hb.y - cameraY, hb.w, hb.h);
    }

    ctx.globalAlpha = 1;
  }

  centerX() { return this.x + this.size / 2; }
  centerY() { return this.y + this.size / 2; }
}

export class NPC {
  constructor(x, y, name, dialog, questDialog) {
    this.x = x;
    this.y = y;
    this.size = 20;
    this.name = name;
    this.dialog = dialog;
    this.questDialog = questDialog;
    this.gaveKey = false;
  }

  draw(ctx, cameraX, cameraY) {
    drawSprite(ctx, sprites.npc, this.x - cameraX - 2, this.y - cameraY - 2, 24, 24);
  }

  centerX() { return this.x + this.size / 2; }
  centerY() { return this.y + this.size / 2; }

  isNear(entity, range = 40) {
    const dx = this.centerX() - entity.centerX();
    const dy = this.centerY() - entity.centerY();
    return Math.hypot(dx, dy) < range;
  }

  getDialog() {
    return this.gaveKey ? this.questDialog : this.dialog;
  }
}

export class Enemy {
  constructor(x, y, type = "slime") {
    this.x = x;
    this.y = y;
    this.type = type;
    this.size = 20;
    this.speed = type === "skeleton" ? 55 : 35;
    this.maxHp = type === "skeleton" ? 4 : 2;
    this.hp = this.maxHp;
    this.damage = type === "skeleton" ? 2 : 1;
    this.alive = true;
    this.hitFlash = 0;
    this.patrolTarget = { x: x + 40, y: y };
    this.patrolTimer = 0;
    this.aggroRange = 120;
  }

  update(dt, player, map, checkCollision) {
    if (!this.alive) return;
    this.hitFlash = Math.max(0, this.hitFlash - dt);

    const dx = player.centerX() - this.centerX();
    const dy = player.centerY() - this.centerY();
    const dist = Math.hypot(dx, dy);

    let moveX = 0;
    let moveY = 0;

    if (dist < this.aggroRange && player.isAlive()) {
      moveX = (dx / dist) * this.speed * dt;
      moveY = (dy / dist) * this.speed * dt;
    } else {
      this.patrolTimer -= dt;
      if (this.patrolTimer <= 0) {
        this.patrolTarget = {
          x: this.x + (Math.random() - 0.5) * 80,
          y: this.y + (Math.random() - 0.5) * 80,
        };
        this.patrolTimer = 2 + Math.random() * 2;
      }
      const pdx = this.patrolTarget.x - this.x;
      const pdy = this.patrolTarget.y - this.y;
      const pdist = Math.hypot(pdx, pdy);
      if (pdist > 4) {
        moveX = (pdx / pdist) * this.speed * 0.5 * dt;
        moveY = (pdy / pdist) * this.speed * 0.5 * dt;
      }
    }

    if (!checkCollision(map, this.x + moveX, this.y, this.size)) {
      this.x += moveX;
    }
    if (!checkCollision(map, this.x, this.y + moveY, this.size)) {
      this.y += moveY;
    }
  }

  takeDamage(amount) {
    if (!this.alive) return false;
    this.hp -= amount;
    this.hitFlash = 0.15;
    if (this.hp <= 0) {
      this.alive = false;
      return true;
    }
    return false;
  }

  touchesPlayer(player) {
    if (!this.alive) return false;
    const dx = this.centerX() - player.centerX();
    const dy = this.centerY() - player.centerY();
    return Math.hypot(dx, dy) < 22;
  }

  draw(ctx, cameraX, cameraY) {
    if (!this.alive) return;

    const sprite = this.type === "skeleton" ? sprites.skeleton : sprites.slime;
    const sx = this.x - cameraX - 2;
    const sy = this.y - cameraY - 2;

    if (this.hitFlash > 0) {
      ctx.globalAlpha = 0.6;
      ctx.filter = "brightness(2)";
    }

    drawSprite(ctx, sprite, sx, sy, 24, 24);
    ctx.globalAlpha = 1;
    ctx.filter = "none";

    // HP bar
    const barW = 20;
    const ratio = this.hp / this.maxHp;
    ctx.fillStyle = "#333";
    ctx.fillRect(sx + 2, sy - 6, barW, 4);
    ctx.fillStyle = ratio > 0.5 ? "#48bb78" : "#e53e3e";
    ctx.fillRect(sx + 2, sy - 6, barW * ratio, 4);
  }

  centerX() { return this.x + this.size / 2; }
  centerY() { return this.y + this.size / 2; }
}

export class WorldItem {
  constructor(x, y, itemId) {
    this.x = x;
    this.y = y;
    this.itemId = itemId;
    this.size = 16;
    this.collected = false;
    this.bob = Math.random() * Math.PI * 2;
  }

  update(dt) {
    if (!this.collected) this.bob += dt * 4;
  }

  draw(ctx, cameraX, cameraY, getItemSprite) {
    if (this.collected) return;
    const bobY = Math.sin(this.bob) * 3;
    const sprite = getItemSprite(this.itemId);
    ctx.drawImage(sprite, this.x - cameraX, this.y - cameraY + bobY, 20, 20);
  }

  tryCollect(player, range = 24) {
    if (this.collected) return false;
    const dx = this.x + 10 - player.centerX();
    const dy = this.y + 10 - player.centerY();
    if (Math.hypot(dx, dy) < range) {
      this.collected = true;
      return true;
    }
    return false;
  }
}

export class Gem extends WorldItem {
  constructor(x, y) {
    super(x, y, "gem");
  }
}

export function hitboxOverlap(a, b) {
  return a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;
}

export function enemyHitbox(enemy) {
  return { x: enemy.x, y: enemy.y, w: enemy.size, h: enemy.size };
}
