using System.Data;
using System.Runtime.CompilerServices;
using Microsoft.VisualBasic;

namespace AOC2024;

internal static class Day06
{
    private enum Direction
    {
        North,
        South,
        East,
        West,
    }
    private static Direction DirectionFromText(char text)
    {
        return text switch
        {
            '^' => Direction.North,
            'v' => Direction.South,
            '<' => Direction.East,
            '>' => Direction.West,
            _ => throw new ArgumentException(null, nameof(text)),
        };
    }

    private class Guard
    {
        public (int, int) Position { get; set; }
        public Direction Direction { get; set; }

        public override int GetHashCode()
        {
            return HashCode.Combine(Direction.GetHashCode(), Position.GetHashCode());
        }

        public (int, int) NextPosition()
        {
            var (y, x) = Position;
            return Direction switch
            {
                Direction.North => (y - 1, x),
                Direction.South => (y + 1, x),
                Direction.East => (y, x + 1),
                Direction.West => (y, x - 1),
                _ => throw new InvalidOperationException(),
            };
        }

        public void Rotate()
        {
            Direction = Direction switch
            {
                Direction.North => Direction.East,
                Direction.South => Direction.West,
                Direction.East => Direction.South,
                Direction.West => Direction.North,
                _ => throw new InvalidOperationException(),
            };
        }

        public override string ToString()
        {
            return $"Guard going {Direction} @ ({Position.Item1}, {Position.Item2})";
        }

        public static (int visitedCount, bool stuckInALoop) Travel(char[][] map)
        {
            var (positions, guard) = FindInitialPosition(map);
            var guardHistory = new HashSet<Guard> { guard };
            while (true)
            {
                var (ny, nx) = guard.NextPosition();
                if (ny < 0 || ny >= map.Length || nx < 0 || nx >= map[0].Length)
                {
                    break;
                }

                if (map[ny][nx] == '#')
                {
                    // obstacle, go 90 degrees CW
                    guard.Rotate();
                    continue;
                }

                guard.Position = (ny, nx);
                positions.Add((ny, nx));
                var isUnique = guardHistory.Add(guard);
                if (!isUnique)
                {
                    return (0, stuckInALoop: true);
                }
            }

            return (visitedCount: positions.Count, false);
        }
    }

    private static (HashSet<(int, int)>, Guard) FindInitialPosition(char[][] map)
    {
        var positions = new HashSet<(int, int)>();
        for (var y = 0; y < map.Length; ++y)
        {
            var row = map[y];
            for (var x = 0; x < row.Length; ++x)
            {
                var ch = row[x];
                if (ch is '^' or '<' or '>' or 'v')
                {
                    positions.Add((y, x));
                    return (positions, new Guard
                    {
                        Position = (y, x),
                        Direction = DirectionFromText(ch),
                    });
                }
            }
        }
        throw new Exception("Invalid input");
    }

    private static void Main()
    {
        var mapBuilder = new List<char[]>();
        while (true)
        {
            var line = Console.ReadLine();
            if (line == null)
            {
                break;
            }

            mapBuilder.Add(line.ToCharArray());
        }

        var map = mapBuilder.ToArray();
        var (visitedCount, _) = Guard.Travel(map);
        Console.WriteLine($"Part 1: {visitedCount}");

        var loops = 0;
        for (var y = 0; y < map.Length; ++y)
        {
            var row = map[y];
            for (var x = 0; x < row.Length; ++x)
            {
                var ch = map[y][x];
                if (ch != '.')
                {
                    continue;
                }
                map[y][x] = '#';
                var (_, stuckInALoop) = Guard.Travel(map);
                if (stuckInALoop)
                {
                    loops++;
                }
                map[y][x] = '.';
            }
        }

        Console.WriteLine($"Part 2: {loops}");
    }
}
