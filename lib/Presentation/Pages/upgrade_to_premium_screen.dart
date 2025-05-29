import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/Constants/images.dart';



class UpgradeToPremiumScreen extends StatefulWidget {
  const UpgradeToPremiumScreen({super.key});

  @override
  State<UpgradeToPremiumScreen> createState() => _UpgradeToPremiumScreenState();
}

class _UpgradeToPremiumScreenState extends State<UpgradeToPremiumScreen> {
  final List<String> _premiumHighlights = [
    'Add Unlimited Sponsors',
    'Add Unlimited Racer',
    'Settle Unlimited Deals',
    'Can host Unlimited Events',
  ];

  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      backgroundColor: const Color(0xFF1A2138),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 24,
            ).copyWith(top: 64, bottom: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D5586), Color(0xFF171E45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF13386B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: Icon(Icons.home, color: Colors.white, size: 16),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Upgrade to Premium",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // Space before bottom border
              ],
            ),
          ),

          

          Expanded( 
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    Images.homeScreen,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                
                // 2. Custom App Bar

                // 3. Premium Features Card
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18, // <--- ADDED THIS LINE
                  child: Container(
                   
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.4),width: 1),
                      gradient: LinearGradient(colors: [Color(0xFF8B6AD2),Color(0xFF211E83)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      ),
                  
                      borderRadius: BorderRadius.circular(16),),
                    
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Get Premium',
                            style: TextStyle(
                              color: Color(0xFFFFCC29),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          Text(
                            "Highlights:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _premiumHighlights
                                .map(
                                  (highlight) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star_sharp,
                                          color: Color(0xFF10B981),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            highlight,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                          // "One Time Purchase" Button within the card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.3),width: 2),
                              borderRadius: BorderRadius.circular(60),
                              gradient: LinearGradient(
                                colors: [
                                Color(0xFFA8E266),
                                Color(0xFF24C166)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                // Handle one time purchase
                              },
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      'One Time Purchase',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 16.0),
                                    child: Text(
                                      '\$0.99',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 4. Bottom Bar
      bottomNavigationBar: Container(
        height: 90,
        color: Color(0xFF13386B),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '\$0.99',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Get Premium button action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xFFFFCC29), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    60,
                  ), 
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Get Premium',
                style: TextStyle(
                  color: Colors.black, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}