#include <SFML/Window.hpp>
#include <iostream>

int main() {
	sf::Window window(sf::VideoMode(800, 600), "Template");

	while (window.isOpen())
	{
		sf::Event event;
		while (window.pollEvent(event))
		{
			if (event.type == sf::Event::Closed)
				window.close();
		}
	}

	return 0;
}