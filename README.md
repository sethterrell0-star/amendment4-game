# Fourth Counsel

A courtroom visual novel about the Fourth Amendment. A docket has 12 levels across four rising difficulty bands, with four questions per case. Case order is shuffled within each band; question order and answer positions are shuffled for each run. Some searches are lawful. After every case, the player sees the court's ruling and the doctrine behind it.

The game is written in **LÖVE 11.4 / Lua**. It also ships as a static browser build using love.js and WebAssembly. No server code or runtime network requests are needed.

## Play in a browser

Open the published GitHub Pages site, or serve the built `docs/` folder locally:

```sh
python3 -m http.server 8000 --directory docs
```

Then visit `http://localhost:8000`. The build in `docs/` is ready for GitHub Pages configured to publish the `main` branch's `/docs` directory.

## Play with LÖVE

Install [LÖVE](https://love2d.org/) and run the project folder:

```sh
love lovegame
```

The `.love` source package is also at `lovegame/fourth-counsel.love`.

## Controls

- Click or press Enter to continue through the title, case file, and ruling.
- Click an answer or press `1`, `2`, or `3` in court.
- Use the up and down arrows to move the answer highlight.
- Press Enter after feedback to advance.
- Press Escape to return to the title.
- Use the Fullscreen button under the game in a browser.

## Rebuild the web version

Requires Node.js and npm. The build uses the `love.js` compatibility export, which works on static hosts such as GitHub Pages without special cross-origin headers.

```sh
npm install
npm run build:web
```

This packages the editable Lua project and assets, then regenerates `docs/` for publishing. To change a case, edit `lovegame/case_data.lua`; to change the interface, edit `lovegame/main.lua`.

## Replace the artwork

Replace the PNGs under `lovegame/assets/characters/` while keeping their filenames, or update the image names in `lovegame/main.lua`. Each pose is a separate replaceable portrait. Replace the background photos under `lovegame/assets/` using their existing filenames. The browser build embeds local copies, so it does not hotlink artwork.

See [ASSETS.md](ASSETS.md) for sources and licenses. Keep the relevant license and attribution with any replacement art.

## Learning note

The fictional cases draw on [*Georgia v. Randolph*](https://www.law.cornell.edu/supct/pdf/04-1067P.ZO) (shared-home consent), [*Riley v. California*](https://www.law.cornell.edu/supremecourt/text/13-132) (phone contents after arrest), [*Carpenter v. United States*](https://www.supremecourt.gov/opinions/17pdf/16-402_h315.pdf) (historical cell-site location data), [*Terry v. Ohio*](https://supreme.justia.com/cases/federal/us/392/1/) (stop and frisk), [*Payton v. New York*](https://www.govinfo.gov/app/details/USREPORTS-445/USREPORTS-445-573) (home entry to make an arrest), [*Rodriguez v. United States*](https://supreme.justia.com/cases/federal/us/575/348/) (traffic-stop duration), [*Carroll v. United States*](https://supreme.justia.com/cases/federal/us/267/132/) (vehicle searches on probable cause), [*Maryland v. Garrison*](https://supreme.justia.com/cases/federal/us/480/79/) (reasonable mistakes executing warrants), [*Arizona v. Gant*](https://www.govinfo.gov/app/details/USREPORTS-556/USREPORTS-556-332) (vehicle search incident to arrest), [*Florida v. Jimeno*](https://www.govinfo.gov/app/details/USREPORTS-500/USREPORTS-500-248) (consent scope), and [*Collins v. Virginia*](https://www.supremecourt.gov/opinions/17pdf/16-1027_7lio.pdf) (automobile exception and curtilage).

These educational scenarios simplify the facts. Real cases depend on the full record, jurisdiction, later precedent, and exceptions. This game is not legal advice.
