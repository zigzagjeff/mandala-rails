json.partial! "api/v1/tiles/tile", tile: @tile
json.body @tile.body.to_plain_text
