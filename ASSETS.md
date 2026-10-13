# Art sources and replacement notes

All art is bundled locally and can be replaced. No external image request is made at runtime.

## Characters

The attorney, prosecutor, and witnesses are original box-figure graphics drawn in `lovegame/main.lua`. Faces, expressions, clothing, and detached hand gestures are assembled from LÖVE shapes; no portrait pack is bundled. Optional replacement PNGs go under `lovegame/assets/characters/custom/` and are enabled by adding pose-to-path pairs to `lovegame/custom_art.lua`.

## Background photos

| Bundled file | Original work and source | License |
| --- | --- | --- |
| `lovegame/assets/courthouse.jpg` | [US Courthouse El Paso exterior](https://commons.wikimedia.org/wiki/File:US_Courthouse_El_Paso_exterior.JPG), General Services Administration | U.S. federal government work; public domain in the United States |
| `lovegame/assets/courtroom.jpg` | [Interior view of the court room at the Old Courthouse](https://commons.wikimedia.org/wiki/File:Interior_view_of_the_court_room_at_the_Old_Courthouse.jpg), Missouri History Museum; original photograph circa 1900–1920 | Public domain in the United States |
| `lovegame/assets/police-car.jpg` | [Police-car.jpg](https://commons.wikimedia.org/wiki/File:Police-car.jpg), PublicDomainPictures.net | CC0 1.0 Universal Public Domain Dedication |

The photos are used as tinted scene backdrops. Replace a photo with another file using the same name and format, or update the references in `lovegame/main.lua`. Check the license for new art and update this file with the source.

## Typeface

`lovegame/assets/fonts/NotoSans-Regular.ttf` uses the Noto Sans font by The Noto Project Authors under the SIL Open Font License, Version 1.1. The license is included beside the font in `lovegame/assets/fonts/OFL.txt`. Noto Sans is bundled so punctuation and extended characters render consistently in the browser and native LÖVE builds.
