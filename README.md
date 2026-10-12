# Fourth Counsel

A small courtroom adventure about the Fourth Amendment. The playable docket contains eight fictional cases with randomized order and a three-step argument in each: establish the facts, choose the constitutional rule, then seek a remedy. The cases cover both valid searches and searches a defense attorney can challenge.

## Run it

Serve this folder with any static web server, then open its `index.html`. For example, from this directory:

```sh
python3 -m http.server 8000
```

Open `http://localhost:8000`. No backend, build framework, package install, API key, or remote asset request is used at runtime. The included `game.wasm` is ready to play. `main.js` is the small browser glue layer for rendering and input; case facts, choices, scoring, and round state are in `game.c` and run in WebAssembly.

To rebuild the WASM module with a clang toolchain that supports `wasm32`:

```sh
clang --target=wasm32 -O2 -nostdlib -fno-builtin \
  -Wl,--no-entry -Wl,--export-memory -Wl,--strip-all \
  -Wl,--initial-memory=131072 game.c -o game.wasm
```

## Replace the art

Replace the three files in `assets/` with images of the same names and formats. The page uses `assets/courthouse.jpg` for the title screen, `assets/courtroom.jpg` during a case, and `assets/police-car.jpg` on the opinion screen. You can also change those references near the top of `style.css`. Animated GIFs work as drop-in images if you change the CSS URL and keep the file alongside the game. Keep the image source and license details with any art you add.

## Learning note

The choices draw on [*Georgia v. Randolph*](https://www.law.cornell.edu/supct/pdf/04-1067P.ZO) (shared-home consent), [*Riley v. California*](https://www.law.cornell.edu/supremecourt/text/13-132) (phone contents after arrest), [*Carpenter v. United States*](https://www.supremecourt.gov/opinions/17pdf/16-402_h315.pdf) (historical cell-site location data), [*Terry v. Ohio*](https://supreme.justia.com/cases/federal/us/392/1/) (stop and frisk), [*Payton v. New York*](https://supreme.justia.com/cases/federal/us/445/573/) (home entry), [*Rodriguez v. United States*](https://supreme.justia.com/cases/federal/us/575/348/) (traffic-stop duration), [*Carroll v. United States*](https://supreme.justia.com/cases/federal/us/267/132/) (vehicle searches on probable cause), and [*Maryland v. Garrison*](https://supreme.justia.com/cases/federal/us/480/79/) (reasonable mistakes executing warrants). Two scenarios have lawful searches; the others provide grounds to argue suppression, subject to the stated facts. Real cases turn on the full record, applicable jurisdiction, later precedent, and exceptions. This is an educational game, not legal advice.
