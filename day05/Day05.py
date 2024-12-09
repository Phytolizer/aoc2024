from enum import Enum
import fileinput
from functools import cmp_to_key


class Stage(Enum):
    RULES = 0
    UPDATES = 1


def sorted_by_rules(rules: list[tuple[int, int]], update: list[int]) -> list[int]:
    def cmp(a: int, b: int) -> int:
        for a1, b1 in rules:
            if a == a1 and b == b1:
                return -1
        return 1

    return sorted(update, key=cmp_to_key(cmp))


def obeys_rules(rules: list[tuple[int, int]], update: list[int]) -> bool:
    return update == sorted_by_rules(rules, update)


def fix(rules: list[tuple[int, int]], update: list[int]) -> list[int]:
    return sorted_by_rules(rules, update)


stage = Stage.RULES
rules: list[tuple[int, int]] = []
part1 = 0
part2 = 0
for line in fileinput.input(encoding="utf-8"):
    line = line.rstrip("\n")
    match stage:
        case Stage.RULES:
            if len(line) == 0:
                stage = Stage.UPDATES
                continue
            before, after = line.split("|")
            rules.append((int(before), int(after)))
        case Stage.UPDATES:
            raw_update = line.split(",")
            update = list(map(int, raw_update))
            if obeys_rules(rules, update):
                part1 += update[len(update) // 2]
            else:
                update = fix(rules, update)
                part2 += update[len(update) // 2]

print(f"Part 1: {part1}")
print(f"Part 2: {part2}")
