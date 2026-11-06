import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/model.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cinemaSurface,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${movie.name.toUpperCase()} (${movie.ageRating})',
              style: const TextStyle(
                color: cinemaFontWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: cinemaFontWhite, width: 2),
              ),
              child: Image.asset(
                movie.imagePath,
                width: 100,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Southsea Cinema Room',
              style: TextStyle(color: cinemaFontWhite, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              movie.screeningTime,
              style: const TextStyle(color: cinemaFontWhite, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              movie.synopsis,
              style: const TextStyle(
                color: cinemaFontWhite,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              // x axis rather than y
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tickets (£${movie.price} each)',
                  style: const TextStyle(color: cinemaFontWhite, fontSize: 16),
                ),
                SizedBox(
                  width: 90,
                  child: DropdownButtonFormField<int>(
                    // create the widget
                    initialValue: 0, // 0, blank value
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    dropdownColor: const Color(0xFFF0F0F0),
                    decoration: const InputDecoration(
                      isDense: true, // compact
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.zero, // square corners > rounded
                      ),
                    ),
                    items: List.generate(
                      // creates 6 values in the dropdown 1 itteration is one option
                      6,
                      (ticketAmount) => DropdownMenuItem<int>(
                        value: ticketAmount,
                        child: Text(
                            '$ticketAmount'), // int to text (string interpolation) ticketAmount.toString()
                      ),
                    ),
                    onChanged: (value) {}, // null until selected
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                  elevation: 0, // no shadow
                  padding: EdgeInsets.zero, // removes padding
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // zero = square corners
                  ),
                ),
                child: const Text(
                  'Add to order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
