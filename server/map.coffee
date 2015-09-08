class Map
  constructor: () ->
    @title = "Default Map"
    @verses = [
      "Default Verse"
      "@blank"
    ]

    @current_verse = 0

module.exports = {
  Map: Map
}

