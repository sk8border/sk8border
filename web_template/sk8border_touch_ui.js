(function() {
  var qS = document.querySelector.bind(document);

  // meta functionality
  // Using undocumented features in PICO-8 v0.1.11g
  var using_touch = false;
  function activateTouch() {
    if (using_touch) return;
    using_touch = true;
    window.pico8_buttons = [0];
    document.body.classList.add('using_touch');
  }
  function startGame60fps() {
    startGame(60);
  }
  function startGame30fps() {
    startGame(30);
  }
  var game_started = false;
  var game_started_once = false;
  var last_chosen_framerate = null;
  function startGame(framerate) {
    if (last_chosen_framerate !== framerate) {
      var bit = framerate === 30 ? 1 : 0;
      window.writeNumberToGpio_global(bit, 0, 1);
      resetGame();
      last_chosen_framerate = framerate;
      if (framerate === 30) {
        qS('.switch_to_30').classList.add('hidden');
        qS('.switch_to_60').classList.remove('hidden');
      } else {
        qS('.switch_to_60').classList.add('hidden');
        qS('.switch_to_30').classList.remove('hidden');
      }
    }
    if (game_started) {
      if (game_paused) {
        toggleGamePaused();
      }
      return;
    }
    document.body.classList.add('playing');
    qS('#play_game').classList.add('hidden');
    qS('#play_game_30fps').classList.add('hidden');
    qS('.or_for_slower').classList.add('hidden');
    if (!game_started_once) {
      // choose canvas
      var namespace = using_touch ? '.touch_game' : '.desk_game';
      Module.canvas = qS(namespace + ' canvas');
      // display status messages
      Module.setStatus = function(msg) {
        qS('.touch_game .status').innerText = msg;
      };
      // run the game
      Module.calledRun = false;
      window.shouldRunNow = true;
      run();
    }
    game_started = true;
    game_started_once = true;
    if (game_paused) {
      toggleGamePaused();
    }
  }
  // only used for touch mode
  function stopGame() {
    if (!game_started) {
      return;
    }
    clearInterval(window.vibrateInterval);
    if (navigator.vibrate) navigator.vibrate(0);
    qS('#play_game').classList.remove('hidden');
    qS('#play_game_30fps').classList.remove('hidden');
    if (!game_paused) {
      toggleGamePaused();
    }
    document.body.classList.remove('playing');
    game_started = false;
  }
  var audio_on = true;
  function toggleAudio() {
    if (!game_started) {
      return;
    }
    audio_on = !audio_on;
    // there's a setter checking mutations I guess!
    window.codo_command = 3;
  }
  var game_paused = false;
  function toggleGamePaused() {
    if (!game_started) {
      return;
    }
    game_paused = !game_paused;
    if (game_paused) {
      window.clearInterval(window.vibrateInterval);
      if (navigator.vibrate) navigator.vibrate(0);
    }
    window.codo_command = 4;
  }
  function resetGame() {
    if (!game_started_once) {
      return;
    }
    requestAnimationFrame(function() {
      window.codo_command = 1;
    });
  }

  // game controls
  var btn_a_code = 16;
  var btn_b_code = 32;
  var btn_a_pressed = false;
  var btn_b_pressed = false;
  function update_input() {
    var code_a = btn_a_pressed ? btn_a_code : 0;
    var code_b = btn_b_pressed ? btn_b_code : 0;
    pico8_buttons[0] = code_a | code_b;
  }
  function press_a(e) {
    e.preventDefault();
    btn_a_pressed = true;
    update_input();
    if (navigator.vibrate) {
      navigator.vibrate(10);
    }
  }
  function press_b(e) {
    e.preventDefault();
    btn_b_pressed = true;
    update_input();
    if (navigator.vibrate) {
      navigator.vibrate(10);
    }
  }
  function release_a() {
    btn_a_pressed = false;
    update_input();
  }
  function release_b() {
    btn_b_pressed = false;
    update_input();
  }

  // set up listeners
  document.addEventListener('touchstart', activateTouch);

  qS('.touch_game').addEventListener('contextmenu', function(e) {
    e.preventDefault();
  }, true);

  var start_btn = qS('#play_game');
  start_btn.addEventListener('click', startGame60fps);

  var start_btn_30fps = qS('#play_game_30fps');
  start_btn_30fps.addEventListener('click', startGame30fps);

  var switch_to_30fps = qS('.switch_to_30 a');
  switch_to_30fps.addEventListener('click', function(e) {
    e.preventDefault();
    startGame30fps();
  });

  var switch_to_60fps = qS('.switch_to_60 a');
  switch_to_60fps.addEventListener('click', function(e) {
    e.preventDefault();
    startGame60fps();
  });

  var pause_btn = qS('.meta_btn.pause');
  pause_btn.addEventListener('click', toggleGamePaused);

  var reset_btn = qS('.meta_btn.reset');
  reset_btn.addEventListener('click', resetGame);

  var exit_btn = qS('.meta_btn.exit');
  exit_btn.addEventListener('click', stopGame);

  var btn_a = qS('.control_btn.a');
  btn_a.addEventListener('touchstart', press_a);
  btn_a.addEventListener('touchend', release_a);

  var btn_b = qS('.control_btn.b');
  btn_b.addEventListener('touchstart', press_b);
  btn_b.addEventListener('touchend', release_b);
})();
