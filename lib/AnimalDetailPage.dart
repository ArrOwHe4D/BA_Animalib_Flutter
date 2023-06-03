import 'package:flanimalib/Widgets/CustomCardView.dart';
import 'package:flutter/material.dart';

import 'DataModels/animal.dart';

class AnimalDetailPage extends StatefulWidget 
{
  const AnimalDetailPage({Key? key, required this.animal}) : super(key: key);

  final Animal animal;

  @override State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage> 
{
  Animal? _animalToDisplay;

  @override
  void initState() 
  {    
    super.initState();
    _animalToDisplay = widget.animal;
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      backgroundColor: Colors.black,
      appBar: AppBar
      (
        title: Text(_animalToDisplay!.name), 
        backgroundColor: const Color(0xFF303030), 
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white), 
        leading: IconButton(color: Colors.white, icon: const Icon(Icons.arrow_back), 
        onPressed: () => Navigator.pop(context))
      ),
      body: Column
      (
        children: 
        [
          const SizedBox(height: 10),
          Container
          (
            width: 400, 
            height: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF10D180))),
            child: ClipRRect
            (
              borderRadius: BorderRadius.circular(10),                                                        
              child: _animalToDisplay!.image            
            ) 
          ),
          const SizedBox(height: 5),
          CustomCardView
          (            
            child: Container 
            (
              height: MediaQuery.of(context).size.height * 0.485,
              child: SingleChildScrollView
              ( 
                child: Column
                (      
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  [
                    const Text('Daten', style: TextStyle(fontSize: 35.0, color: Color(0xFF10D180))),
                    const SizedBox(height: 10),
                    Row(children: [ const Text('Bezeichnung: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text(_animalToDisplay!.name, style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                    const SizedBox(height: 10),
                    Row(children: [ const Text('Größe: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text(_animalToDisplay!.height, style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                    const SizedBox(height: 10),
                    Row(children: [ const Text('Gewicht: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text(_animalToDisplay!.weight, style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                    const SizedBox(height: 10),
                    Row(children: [ const Text('Spezies: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text(_animalToDisplay!.species, style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                    const SizedBox(height: 10),
                    Row(children: [ const Text('Regionen: ', style: TextStyle(fontSize: 14, color: Colors.white)), Text(_animalToDisplay!.regions, style: const TextStyle(fontSize: 14, color: Colors.white)) ]),
                    const SizedBox(height: 20),
                    const Text('Beschreibung', style: TextStyle(fontSize: 20.0, color: Color(0xFF10D180))),
                    const SizedBox(height: 10),
                    Text(_animalToDisplay!.description, style: const TextStyle(color: Colors.white)),
                  ]
                )
              )
            )
          )
        ]
      )  
    );
  }
}