import 'package:flanimalib/Widgets/customcardview.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget 
{
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      backgroundColor: Colors.black,
      body: Center
      (
        child: Column
        (          
          children:
          [
            const SizedBox(height: 40),
            CustomCardView
            (                  
              child: Row
              (
                children: 
                [ 
                  Image.asset('images/icon_bear.png', width: 100, height: 100),
                  const SizedBox(width: 10), 
                  const Flexible(child: Text('Welcome to Animalib!', style: TextStyle(fontSize: 32.0, color: Colors.white)))                      
                ]               
              )
            ),
            const SizedBox(height: 5),
            CustomCardView
            (                   
              child: Container
              (
                height: MediaQuery.of(context).size.height * 0.66,
                child: SingleChildScrollView
                (
                  child: Column
                  (
                    children: 
                    [
                      Row
                      (
                        children: 
                        [
                          Image.asset('images/icon_news.png', width: 50, height: 50),
                          const SizedBox(width: 10), 
                          const Text('News', style: TextStyle(fontSize: 50, color: Colors.white))
                        ]
                      ),
                      const SizedBox(height: 15),
                      const Column
                      (
                        children: [
                          Text('24.01.2023: Another £2 million funding by the UK government!', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('The UK government announces another £2 million in funding to protect pangolins, sharks &amp; other endangered species.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('20.01.2023: 40 Starving Sheep have been Saved from a Backyard!', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('40 Starving Sheep Have Been Saved From A Backyard Slaughter Operation In New York’s Hudson Valley.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('19.01.2023: New York bans sale of cosmetics tested on animals!', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('Victory! New York becomes the 10th state in the U.S. to Ban the sale of cosmetics tested on animals.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('18.01.2023: 2 Pandas saved moving to Sanctuary in China', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('Victory! Suffering pandas Yaya &amp; Lele at the memphis zoo will finally be sent to a sanctuary in china.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('17.01.2023: Biden signs the shark fin sales elimination act', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('Victory! President Biden signs the shark fin sales elimination act helping to protect sharks in the U.S.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('17.01.2023: Three chimpanzees shot!', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('Breaking! Three chimpanzees are shot &amp; killed after escaping from their enclosure at a swedish zoo.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('15.01.2023: Stricter animal welfare laws in Queensland Australia', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('Queensland, Australia, passes stricter animal welfare laws for the first time in more than two decades.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('13.01.2023: New Research on climate impact of factory farming in Canada', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('First-of-its-Kind research reveals the staggering impact factory farming in Canada has on our climate.', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 15),
                          Text('12.01.2023: £4 million funding by the UK government!', style: TextStyle(fontSize: 18, color: Color(0xFF10D180))),
                          Text('The UK government announces £4 million in funding to protect pangolins, sharks &amp; other endangered species.', style: TextStyle(fontSize: 18, color: Colors.white))
                        ]
                      )
                    ] 
                  ) 
                ) 
              )                                                                                                      
            )   
          ]            
        )  
      ),
    );
  }
}