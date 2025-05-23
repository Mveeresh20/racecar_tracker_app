
import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';
import 'package:racecar_tracker/models/sponser_ship_deal.dart'; // Make sure this import path is correct

class ActiveSponsorshipDealsContent extends StatelessWidget {
  final SponsorshipDeal deal; // Now accepts a single SponsorshipDeal object

  const ActiveSponsorshipDealsContent({Key? key, required this.deal }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column( 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(deal.title, style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 14,fontFamily: "Montserrat")),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: deal.statusColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                deal.statusText,
                style: context.labelMedium?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        Text("Summer race", style: context.bodyMedium?.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
         Container(
                height: 1,
              decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1),width: 1),
              )

              ),
            ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Deal Value", style: context.bodyMedium?.copyWith(color: Colors.white)),
                Text(deal.dealValue,textAlign: TextAlign.center, style: TextStyle(fontSize: 14,fontWeight: FontWeight.w700,fontFamily: "Montserrat",color: Colors.white,)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("Commission", style: context.bodyMedium?.copyWith(color: Colors.white))),
                Text(deal.commission, style: TextStyle(fontSize: 14,fontWeight: FontWeight.w700,fontFamily: "Montserrat",color: Colors.white,)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Renewal", style: context.bodyMedium?.copyWith(color: Colors.white)),
                Text(deal.renewalDate, style: TextStyle(fontSize: 14,fontWeight: FontWeight.w700,fontFamily: "Montserrat",color: Colors.white,)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:racecar_tracker/models/sponser_ship_deal.dart';


// class ActiveSponsorshipDealsContent extends StatelessWidget {
//   final List<SponsorshipDeal> deals;

//   const ActiveSponsorshipDealsContent({Key? key, required this.deals}) : super(key: key);

//   Widget _buildSponsorshipDealItem(SponsorshipDeal deal, BuildContext context) {
//     return Card(
//       color: const Color(0xFF3B487A), // Slightly different shade for inner card
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(deal.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)), // Use theme text style
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: deal.statusColor, // Dynamic color based on status
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Text(
//                     deal.statusText,
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black, fontWeight: FontWeight.bold), // Use theme text style and override color
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Deal Value", style: Theme.of(context).textTheme.bodySmall), // Use theme text style
//                     Text(deal.dealValue, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Commission", style: Theme.of(context).textTheme.bodySmall), // Use theme text style
//                     Text(deal.commission, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Renewal", style: Theme.of(context).textTheme.bodySmall), // Use theme text style
//                     Text(deal.renewalDate, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (deals.isEmpty) {
//       return Center(
//         child: Text("No active sponsorship deals.", style: Theme.of(context).textTheme.bodyMedium),
//       );
//     }
//     return Column(
//       children: deals.map((deal) => _buildSponsorshipDealItem(deal, context)).toList(),
//     );
//   }
// }