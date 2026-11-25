import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  int _quantity = 0; // tickets picked in the dropdown

  void _addToOrder() {
    if (_quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select how many tickets you want first')),
      );
      return;
    }
    BasketRepository.instance.addTickets(widget.movie, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added $_quantity tickets for ${widget.movie.name} to your basket',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Movie movie = widget.movie;
    final ColorScheme colours = Theme.of(context).colorScheme;
    return Card(
      color: colours.surface,
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
              style: TextStyle(
                color: colours.onSurface,
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
            Text(
              'Southsea Cinema Room',
              style: TextStyle(color: colours.onSurface, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              movie.screeningDateTime,
              style: TextStyle(color: colours.onSurface, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              movie.synopsis,
              style: TextStyle(
                color: colours.onSurface,
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
                  'Tickets (${movie.formattedPrice} each)',
                  style: TextStyle(color: colours.onSurface, fontSize: 16),
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
                    onChanged: (value) {
                      setState(() {
                        _quantity = value ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 36,
                  child: PrimaryButton(
                    label: 'Add to order',
                    onPressed: _addToOrder,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  height: 36,
                  child: PrimaryButton(
                    label: 'Details',
                    onPressed: () {
                      // opens a page showing only this movie, bigger
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieListing(movie: movie),
                        ),
                      );
                    },
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
