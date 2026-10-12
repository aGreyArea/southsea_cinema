import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatelessWidget {
  const MovieListing({super.key});
  // static const blue = Color(0xFF54BFDA) // can't do const on its own as inside a class dart doesnt treat them as constants but as ordinary instance fields that are changeable
  // static const grey = Color(0xFFF0F0F0) // moved to constants file

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle, style: cinemaHeaderStyle),
        backgroundColor: cinemaSurface,
        iconTheme: const IconThemeData(color: cinemaBrand),
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ // lists widgets inside of a column
            Text(
              'Obsession (2025) (18)',
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 32,
                fontWeight: FontWeight.normal,
              ),
            ),

            SizedBox(height: 40),

            Text(
              '''After breaking the mysterious "One Wish Willow" to win his crush's heart, a hopeless romantic finds himself getting exactly what he asked for but soon discovers that some desires come at a dark, sinister price.''',
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 40),

            Text(
              "Thursday 22 Oct 2026, 18:00 - ends at 19:14 (1h, 14m)",
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),

            SizedBox(height: 28),

            Text(
              'Tickets',
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Select Quantaties (up to 5 total)',
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),

            SizedBox(height: 18),

            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: DropdownButtonFormField<int>(
                    initialValue: 0,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    dropdownColor: const Color(0xFFF0F0F0),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    items: List.generate(
                      6,
                      (index) => DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index'),
                      ),
                    ),
                    onChanged: (value) {},
                  ),
                ),

                SizedBox(width: 16),

                Text(
                  'Adult (£7.50)',
                  style: TextStyle(
                    color: cinemaFontWhite,
                    fontSize: 20,
                  ),
                ),

                SizedBox(width: 24),

                SizedBox(
                  width: 150,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Add to Order Pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cinemaBrand,
                      foregroundColor: cinemaFontWhite,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'ADD TO ORDER',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }
}
