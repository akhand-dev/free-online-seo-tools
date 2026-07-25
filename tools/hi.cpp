#include <iostream>
#include <string>

int main() {
    // Declare a variable to hold the user's name
    std::string name;

    // Prompt the user for input
    std::cout << "Enter your name: ";
    
    // Read the full line of text entered by the user
    std::getline(std::cin, name);

    // Print the greeting
    std::cout << "Hello, " << name << "! Welcome to C++ programming." << std::endl;

    return 0;
}
