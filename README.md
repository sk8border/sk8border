# sk8border

![sk8border preview GIF](img/preview_gif_compressed.gif)

(Le français suit)

Lay that wall to waste! [#antifagamejam](https://twitter.com/search?q=%23antifagamejam)

Sk8Border was created in Montreal in March/April 2018 for the Anti-Fascist Game Jam (https://itch.io/jam/antifa-game-jam) as a collaborative effort by Leif Halldór Ásgeirsson, Marc-André Toupin and Ben Wiley. It is built with PICO-8 (https://www.lexaloffle.com/pico-8.php).

This game runs in your web browser - even on your phone!

----------------------

Fracassez la frontière! [#antifagamejam](https://twitter.com/search?q=%23antifagamejam)

Sk8Border a été créé à Montréal en mars/avril 2018 pour le Anti-Fascist Game Jam (https://itch.io/jam/antifa-game-jam), par Leif Halldór Ásgeirsson, Marc-André Toupin et Ben Wiley. Il est fait avec PICO-8 (https://www.lexaloffle.com/pico-8.php).

Ce jeu fonctionne dans le navigateur - même sur les téléphones!

## Play / jouer

Current build is playable online at: https://sk8border.github.io/sk8border/

Binaries for Linux, Windows and Mac are available on the Itch.io: https://sk8border.itch.io/sk8border

## exportation

### Check out the build branch

Checkout `gh-pages`

```console
git checkout gh-pages
git merge master
```

### Standard build (won't work currently)

Create a new web build from PICO-8 with:

```console
export index.js
```

### Minified build (because we have too much code!)

0. Make sure you have python3 installed on your OS
1. Download [picotool](https://github.com/dansanderson/picotool)
2. Generate a lua-minified version of our p8 file:
  ```console
  /path/to/picotool/p8tool luamin ./sk8border.p8
  ```
3. Now we'll have a new file called `sk8border_fmt.p8`. Don't save this, but we'll load it in PICO-8!
4. Inside of PICO-8 run:
  ```console
  load sk8border_fmt.p8
  export index.js
  load sk8border.p8
  ```
5. Delete the minified file: `rm sk8border_fmt.p8`

### Finish up

Push:

```console
git push origin gh-pages
```

Back to master:

```console
git checkout master
```
