# DO NOT EDIT THESE VARIABLES.
# The values are changed automatically by our GitHub Actions workflows when preparing a new patch.
GAME_VERSION = 'dev'

# Scripts which are loaded immediately in order to show the Intro screen.
# Don't add new scripts here unless it's really necessary.
INIT = [
  'Tooltip/SystemConstants',
  'Tooltip/Utils',

  'SpriteResizer',

  'RTP',
] + Dir.glob("Scripts/DataObjects/*") + [
  'Compilers',
  'BitmapCache',
  'Window',
  'SpriteWindow',
  'SW Subclasses',

  'Options',
  'System',

  'Cache',
  'Main',
]

# List of scripts to be loaded while intro screen is being shown. Adjust as needed.
SCRIPTS = [
  'RPG_Sprite',

  'Messages',
  'DrawText',
  'TextEntry',

  'Utilities',

  'Tooltip/Colors',
  'Scripts/Tooltip/UIElements/UIElement',
  'Scripts/Tooltip/UIElements/Image',
  'Scripts/Tooltip/UIElements/ScrollableContainer'

] + Dir.glob("Scripts/Tooltip/GameCalculation/*") + Dir.glob("Scripts/Tooltip/Scenes/*") +
  Dir.glob("Scripts/Tooltip/UIElements/*") #+ Dir.glob("Scripts/Tooltip/Scenes/*")

