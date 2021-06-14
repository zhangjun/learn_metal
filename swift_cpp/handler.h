#pragma once

#include <string>

class Handler {
public:
  Handler(const std::string& name): name_(name) {}
  
  void print();
  void set_name(const std::string& name);
  const std::string& name();

private:
  std::string name_;
};
