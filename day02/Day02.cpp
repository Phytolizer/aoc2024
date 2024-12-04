#include <algorithm>
#include <iostream>
#include <numeric>
#include <span>
#include <sstream>
#include <string>
#include <vector>

template <class It, class Gen, class Pred>
void generate_while(It it, Gen gen, Pred pred) {
  auto value = gen();
  while (pred(value)) {
    *it = std::move(value);
    ++it;
    value = gen();
  }
}

template <typename T> T get_value_from_stream(std::istream &in) {
  T value;
  in >> value;
  return value;
}

template <typename T> std::vector<T> stream_values(std::istream &in) {
  std::vector<T> out;
  generate_while(
      std::back_inserter(out), [&in] { return get_value_from_stream<T>(in); },
      [&in](auto const &_) { return bool(in); });
  return out;
}

template <typename T> std::vector<T> stream_values(std::istream &&rv) {
  auto &x = rv;
  return stream_values<T>(x);
}

template <template <class> class C, class T> void dumparr(C<T> const &row) {
  std::for_each(begin(row), end(row),
                [](auto const &value) { std::cout << value << ' '; });
  std::cout << '\n';
}

template <template <class> class C1, template <class> class C2, class T>
void dumparr2(C1<C2<T>> const &arr) {
  std::for_each(begin(arr), end(arr), [](auto const &row) { dumparr(row); });
}

template <template <class> class C> bool is_safe(C<int> const &row) {
  auto pos = std::transform_reduce(
      next(begin(row)), end(row), begin(row), true, std::logical_and{},
      [](int p1, int p2) { return p2 - p1 >= 1 && p2 - p1 <= 3; });
  auto neg = std::transform_reduce(
      next(begin(row)), end(row), begin(row), true, std::logical_and{},
      [](int p1, int p2) { return p1 - p2 >= 1 && p1 - p2 <= 3; });
  return pos || neg;
}

template <template <class> class C, class T>
std::vector<std::vector<T>> attenuate(C<T> const &reports) {
  std::vector<std::vector<T>> results;
  for (std::size_t i = 0; i <= size(reports); ++i) {
    std::vector<T> result;
    std::copy(begin(reports), begin(reports) + i - 1,
              std::back_inserter(result));
    std::copy(begin(reports) + i, end(reports), std::back_inserter(result));
    results.push_back(std::move(result));
  }
  return results;
}

int main() {
  std::string line;
  std::vector<std::vector<int>> reports;
  while (std::getline(std::cin, line)) {
    reports.push_back(stream_values<int>(std::istringstream{line}));
  }
  std::cout << "Part 1: "
            << std::accumulate(begin(reports), end(reports), 0,
                               [](int acc, auto const &report) {
                                 return acc + is_safe(report);
                               })
            << '\n';
  std::cout << "Part 2: "
            << std::count_if(begin(reports), end(reports),
                             [](auto const &report) {
                               auto att = attenuate(report);
                               return std::any_of(begin(att), end(att),
                                                  [](auto const &row) {
                                                    return is_safe(row);
                                                  });
                             })
            << '\n';
}
