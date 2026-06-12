class AudioManager {
  constructor() {
    this.ctx = null;
    this.musicGain = null;
    this.sfxGain = null;
    this.musicInterval = null;
    this.started = false;
  }

  init() {
    if (this.started) return;
    this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    this.musicGain = this.ctx.createGain();
    this.sfxGain = this.ctx.createGain();
    this.musicGain.gain.value = 0.08;
    this.sfxGain.gain.value = 0.15;
    this.musicGain.connect(this.ctx.destination);
    this.sfxGain.connect(this.ctx.destination);
    this.started = true;
    this.startMusic();
  }

  tone(freq, duration, type = "square", gainNode = this.sfxGain, volume = 0.3) {
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    osc.type = type;
    osc.frequency.value = freq;
    g.gain.value = volume;
    g.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);
    osc.connect(g);
    g.connect(gainNode);
    osc.start();
    osc.stop(this.ctx.currentTime + duration);
  }

  playCollect() {
    this.tone(880, 0.1);
    setTimeout(() => this.tone(1100, 0.15), 80);
  }

  playAttack() {
    this.tone(200, 0.08, "sawtooth", this.sfxGain, 0.2);
  }

  playHit() {
    this.tone(120, 0.15, "square", this.sfxGain, 0.25);
  }

  playTalk() {
    this.tone(440, 0.06);
    setTimeout(() => this.tone(550, 0.06), 70);
  }

  playPortal() {
    this.tone(330, 0.1);
    setTimeout(() => this.tone(660, 0.2), 100);
  }

  playPotion() {
    this.tone(523, 0.1);
    setTimeout(() => this.tone(784, 0.15), 100);
  }

  playVictory() {
    [523, 659, 784, 1047].forEach((f, i) => {
      setTimeout(() => this.tone(f, 0.2, "square", this.sfxGain, 0.2), i * 150);
    });
  }

  playEnemyDefeat() {
    this.tone(300, 0.05);
    setTimeout(() => this.tone(150, 0.2, "sawtooth"), 50);
  }

  startMusic() {
    if (!this.ctx || this.musicInterval) return;
    const melody = [262, 294, 330, 349, 392, 349, 330, 294];
    let step = 0;
    this.musicInterval = setInterval(() => {
      if (!this.ctx) return;
      const freq = melody[step % melody.length];
      this.tone(freq, 0.18, "triangle", this.musicGain, 0.12);
      step++;
    }, 400);
  }

  stopMusic() {
    if (this.musicInterval) {
      clearInterval(this.musicInterval);
      this.musicInterval = null;
    }
  }
}

export const audio = new AudioManager();

export function ensureAudio() {
  audio.init();
}
