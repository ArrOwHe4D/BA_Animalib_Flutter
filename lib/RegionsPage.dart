import 'package:flanimalib/DataModels/Region.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegionsPage extends StatefulWidget 
{
  const RegionsPage({Key? key}) : super(key: key);

  @override
  State<RegionsPage> createState() => _RegionsPageState();
}

class _RegionsPageState extends State<RegionsPage>                                                                                                                
{ 
  List<Region> regionList = <Region>[];

  @override
  void initState() 
  {    
    super.initState();
    getRegionDataAsync();    
  }

  Future<void> getRegionDataAsync() async 
  {
    final url = Uri.parse('http://192.168.178.51:57565/api/Regions');
    final response = await http.get(url);

    if (response.statusCode == 200)
    {      
      final List<dynamic> objectList = json.decode(response.body);

      setState(() {
        regionList = objectList.map((item) {        
          return Region(            
            item['name'],
            item['size'],
            item['speciesCount'],
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
            Image.asset('images/icon_title_regions.png', width: 40, height: 40),
            const SizedBox(width: 5),
            const Text('Regions', style: TextStyle(fontSize: 40.0, color: Colors.white))
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
                      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: regionList[index].image)
                    ),
                    title: Column
                    (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: 
                      [
                        const SizedBox(height: 10),
                        Text(regionList[index].name, style: const TextStyle(color: Color(0xFF10D180), fontSize: 20)),
                        Text("Fläche: ${regionList[index].size} km²", style: const TextStyle(color: Colors.white, fontSize: 13)),
                        Text("Spezies: ${regionList[index].speciesCount}", style: const TextStyle(color: Colors.white, fontSize: 13))
                      ]
                    )
                  ) 
                ),
                const SizedBox(height: 10)
              ]
            );
          }, itemCount: regionList.length),
        )
      ]                                                                                                                                                                                                                                                                    
    );
  }
}