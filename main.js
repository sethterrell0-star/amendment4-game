(() => {
  const $ = (id) => document.getElementById(id);
  const screens = { home: $('home'), trial: $('trial'), verdict: $('verdict') };
  const decoder = new TextDecoder();
  let wasm;
  let soundOn = false;
  let audio;

  async function boot() {
    try {
      const response = await fetch('game.wasm');
      if (!response.ok) throw new Error('Could not load game.wasm');
      const bytes = await response.arrayBuffer();
      const loaded = await WebAssembly.instantiate(bytes, {});
      wasm = loaded.instance.exports;
      $('start-game').disabled = false;
    } catch (error) {
      $('start-game').textContent = 'Could not load game.wasm';
      $('start-game').disabled = true;
      console.error(error);
    }
  }
  $('start-game').disabled = true;
  boot();

  const str = (fn, ...args) => {
    const ptr = wasm[fn](...args);
    const bytes = new Uint8Array(wasm.memory.buffer);
    let end = ptr;
    while (bytes[end]) end++;
    return decoder.decode(bytes.subarray(ptr, end));
  };
  const show = (screen) => Object.values(screens).forEach((node) => node.classList.toggle('hidden', node !== screens[screen]));
  const pad = (num) => String(num).padStart(2, '0');

  function clickTone() {
    if (!soundOn) return;
    try {
      audio ||= new AudioContext();
      const oscillator = audio.createOscillator();
      const gain = audio.createGain();
      oscillator.type = 'sine';
      oscillator.frequency.value = 520;
      gain.gain.setValueAtTime(.04, audio.currentTime);
      gain.gain.exponentialRampToValueAtTime(.001, audio.currentTime + .11);
      oscillator.connect(gain).connect(audio.destination);
      oscillator.start();
      oscillator.stop(audio.currentTime + .11);
    } catch (_) {}
  }

  function showTrial() {
    show('trial');
    const pos = wasm.get_case_pos();
    $('docket-no').textContent = pad(pos + 1);
    $('case-number').textContent = pad(pos + 1);
    $('case-count').textContent = pad(wasm.get_count());
    $('case-title').textContent = str('get_title');
    $('case-badge').textContent = str('get_badge');
    $('case-setting').textContent = str('get_setting');
    $('case-facts').textContent = str('get_facts');
    $('case-evidence').textContent = str('get_evidence');
    $('doctrine-label').textContent = str('get_doctrine').toUpperCase();
    const stage = wasm.get_stage();
    const names = ['CROSS-EXAMINATION', 'THE CONSTITUTIONAL RULE', 'CLOSING ARGUMENT'];
    $('stage-name').textContent = names[stage];
    $('stage-number').textContent = pad(stage + 1);
    $('progress-fill').style.width = `${((stage + 1) / 3) * 100}%`;
    $('prompt').textContent = str('get_prompt');
    $('choices').replaceChildren();
    $('feedback').classList.add('hidden');
    $('choices').classList.remove('hidden');
    for (let i = 0; i < 3; i++) {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'choice-button';
      button.innerHTML = `<span class="choice-key">0${i + 1}</span><span></span>`;
      button.lastElementChild.textContent = str('get_choice', i);
      button.addEventListener('click', () => makeChoice(i));
      $('choices').append(button);
    }
  }

  function makeChoice(choice) {
    clickTone();
    wasm.choose(choice);
    for (const button of $('choices').children) button.disabled = true;
    $('feedback-text').textContent = str('get_feedback');
    $('choices').classList.add('hidden');
    $('feedback').classList.remove('hidden');
    $('continue-button').textContent = wasm.get_done() ? 'Hear the ruling  →' : 'Continue  →';
  }

  function showVerdict() {
    show('verdict');
    $('result-title').textContent = str('get_result_title');
    $('case-score').textContent = `${wasm.get_score()} / 3`;
    $('round-score').textContent = `${wasm.get_round_score()} / ${wasm.get_round_total()}`;
    $('result-doctrine').textContent = `${str('get_outcome')} ${str('get_doctrine')}. ${str('get_feedback')}`;
    const finalCase = wasm.get_case_pos() + 1 >= wasm.get_count();
    $('next-case').innerHTML = finalCase ? 'Begin a new docket <span>↻</span>' : 'Call the next case <span>→</span>';
  }

  $('start-game').addEventListener('click', () => {
    if (!wasm) return;
    wasm.start_round((Math.random() * 0xffffffff) >>> 0);
    wasm.start_case(0);
    clickTone();
    showTrial();
  });
  $('continue-button').addEventListener('click', () => {
    clickTone();
    if (wasm.get_done()) showVerdict(); else showTrial();
  });
  $('next-case').addEventListener('click', () => {
    clickTone();
    if (wasm.get_case_pos() + 1 >= wasm.get_count()) {
      wasm.start_round((Math.random() * 0xffffffff) >>> 0);
      wasm.start_case(0);
    } else wasm.start_case(wasm.get_case_pos() + 1);
    showTrial();
  });
  $('return-home').addEventListener('click', () => { clickTone(); show('home'); });
  $('leave-trial').addEventListener('click', () => { clickTone(); show('home'); });
  $('how-button').addEventListener('click', () => $('how').classList.toggle('hidden'));
  $('close-how').addEventListener('click', () => $('how').classList.add('hidden'));
  $('sound-toggle').addEventListener('click', () => {
    soundOn = !soundOn;
    $('sound-toggle').innerHTML = `SOUND <span>${soundOn ? 'ON' : 'OFF'}</span>`;
    $('sound-toggle').setAttribute('aria-label', soundOn ? 'Turn sound off' : 'Turn sound on');
    clickTone();
  });
})();
