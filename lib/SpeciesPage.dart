import 'package:flanimalib/DataModels/Species.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpeciesPage extends StatefulWidget 
{
  const SpeciesPage({Key? key}) : super(key: key);

  @override
  State<SpeciesPage> createState() => _SpeciesPageState();
}

class _SpeciesPageState extends State<SpeciesPage>                                                                                                                
{ 
  List<Species> speciesList = <Species>[];

  @override
  void initState() 
  {    
    super.initState();
    getSpeciesDataAsync();    
  }

  Future<void> getSpeciesDataAsync() async 
  {
    final url = Uri.parse('http://192.168.178.51:57565/api/Species');
    final response = await http.get(url);

    if (response.statusCode == 200)
    {      
      final List<dynamic> objectList = json.decode(response.body);

      setState(() {
        speciesList = objectList.map((item) {        
          return Species(            
            item['name'],
            item['type'],
            item['animalCount'],
            Image.memory(base64Decode(item['image']), fit: BoxFit.cover)
          );
        }).toList();        
      });
    }
    else 
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
            Image.asset('images/icon_title_species.png', width: 40, height: 40),
            const SizedBox(width: 5),
            const Text('Species', style: TextStyle(fontSize: 40.0, color: Colors.white))
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tileColor: const Color(0xFF303030),                                                                                           
                    leading: Container
                    (
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.green, width: 2.0), borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: speciesList[index].image)
                    ),
                    title: Column
                    (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: 
                      [
                        const SizedBox(height: 10),
                        Text(speciesList[index].name, style: const TextStyle(color: Color(0xFF10D180), fontSize: 20)),
                        Text("Typ: ${speciesList[index].speciesType}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                        Text("Anzahl: ${speciesList[index].animalCount}", style: const TextStyle(color: Colors.white, fontSize: 13))
                      ]
                    )
                  ) 
                ),
                const SizedBox(height: 10)
              ]
            );
          }, itemCount: speciesList.length),
        )
      ]                                                                                                                                                                                                                                                                    
    );
  }
}