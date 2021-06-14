#include "handler.h"
#include <iostream>

void Handler::print() {
  std::cout << "name: " << name_ << std::endl;
}

const std::string& Handler::name() {
  return name_;
}

void Handler::set_name(const std::string& name) {
  name_ = name;
}
