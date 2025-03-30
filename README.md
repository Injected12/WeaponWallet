# Authenticated Weapons Shop with NPC Delivery

This FiveM resource provides an authenticated weapons shop system with NPC-based delivery. Players can access the shop at a designated location, log in with predefined credentials, purchase weapons, and collect them from an NPC at a randomly generated delivery point.

## Features

- Authentication system with predefined user accounts
- Customizable weapon inventory per user
- In-game currency based purchasing
- Random delivery point generation
- NPC-based weapon delivery
- Clean, semi-transparent UI
- Highly configurable through config.lua

## Installation

1. Download the resource
2. Place it in your FiveM resources folder
3. Add `ensure weapons_shop` to your server.cfg
4. Configure the shop location, users, and weapons in config.lua
5. Restart your server

## Usage

### Player Instructions
1. Visit the weapons shop location (marked on the map)
2. Press E to access the shop menu
3. Log in with your provided credentials
4. Browse available weapons and make a purchase
5. Follow the marker on your map to collect your weapon from the delivery NPC
6. Press E to collect your weapon from the NPC

### Admin Commands
The following commands can be used by server admins to manage the shop:

- `/weapons_add_user [username] [password] [name]` - Add a new user
- `/weapons_add_weapon [username] [weapon] [price]` - Add a weapon to a user's inventory
- `/weapons_remove_weapon [username] [weapon]` - Remove a weapon from a user's inventory
- `/weapons_remove_user [username]` - Remove a user
- `/weapons_list_users` - List all users
- `/weapons_list_weapons [username]` - List all weapons available to a user

## Configuration

The resource is highly configurable through the `config.lua` file. You can customize:

- Shop location
- Map blip appearance
- Interaction settings
- Delivery distance and timeout
- NPC model and animation
- UI colors and appearance
- User accounts and weapon inventories

## Weapon Names

When adding weapons, use the following format: `WEAPON_NAME` (without the "WEAPON_" prefix in commands)

Examples:
- WEAPON_PISTOL
- WEAPON_SMG
- WEAPON_CARBINERIFLE
- WEAPON_SNIPERRIFLE
- WEAPON_BAT

## Notes

- This resource does not require any framework (like ESX or QBCore)
- It uses the basic FiveM money system by default
- The shop location can be changed in the config.lua file
- Each user can have their own set of available weapons and prices

## Troubleshooting

- If the menu doesn't appear, make sure the resource is started and the shop location is correct
- If weapons don't appear after login, check that the user has weapons assigned in config.lua
- If the NPC doesn't spawn, check for script errors in the server console

## License

This resource is licensed under the [MIT License](https://opensource.org/licenses/MIT).
