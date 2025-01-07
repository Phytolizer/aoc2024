import std/deques
import std/sequtils
import std/strutils
import std/sugar
import std/tables

type Vec2 = object
  x, y: int

proc initVec2(x, y: int): Vec2 =
  Vec2(x: x, y: y)

proc `+`(a, b: Vec2): Vec2 =
  initVec2(a.x + b.x, a.y + b.y)

const
  up = initVec2(0, 1)
  down = initVec2(0, -1)
  left = initVec2(-1, 0)
  right = initVec2(1, 0)

type Map = TableRef[Vec2, char]

proc parseMap(input: string): Map =
  newTable collect do:
    for y, line in input.split("\n").toSeq:
      for x, ch in line:
        (initVec2(x, -y), ch)

proc trailsFrom(map: Map, head: Vec2): seq[Vec2] =
  var positions = [head].toDeque
  while positions.len > 0:
    let point = positions.popFirst
    if map[point] == '9':
      result &= point
    else:
      for dir in [up, down, left, right]:
        if map.getOrDefault(point + dir) == chr(ord(map[point]) + 1):
          positions.addLast(point + dir)

proc trailHeads(map: Map): seq[Vec2] =
  collect:
    for k, v in map.pairs:
      if v == '0':
        k

proc trails(input: string): TableRef[Vec2, seq[Vec2]] =
  let map = input.parseMap()
  newTable collect do:
    for head in map.trailHeads():
      (head, map.trailsFrom(head))

proc part1(input: string): int =
  trails(input).values.toSeq.foldl(a + deduplicate(b).len, 0)

proc part2(input: string): int =
  trails(input).values.toSeq.foldl(a + b.len, 0)

let input = stdin.readAll()
echo "Part 1: " & $part1(input)
echo "Part 2: " & $part2(input)
