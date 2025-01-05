#include <iostream>
#include <filesystem>
#include <stdio.h>
#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>
#include <SFML/Graphics/RenderWindow.hpp>
#include <SFML/System/Clock.hpp>
#include <SFML/Window/Event.hpp>


const int WIDTH = 800, HEIGHT = 600;
int main()
{

sf::RenderWindow window(sf::VideoMode({WIDTH, HEIGHT}), "The Planets");
window.setFramerateLimit(60);

// SHADERER
if (!sf::Shader::isAvailable())
{
	std::cout<<"Shaders are not available on this computer"<<std::endl;
}
sf::Shader shader;
if (!shader.loadFromFile("shaders/fs.glsl", sf::Shader::Fragment)){
	std::cout << "Current working directory: " << std::filesystem::current_path() << std::endl;
	exit(-1);
}


auto mouse_position = sf::Vector2f{};
sf::Clock deltaClock;
sf::Clock clock;

while (window.isOpen())
{
	sf::Event event;
	while (window.pollEvent(event))
	{
		if (event.type == sf::Event::Closed) {
			window.close();
		}
	}

	window.clear(sf::Color::Black);

	shader.setUniform("u_resolution", sf::Glsl::Vec2{ window.getSize() });
	shader.setUniform("u_mouse", sf::Glsl::Vec2{ mouse_position });
	shader.setUniform("u_time", clock.getElapsedTime().asSeconds());
	shader.setUniform("u_propratio", static_cast<float>(HEIGHT) / WIDTH);

	window.draw(sf::RectangleShape(sf::Vector2f(WIDTH, HEIGHT)), &shader);
	window.display();

}

return 0;

}