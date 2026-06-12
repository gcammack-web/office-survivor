import { CANVAS_WIDTH, CANVAS_HEIGHT, TILE_SIZE, MAP_IDS, ITEMS, TILES } from "./constants.js";
import { MAPS, checkCollision, getTileAt } from "./maps.js";
import { Player, NPC, Enemy, Gem, WorldItem, hitboxOverlap, enemyHitbox } from "./entities.js";
import {
  getMovement, isActionPressed, isAttackPressed, isInventoryPressed,
  isUseItemPressed, isQuickPotionPressed, isInventoryNextPressed, anyKeyPressed,
} from "./input.js";
import { drawMap, drawDialog, drawHud, drawGameOver, drawPrompt } from "./renderer.js";
import { Inventory } from "./inventory.js";
import { getItemSprite } from "./sprites.js";
import { audio, ensureAudio } from "./audio.js";

function createOverworldState() {
  return {
    npc: new NPC(
      10 * TILE_SIZE + 2, 8 * TILE_SIZE + 2,
      "Villager",
      "Welcome, traveler! Collect gems and explore the dungeon to the east.",
      "The dungeon holds the final gem. Here's the key — be careful of monsters!"
    ),
    gems: [
      new Gem(14 * TILE_SIZE + 6, 2 * TILE_SIZE + 6),
      new Gem(2 * TILE_SIZE + 6, 10 * TILE_SIZE + 6),
    ],
    items: [],
    enemies: [
      new Enemy(7 * TILE_SIZE + 2, 12 * TILE_SIZE + 2, "slime"),
      new Enemy(15 * TILE_SIZE + 2, 14 * TILE_SIZE + 2, "slime"),
    ],
  };
}

function createDungeonState() {
  return {
    npc: null,
    gems: [
      new Gem(13 * TILE_SIZE + 6, 12 * TILE_SIZE + 6),
    ],
    items: [
      new WorldItem(4 * TILE_SIZE + 6, 4 * TILE_SIZE + 6, ITEMS.POTION),
      new WorldItem(10 * TILE_SIZE + 6, 8 * TILE_SIZE + 6, ITEMS.SWORD),
      new WorldItem(7 * TILE_SIZE + 6, 11 * TILE_SIZE + 6, ITEMS.POTION),
    ],
    enemies: [
      new Enemy(5 * TILE_SIZE + 2, 5 * TILE_SIZE + 2, "slime"),
      new Enemy(10 * TILE_SIZE + 2, 5 * TILE_SIZE + 2, "skeleton"),
      new Enemy(12 * TILE_SIZE + 2, 10 * TILE_SIZE + 2, "skeleton"),
      new Enemy(8 * TILE_SIZE + 2, 12 * TILE_SIZE + 2, "slime"),
    ],
  };
}

