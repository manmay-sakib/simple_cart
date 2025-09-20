// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
//
// class ProductCardShimmer extends StatelessWidget {
//   final bool isGrid;
//
//   const ProductCardShimmer({super.key, this.isGrid = true});
//
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: const EdgeInsets.all(8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top image shimmer: flexible height
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.grey.shade100,
//                 ),
//               ),
//             ),
//
//             if (isGrid) ...[
//               const SizedBox(height: 8),
//               // Title shimmer
//               Container(
//                 height: 16,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4),
//                   color: Colors.grey.shade100,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               // Subtitle shimmer
//               Container(
//                 height: 14,
//                 width: 60,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4),
//                   color: Colors.grey.shade100,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
