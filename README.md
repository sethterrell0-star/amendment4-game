# Fourth Counsel

A courtroom visual novel about the Fourth Amendment. Its 12 cases cover four rising difficulty bands, with four randomized courtroom questions per case. A full case now moves from an evidence desk through witness cross-examination and a four-link motion builder to a branching ruling. Some searches are lawful, so the defense must fit the facts to the doctrine instead of arguing suppression every time.

Choose a full campaign, a date-seeded daily docket, single-case practice, or the doctrine notebook. Study mode shows free hints, Standard deducts a point when a used hint leads to a correct answer, and Expert disables hints. Case order is shuffled inside each difficulty band; questions and answer positions are shuffled each run. The daily docket uses the UTC date as its seed, so players get the same shuffle that day.

The game is written in **LÖVE 11.4 / Lua**. It also ships as a static browser build using love.js and WebAssembly. No server-side code or external services are needed; the browser loads the bundled game files from the same site.

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

## Controls

- On the title screen, press `1` for campaign, `2` for daily, `3` for practice, `4` for the notebook, or `5` for Learn. Press `D` to cycle difficulty.
- In Learn, scroll with the mouse wheel or arrow/Page Up/Page Down keys. Home and End jump to the beginning and end.
- On the evidence desk, click each record or use left/right and Enter to review it.
- During cross-examination and argument building, click an option or use `1`, `2`, or `3`; press Enter to continue after feedback.
- In court, click an answer or press `1`, `2`, or `3`; use up/down to move the highlight. Press `H` for a doctrine hint outside Expert mode.
- In practice and the notebook, use arrow keys to browse cases; Enter starts practice.
- Press Escape to return to the title.
- Use the Fullscreen button under the game in a browser.

## Rebuild the web version

Requires Node.js and npm. The build uses the `love.js` compatibility export, which works on static hosts such as GitHub Pages without special cross-origin headers.

```sh
npm install
npm run build:web
```

This packages the editable Lua project and assets, then regenerates `docs/` for publishing. To change a case, edit `lovegame/case_data.lua`; to change the interface, animation, or built-in character art, edit `lovegame/main.lua`.

## Replace the artwork

The default cast is original procedural art drawn in LÖVE: layered box-shaped faces, changing expressions, floating hands with no arms, and idle/blink/gesture animations. To use optional PNG overrides, put files in `lovegame/assets/characters/custom/` and list pose-to-path pairs in `lovegame/custom_art.lua`; the empty default table uses the original box-figure art. Replace background photos under `lovegame/assets/` using their existing filenames. The browser build embeds local copies and does not hotlink artwork.

See [ASSETS.md](ASSETS.md) for sources and licenses. Keep the relevant license and attribution with any replacement art.

## Learning note

The Learn page presents the Fourth Amendment's ratification, historical background, text, protections, and selected modern applications. Its pictures are original vector-like illustrations drawn in Lua; there are no memes, external image downloads, or runtime network requests.

Primary and official references for the Learn page:

- [National Archives: The Bill of Rights](https://www.archives.gov/milestone-documents/bill-of-rights) and [How did it happen?](https://www.archives.gov/founding-docs/bill-of-rights/how-did-it-happen) — amendment text, ratification date, and drafting history.
- [United States v. Verdugo-Urquidez, 494 U.S. 259](https://tile.loc.gov/storage-services/service/ll/usrep/usrep494/usrep494259/usrep494259.pdf) — historical discussion of writs of assistance and general warrants.
- [Congress.gov Constitution Annotated: The Fourth Amendment](https://constitution.congress.gov/browse/essay/intro-7-1/ALDE_00001302/) — incorporation and Fourth Amendment overview.
- [Riley v. California](https://constitution.congress.gov/browse/essay/amdt4-3-4/ALDE_00013718/) and [Carpenter v. United States](https://www.supremecourt.gov/opinions/17pdf/16-402_h315.pdf) — selected modern digital privacy decisions.

The fictional cases draw on [*Georgia v. Randolph*](https://www.law.cornell.edu/supct/pdf/04-1067P.ZO) (shared-home consent), [*Riley v. California*](https://www.law.cornell.edu/supremecourt/text/13-132) (phone contents after arrest), [*Carpenter v. United States*](https://www.supremecourt.gov/opinions/17pdf/16-402_h315.pdf) (historical cell-site location data), [*Terry v. Ohio*](https://supreme.justia.com/cases/federal/us/392/1/) (stop and frisk), [*Payton v. New York*](https://www.govinfo.gov/app/details/USREPORTS-445/USREPORTS-445-573) (home entry to make an arrest), [*Rodriguez v. United States*](https://supreme.justia.com/cases/federal/us/575/348/) (traffic-stop duration), [*Carroll v. United States*](https://supreme.justia.com/cases/federal/us/267/132/) (vehicle searches on probable cause), [*Maryland v. Garrison*](https://supreme.justia.com/cases/federal/us/480/79/) (reasonable mistakes executing warrants), [*Arizona v. Gant*](https://www.govinfo.gov/app/details/USREPORTS-556/USREPORTS-556-332) (vehicle search incident to arrest), [*Florida v. Jimeno*](https://www.govinfo.gov/app/details/USREPORTS-500/USREPORTS-500-248) (consent scope), and [*Collins v. Virginia*](https://www.supremecourt.gov/opinions/17pdf/16-1027_7lio.pdf) (automobile exception and curtilage).

These educational scenarios simplify the facts. Real cases depend on the full record, jurisdiction, later precedent, and exceptions. This game is not legal advice.
