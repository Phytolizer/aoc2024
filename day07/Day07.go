package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func die(err error) {
	log.Fatalf("Error: %v", err)
}

var ops = []uint8{'+', '*'}

func check1(target int, acc int, nums []int) bool {
	if len(nums) == 0 {
		return acc == target
	}

	return check1(target, acc*nums[0], nums[1:]) ||
		check1(target, acc+nums[0], nums[1:])
}

func catNums(a, b int) int {
	cat := fmt.Sprintf("%d%d", a, b)
	result, _ := strconv.Atoi(cat)
	return result
}

func check2(target int, acc int, nums []int) bool {
	if len(nums) == 0 {
		return acc == target
	}

	return check2(target, acc*nums[0], nums[1:]) ||
		check2(target, acc+nums[0], nums[1:]) ||
		check2(target, catNums(acc, nums[0]), nums[1:])
}

func canEqual(value int, nums []int, check func(int, int, []int) bool) bool {
	return check(value, 0, nums)
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	part1 := 0
	part2 := 0
	for scanner.Scan() {
		line := scanner.Text()
		eqn := strings.Split(line, ": ")
		test, err := strconv.Atoi(eqn[0])
		if err != nil {
			die(err)
		}
		rawNums := strings.Split(eqn[1], " ")
		nums := make([]int, 0)
		for _, rawNum := range rawNums {
			num, err := strconv.Atoi(rawNum)
			if err != nil {
				die(err)
			}
			nums = append(nums, num)
		}
		if canEqual(test, nums, check1) {
			part1 += test
		}
		if canEqual(test, nums, check2) {
			part2 += test
		}
	}

	if scanner.Err() != nil {
		die(scanner.Err())
	}
	fmt.Printf("Part 1: %d\n", part1)
	fmt.Printf("Part 2: %d\n", part2)
}
