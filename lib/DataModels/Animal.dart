import 'package:flutter/widgets.dart';

class Animal
{
  int id;
  String name;
  String height;      
  String weight;
  String species;
  String regions;
  String description;    
  Image image;

  Animal(this.id, this.name, this.height, this.weight, this.regions, this.species, this.description, this.image);
}