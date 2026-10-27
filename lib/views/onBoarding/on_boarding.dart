import 'package:flutter/material.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});
  @override
  State<StatefulWidget> createState() => OnBoardingState();
}

class OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("logo-galana.webp", fit: BoxFit.cover),
              // textContainer
              Column(
                children: [
                  Text(
                    "Réalisez vos inspections en toute confiance",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  Text(
                    "Planifiez, exécutez et suivez vos inspections HSSE depuis une seule plateforme.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Commencer",
                     
                      
                    ),
                  ),
                  TextButton(onPressed: () {}, child: Text("Passer")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