export class Game {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.inventory = new Inventory();
    this.mapStates = {
      [MAP_IDS.OVERWORLD]: createOverworldState(),
      [MAP_IDS.DUNGEON]: createDungeonState(),
    };
    this.currentMapId = MAP_IDS.OVERWORLD;
    this.player = new Player(5 * TILE_SIZE + 2, 5 * TILE_SIZE + 2);
    this.dialog = null;
    this.dialogTimer = 0;
    this.talkedToNpc = false;
    this.doorOpen = false;
    this.gemsCollected = 0;
    this.totalGems = 3;
    this.won = false;
    this.gameOver = false;
    this.time = 0;
    this.lastAction = false;
    this.lastAttack = false;
    this.lastInventory = false;
    this.lastUse = false;
    this.lastQuickPotion = false;
    this.lastTab = false;
    this.statusMsg = "Explore the village. Talk to the villager.";
  }

  get mapDef() { return MAPS[this.currentMapId]; }
  get map() { return this.mapDef.data; }
  get mapState() { return this.mapStates[this.currentMapId]; }

  update(dt) {
    if (anyKeyPressed()) ensureAudio();

    if (this.gameOver || this.won) {
      this.dialogTimer = Math.max(0, this.dialogTimer - dt);
      if (this.dialogTimer <= 0) this.dialog = null;
      return;
    }

    this.time += dt;

    if (this.inventory.open) {
      this.handleInventoryInput();
      return;
    }

    const { dx, dy } = getMovement();
    this.player.update(dt, dx, dy, this.map, checkCollision, this.doorOpen);

    this.handleCombat(dt);
    this.handleInteractions();
    this.updateEntities(dt);
    this.checkMapTransitions();
    this.checkWinCondition();

    if (this.dialogTimer > 0) {
      this.dialogTimer -= dt;
      if (this.dialogTimer <= 0) this.dialog = null;
    }

    if (!this.player.isAlive()) {
      this.gameOver = true;
      this.showDialog("You have fallen...", 999);
      audio.stopMusic();
    }

    this.updateHtmlHud();
  }

  handleInventoryInput() {
    if (isInventoryPressed() && !this.lastInventory) {
      this.inventory.toggle();
    }
    this.lastInventory = isInventoryPressed();

    if (isInventoryNextPressed() && !this.lastTab) {
      this.inventory.selectNext();
    }
    this.lastTab = isInventoryNextPressed();

    if (isUseItemPressed() && !this.lastUse) {
      const result = this.inventory.useSelected(this.player);
      if (result === "potion") audio.playPotion();
      if (result === "already_full") this.showDialog("HP is already full.");
    }
    this.lastUse = isUseItemPressed();
  }

  handleCombat(dt) {
    const state = this.mapState;

    if (isAttackPressed() && !this.lastAttack && this.player.attack()) {
      audio.playAttack();
      const hb = this.player.getAttackHitbox();
      const damage = 1 + this.inventory.getAttackBonus();

      for (const enemy of state.enemies) {
        if (!enemy.alive) continue;
        if (hitboxOverlap(hb, enemyHitbox(enemy))) {
          const killed = enemy.takeDamage(damage);
          audio.playHit();
          if (killed) audio.playEnemyDefeat();
        }
      }
    }
    this.lastAttack = isAttackPressed();

    for (const enemy of state.enemies) {
      enemy.update(dt, this.player, this.map, checkCollision);
      if (enemy.touchesPlayer(this.player)) {
        if (this.player.takeDamage(enemy.damage)) {
          audio.playHit();
        }
      }
    }
  }

  handleInteractions() {
    const action = isActionPressed();
    const state = this.mapState;

    if (action && !this.lastAction && state.npc?.isNear(this.player)) {
      const npc = state.npc;
      this.showDialog(npc.getDialog());
      audio.playTalk();

      if (!npc.gaveKey) {
        npc.gaveKey = true;
        this.inventory.add(ITEMS.KEY);
        this.talkedToNpc = true;
        this.doorOpen = true;
        this.setStatus("You received the Dungeon Key! Head east.");
      }
    }
    this.lastAction = action;

    if (isQuickPotionPressed() && !this.lastQuickPotion) {
      const result = this.inventory.quickUsePotion(this.player);
      if (result === "potion") {
        audio.playPotion();
        this.showDialog("Used Health Potion! +3 HP");
      }
    }
    this.lastQuickPotion = isQuickPotionPressed();

    if (isInventoryPressed() && !this.lastInventory) {
      this.inventory.toggle();
    }
    this.lastInventory = isInventoryPressed();
  }

  updateEntities(dt) {
    const state = this.mapState;

    for (const gem of state.gems) {
      gem.update(dt);
      if (gem.tryCollect(this.player)) {
        this.gemsCollected++;
        this.inventory.add(ITEMS.GEM);
        audio.playCollect();
        this.setStatus(`Found a gem! (${this.gemsCollected}/${this.totalGems})`);
      }
    }

    for (const item of state.items) {
      item.update(dt);
      if (item.tryCollect(this.player)) {
        this.inventory.add(item.itemId);
        audio.playCollect();
        this.showDialog(`Found ${item.itemId}!`);
      }
    }
  }

  checkMapTransitions() {
    const tile = getTileAt(this.map, this.player.centerX(), this.player.centerY());

    if (this.currentMapId === MAP_IDS.OVERWORLD && tile === TILES.DOOR && this.doorOpen) {
      this.changeMap(MAP_IDS.DUNGEON);
    }

    if (this.currentMapId === MAP_IDS.DUNGEON && tile === TILES.STAIRS_UP) {
      this.changeMap(MAP_IDS.OVERWORLD, { x: 17 * TILE_SIZE + 2, y: 9 * TILE_SIZE + 2 });
    }
  }

  changeMap(mapId, spawn = null) {
    audio.playPortal();
    this.currentMapId = mapId;
    const def = MAPS[mapId];
    const pos = spawn || def.spawn;
    this.player.x = pos.x;
    this.player.y = pos.y;
    this.setStatus(`Entered ${def.name}`);
  }

  checkWinCondition() {
    if (!this.won && this.gemsCollected >= this.totalGems && this.talkedToNpc) {
      this.won = true;
      audio.playVictory();
      this.showDialog("Quest complete! You saved the village!", 999);
      this.setStatus("Victory! Thanks for playing.");
    }
  }

  showDialog(text, duration = 3) {
    this.dialog = text;
    this.dialogTimer = duration;
  }

  setStatus(text) {
    this.statusMsg = text;
    const el = document.getElementById("status");
    if (el) el.textContent = text;
  }

  updateHtmlHud() {
    const gemsEl = document.getElementById("gems");
    const totalEl = document.getElementById("gems-total");
    const hpEl = document.getElementById("hp");
    const mapEl = document.getElementById("map-name");
    if (gemsEl) gemsEl.textContent = this.gemsCollected;
    if (totalEl) totalEl.textContent = this.totalGems;
    if (hpEl) hpEl.textContent = `${this.player.hp}/${this.player.maxHp}`;
    if (mapEl) mapEl.textContent = this.mapDef.name;
  }

  getCamera() {
    const mapWidth = this.map[0].length * TILE_SIZE;
    const mapHeight = this.map.length * TILE_SIZE;

    let cameraX = this.player.centerX() - CANVAS_WIDTH / 2;
    let cameraY = this.player.centerY() - CANVAS_HEIGHT / 2;

    cameraX = Math.max(0, Math.min(cameraX, mapWidth - CANVAS_WIDTH));
    cameraY = Math.max(0, Math.min(cameraY, mapHeight - CANVAS_HEIGHT));

    return { cameraX, cameraY };
  }

  draw() {
    const { cameraX, cameraY } = this.getCamera();
    const { ctx } = this;
    const state = this.mapState;

    ctx.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    drawMap(ctx, this.map, cameraX, cameraY, this.time, this.doorOpen);

    for (const item of state.items) {
      item.draw(ctx, cameraX, cameraY, getItemSprite);
    }
    for (const gem of state.gems) {
      gem.draw(ctx, cameraX, cameraY, getItemSprite);
    }
    for (const enemy of state.enemies) {
      enemy.draw(ctx, cameraX, cameraY);
    }
    if (state.npc) state.npc.draw(ctx, cameraX, cameraY);
    this.player.draw(ctx, cameraX, cameraY);

    drawHud(ctx, this.player, this.mapDef.name);

    if (state.npc?.isNear(this.player) && !this.dialog && !this.inventory.open) {
      drawPrompt(ctx, state.npc.x - cameraX - 8, state.npc.y - cameraY - 8, "[Space] Talk");
    }

    if (this.currentMapId === MAP_IDS.OVERWORLD && this.doorOpen) {
      drawPrompt(ctx, 18 * TILE_SIZE - cameraX - 20, 9 * TILE_SIZE - cameraY - 8, "Dungeon →");
    }

    if (this.currentMapId === MAP_IDS.DUNGEON) {
      drawPrompt(ctx, 1 * TILE_SIZE - cameraX, 14 * TILE_SIZE - cameraY - 8, "[Stairs] Exit");
    }

    if (this.dialog) drawDialog(ctx, this.dialog);
    this.inventory.draw(ctx);

    if (this.gameOver) drawGameOver(ctx);
  }
}
