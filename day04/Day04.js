import { readFileSync } from "fs";

const v2smul = (s, [x, y]) => {
  return [s * x, s * y];
};
const v2add = ([ax, ay], [bx, by]) => {
  return [ax + bx, ay + by];
};

const coordMap = (data) => {
  const result = {};
  data.forEach((row, y) => {
    [...row].forEach((ch, x) => {
      result[`${y},${x}`] = ch;
    });
  });
  return result;
};

const isPattern = (coords, pos, dir, pattern) => {
  const chars = [...Array(pattern.length).keys()].map((i) => {
    const [px, py] = v2add(pos, v2smul(i, dir));
    return coords[`${px},${py}`];
  });
  const text = chars.join("");
  if (text == pattern || text == pattern.split("").reverse().join("")) {
    return true;
  }
  return false;
};

const input = readFileSync(process.stdin.fd, "utf-8");
const data = input.trim().split("\n");
const coords = coordMap(data);
let part1 = 0;
for (const pt of Object.keys(coords)) {
  const [px, py] = pt.split(",").map((x) => Number(x));
  const dirs = [
    [0, 1],
    [1, 1],
    [1, -1],
    [1, 0],
  ];
  for (const dir of dirs) {
    if (isPattern(coords, [px, py], dir, "XMAS")) {
      part1++;
    }
  }
}
console.log("Part 1:", part1);
let part2 = 0;
for (const pt of Object.keys(coords)) {
  const pos = pt.split(",").map((x) => Number(x));
  if (
    isPattern(coords, v2add(pos, [-1, -1]), [1, 1], "MAS") &&
    isPattern(coords, v2add(pos, [1, -1]), [-1, 1], "MAS")
  ) {
    part2++;
  }
}
console.log("Part 2:", part2);
