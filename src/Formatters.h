#pragma once

#include <ostream>
#include <string>

// ******************************************************************************
struct indent {
  size_t _n;

  indent(size_t n) : _n(n) {}

  friend std::ostream& operator<<(std::ostream& os, const indent& _i) {
    for (size_t i = 0; i < _i._n; ++i) os << "  ";

    return os;
  }
};

// ******************************************************************************
struct spaces {
  size_t _n;

  spaces(size_t n) : _n(n) {}

  friend std::ostream& operator<<(std::ostream& os, const spaces& _i) {
    for (size_t i = 0; i < _i._n; ++i) os.put(' ');

    return os;
  }
};

// ******************************************************************************
inline void AssureIndents(std::string& text, int n) {
  std::string::size_type pos = 0;
  while (pos < text.size()) {
    pos = text.find('\n', pos);
    if (pos == std::string::npos) break;

    pos += 1;
    text.insert(pos, n, '\t');
    pos += n;
  }
}
