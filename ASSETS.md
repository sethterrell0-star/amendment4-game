# Art sources and replacement notes

All art is bundled locally and can be replaced. No external image request is made at runtime.

## Character portraits

The twelve replaceable portraits in `lovegame/assets/characters/` come from [Visual Novel Character Sprite](https://opengameart.org/content/visual-novel-character-sprite), by FALLiNG_AiR. The pack is dedicated under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). Character poses cover the defense attorney, prosecutor, and two witnesses. Attribution is not required by CC0; it is included here as a courtesy. Keep each filename, or change its reference in `lovegame/main.lua`.

## Background photos

| Bundled file | Original work and source | License |
| --- | --- | --- |
| `lovegame/assets/courthouse.jpg` | [US Courthouse El Paso exterior](https://commons.wikimedia.org/wiki/File:US_Courthouse_El_Paso_exterior.JPG), General Services Administration | U.S. federal government work; public domain in the United States |
| `lovegame/assets/courtroom.jpg` | [Interior view of the court room at the Old Courthouse](https://commons.wikimedia.org/wiki/File:Interior_view_of_the_court_room_at_the_Old_Courthouse.jpg), Missouri History Museum; original photograph circa 1900–1920 | Public domain in the United States |
| `lovegame/assets/police-car.jpg` | [Police-car.jpg](https://commons.wikimedia.org/wiki/File:Police-car.jpg), PublicDomainPictures.net | CC0 1.0 Universal Public Domain Dedication |

The photos are used as tinted scene backdrops. Replace a photo with another file using the same name and format, or update the references in `lovegame/main.lua`. The court portraits are independent transparent PNGs, so you can replace them with your own poses. Check the license for new art and update this file with the source.
