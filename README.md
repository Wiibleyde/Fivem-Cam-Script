# Fivem-Cam-Script

## Table of Contents

- [Description](#description)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Editing the script](#editing-the-script)
- [Credits](#credits)
- [License](#license)

## Description

This script allows you to use a camera in FiveM. You can move the camera around and zoom in and out. You can also look around with your mouse. This script is perfect for taking screenshots or making videos.

## Requirements

- [FiveM server](https://fivem.net/)
- [Wiibleyde_Cams](https://github.com/Wiibleyde/Fivem-Cam-Script)

## Installation

1. Download the script
2. Put the `wiibleyde_cams` folder in the server resource directory
3. Add `ensure wiibleyde_cams` to your server.cfg
4. Restart your server
5. Enjoy!

## Usage

1. Type `/cam` in chat
2. Use the up and down arrow keys to move use the zoom in and out
3. Move your mouse to look around
4. Press `Backspace` to exit the camera

## Editing the script

If you don't want to use a command, you can use the `TriggerClientEvent("Cam:ToggleCam", src)` anywhere in your code, so, you can change the way you want to open the camera.

## Credits

- [Wiibleyde](https://github.com/Wiibleyde)
- [mrdiamonddirt](https://github.com/mrdiamonddirt) for the inspiration : [WeazelNewsCam](https://github.com/mrdiamonddirt/WeazelNewsCam)

## License

[MIT](https://choosealicense.com/licenses/mit/)
