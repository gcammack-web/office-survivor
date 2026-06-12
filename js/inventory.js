import { ITEMS } from "./constants.js";
import { getItemSprite } from "./sprites.js";

const ITEM_META = {
  [ITEMS.POTION]: { name: "Health Potion", desc: "Restores 3 HP", stackable: true },
  [ITEMS.SWORD]: { name: "Rusty Sword", desc: "+2 attack damage", stackable: false },
  [ITEMS.KEY]: { name: "Dungeon Key", desc: "Opens the dungeon door", stackable: false },
  [ITEMS.GEM]: { name: "Gem", desc: "A shiny quest gem", stackable: true },
};

export class Inventory {
  constructor() {
    this.slots = [];
    this.selectedIndex = 0;
    this.open = false;
    this.hasSword = false;
  }

  add(itemId, count = 1) {
    const meta = ITEM_META[itemId];
    if (!meta) return false;

    if (meta.stackable) {
      const existing = this.slots.find((s) => s.id === itemId);
      if (existing) {
        existing.count += count;
      } else {
        this.slots.push({ id: itemId, count });
      }
    } else if (!this.slots.some((s) => s.id === itemId)) {
      this.slots.push({ id: itemId, count: 1 });
      if (itemId === ITEMS.SWORD) this.hasSword = true;
    }
    return true;
  }

  remove(itemId, count = 1) {
    const slot = this.slots.find((s) => s.id === itemId);
    if (!slot || slot.count < count) return false;
    slot.count -= count;
    if (slot.count <= 0) {
      this.slots = this.slots.filter((s) => s !== slot);
    }
    return true;
  }

  has(itemId) {
    return this.slots.some((s) => s.id === itemId);
  }

  count(itemId) {
    return this.slots.filter((s) => s.id === itemId).reduce((n, s) => n + s.count, 0);
  }

  toggle() {
    this.open = !this.open;
  }

  selectNext() {
    if (this.slots.length === 0) return;
    this.selectedIndex = (this.selectedIndex + 1) % this.slots.length;
  }

  getSelected() {
    return this.slots[this.selectedIndex] || null;
  }

  useSelected(player) {
    const slot = this.getSelected();
    if (!slot) return null;

    if (slot.id === ITEMS.POTION) {
      if (player.hp >= player.maxHp) return "already_full";
      player.heal(3);
      this.remove(ITEMS.POTION, 1);
      return "potion";
    }
    return null;
  }

  quickUsePotion(player) {
    if (!this.has(ITEMS.POTION)) return null;
    if (player.hp >= player.maxHp) return "already_full";
    player.heal(3);
    this.remove(ITEMS.POTION, 1);
    return "potion";
  }

  getAttackBonus() {
    return this.hasSword ? 2 : 0;
  }

  draw(ctx) {
    if (!this.open) return;

    const boxW = 280;
    const boxH = 160;
    const boxX = (ctx.canvas.width - boxW) / 2;
    const boxY = (ctx.canvas.height - boxH) / 2;

    ctx.fillStyle = "rgba(0, 0, 0, 0.85)";
    ctx.fillRect(boxX, boxY, boxW, boxH);
    ctx.strokeStyle = "#ffd700";
    ctx.lineWidth = 2;
    ctx.strokeRect(boxX, boxY, boxW, boxH);

    ctx.fillStyle = "#ffd700";
    ctx.font = "bold 14px Courier New, monospace";
    ctx.fillText("INVENTORY", boxX + 12, boxY + 22);

    if (this.slots.length === 0) {
      ctx.fillStyle = "#888";
      ctx.font = "12px Courier New, monospace";
      ctx.fillText("Empty", boxX + 12, boxY + 50);
    } else {
      this.slots.forEach((slot, i) => {
        const iy = boxY + 36 + i * 28;
        const selected = i === this.selectedIndex;

        if (selected) {
          ctx.fillStyle = "rgba(255, 215, 0, 0.15)";
          ctx.fillRect(boxX + 8, iy - 2, boxW - 16, 24);
        }

        const sprite = getItemSprite(slot.id);
        ctx.drawImage(sprite, boxX + 12, iy, 20, 20);

        const meta = ITEM_META[slot.id];
        ctx.fillStyle = selected ? "#ffd700" : "#ccc";
        ctx.font = "12px Courier New, monospace";
        const label = slot.count > 1 ? `${meta.name} x${slot.count}` : meta.name;
        ctx.fillText(label, boxX + 38, iy + 14);
      });

      const sel = this.getSelected();
      if (sel) {
        ctx.fillStyle = "#888";
        ctx.font = "11px Courier New, monospace";
        ctx.fillText(ITEM_META[sel.id].desc, boxX + 12, boxY + boxH - 28);
        ctx.fillText("[E] Use  [Tab] Next  [I] Close", boxX + 12, boxY + boxH - 12);
      }
    }
  }
}

export { ITEM_META };
