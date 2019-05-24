// this code assumes the pico8-gpio-listener library has
// been included already
// https://unpkg.com/pico8-gpio-listener@0.2.1/pico8-gpio-listener.js

(function() {
  function readNumberFromGpio(gpio, pinIndex, bits) {
    return gpio
      .slice(pinIndex, pinIndex + bits)
      .reduce(function (num, val, i) {
        return num + (
          val
            ? Math.pow(2, bits - 1 - i)
            : 0
        );
      }, 0);
  }

  function groundVibration() {
    // TODO: implement a ground vibration? maybe?
    // navigator.vibrate([1, 300, 1]);
  }

  function grindVibration(level) {
    navigator.vibrate(0);
    var length = 5 * level;
    var vibrations = [];
    for (var i = 0; i < 12; i++) {
      vibrations.push(length);
      vibrations.push(80 - length);
    }
    navigator.vibrate(vibrations);
  }

  var playerStates = {
    0: 'idle',
    1: 'crouch',
    2: 'launch',
    3: 'jump',
    4: 'grind',
    5: 'down',
    6: 'land'
  };

  var playerState = 0;
  var destructionLevel = 0;

  window.vibrateInterval = null;

  var gpio = getP8Gpio();
  gpio.subscribe(function() {
    // don't waste time doing this if we can't vibrate!
    if (!navigator.vibrate) return;

    var _playerState = readNumberFromGpio(gpio, 1, 3);
    var _destructionLevel = readNumberFromGpio(gpio, 4, 3);
    if (
      _playerState === playerState &&
      _destructionLevel === destructionLevel ||
      (
        (
          // same vibration pattern for both of these
          playerStates[playerState] === 'idle' ||
          playerStates[playerState] === 'crouch'
        ) &&
        (
          playerStates[_playerState] === 'idle' ||
          playerStates[_playerState] === 'crouch'
        )
      )
    ) {
      // no need to change anything
      return;
    }

    clearInterval(vibrateInterval);
    navigator.vibrate(0);

    if (_destructionLevel) {
      // vibrate based on destruction level
      if (_destructionLevel === 6) {
        // wall is falling
        navigator.vibrate([40, 10, 40, 10, 40, 10, 40, 10, 40, 10, 40]);
      } else if (playerStates[_playerState] === 'grind') {
        vibrateInterval =
          setInterval(grindVibration(_destructionLevel), 960);
      }
    } else if (_playerState !== playerState) {
      switch (playerStates[_playerState]) {
        case 'idle':
        case 'crouch':
          // vibrateInterval = setInterval(groundVibration, 1000);
          break;
        case 'launch':
          navigator.vibrate([20, 40, 20]);
          break;
        case 'land':
          // it feels a bit early without the timeout
          setTimeout(function() {
            navigator.vibrate(40);
          }, 40);
          break;
        default:
          break;
      }
    }

    playerState = _playerState;
    destructionLevel = _destructionLevel;
  })
})();
