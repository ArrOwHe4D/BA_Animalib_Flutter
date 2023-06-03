import 'package:flanimalib/AnimalDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'DataModels/animal.dart';

class AnimalsPage extends StatefulWidget 
{
  const AnimalsPage({Key? key}) : super(key: key);

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage>                                                                                                                
{ 
  List<Animal> animalList = <Animal>[];

  @override
  void initState() 
  {    
    super.initState();
    getAnimalDataAsync();    
  }

  Future<void> getAnimalDataAsync() async 
  {
    try
    {
      final url = Uri.parse('http://192.168.178.51:57565/api/Animals');
      final response = await http.get(url);    

      if (response.statusCode == 200)
      {              
        final List<dynamic> objectList = json.decode(response.body);

        setState(() {
          animalList = objectList.map((item) {        
            return Animal(
              item['id'],
              item['name'],
              item['height'],
              item['weight'],
              item['regions'],
              item['species'],
              item['description'],
              Image.memory(base64Decode(item['image']), fit: BoxFit.cover)
            );
          }).toList();        
        });
      }
    }
    catch (error)
    {
      Fluttertoast.showToast(msg: "Could not retrieve Data from REST-Service!", toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Column
    (
      children:
      [
        const SizedBox(height: 35),
        Row
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            Image.asset('images/icon_title_animals.png', width: 40, height: 40),
            const SizedBox(width: 5),
            const Text('Animals', style: TextStyle(fontSize: 40.0, color: Colors.white))
          ]
        ),
        Expanded
        (
          child: ListView.builder(itemBuilder: (context, int index) 
          {                         
            return Column
            (                        
              children: 
              [
                Container
                (                                          
                  height: 110,
                  width: 390,                                
                  decoration: BoxDecoration
                  (
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all
                    (
                      color: Colors.transparent,
                      width: 1.0,
                    )
                  ), 
                  child: ListTile
                  (    
                    onTap: () => { Navigator.push(context, MaterialPageRoute(builder: (context) => AnimalDetailPage(animal: animalList[index]))) },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tileColor: const Color(0xFF303030),                                                                                           
                    leading: Container
                    (
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.green, width: 2.0), borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: animalList[index].image)
                    ),                  
                    title: Column
                    (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: 
                      [
                        const SizedBox(height: 10),
                        Text(animalList[index].name, style: const TextStyle(color: Color(0xFF10D180), fontSize: 20)),
                        Text("Regionen: ${animalList[index].regions}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                        Text("Spezies: ${animalList[index].species}", style: const TextStyle(color: Colors.white, fontSize: 13))
                      ]
                    )              
                  ) 
                ),
                const SizedBox(height: 10)
              ]
            );
          }, itemCount: animalList.length),
        )
      ]                                                                                                                                                                                                                                                                    
    );
  }
}