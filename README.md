# StreetTalk

A lightweight FiveM NPC interaction system that allows players to interact with nearby NPCs using ox_lib context menus with randomized outcomes.

## Features

- **NPC Detection**: Automatically detects nearby NPCs within configurable distance
- **ox_lib Integration**: Clean context menus and notifications using ox_lib
- **Randomized Outcomes**: Each interaction has multiple possible results with configurable probabilities
- **Anti-Spam System**: Cooldown system prevents players from repeatedly harassing NPCs
- **Optional ESX Integration**: Configurable framework support (disabled by default)
- **Police Alerts**: Certain actions can alert police players
- **Highly Configurable**: All settings, probabilities, and responses can be customized

## Installation

1. Download the latest release
2. Extract the files to your FiveM server's resources folder
3. Add `ensure streettalk` to your `server.cfg`
4. Restart your server

## Usage

### Player Interactions

When near an NPC (within 2 meters by default), press **[E]** to open the interaction menu with these options:

- **Ask for Directions** - Get help finding locations around the city
- **Small Talk** - Have casual conversations with NPCs
- **Beg for Money** - Ask for spare change (may alert police)
- **Threaten** - Intimidate NPCs for money (may alert police)
- **Buy Drugs** - Attempt to purchase illegal substances (may alert police)
- **Sell Junk** - Try to sell random items to NPCs
- **Flirt** - Attempt to charm NPCs

### Configuration

Edit `config.lua` to customize:

- **ESX Integration**: Enable/disable framework support
- **Interaction Distance**: How close players need to be to NPCs
- **Cooldown Times**: Prevent interaction spam
- **Outcome Probabilities**: Adjust success rates for each interaction
- **Money Amounts**: Configure reward ranges
- **Custom Responses**: Add your own NPC dialogue

## Configuration Options

### ESX Integration
```lua
Config.UseESX = false  -- Set to true to enable ESX integration
```

### Interaction Outcomes
All interaction probabilities can be customized in `config.lua`:
- Success rates for each interaction type
- Money reward ranges
- Police alert chances
- Custom NPC responses

## Requirements

- FiveM Server
- ox_lib (required)
- ESX Framework (optional, configurable)

## License

This project is open source and available under the MIT License.
