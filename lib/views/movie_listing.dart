import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class MovieListing extends StatefulWidget {
  final Movie movie;

  const MovieListing({super.key, required this.movie});

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  // static const blue = Color(0xFF54BFDA) // can't do const on its own as inside a class dart doesnt treat them as constants but as ordinary instance fields that are changeable
  // static const grey = Color(0xFFF0F0F0) // moved to constants file

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        // scrolls if the bigger layout doesn't fit on screen
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // lists widgets inside of a column
            Text(
              '${widget.movie.name.toUpperCase()} (${widget.movie.ageRating})',
              style: const TextStyle(
                color: cinemaFontWhite,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: cinemaFontWhite, width: 2),
              ),
              child: Image.asset(
                widget.movie.imagePath,
                width: 200, // double the size shown on the card
                height: 300,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              widget.movie.synopsis,
              style: const TextStyle(
                color: cinemaFontWhite,
                fontSize: 20,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Southsea Cinema Room',
              style: TextStyle(color: cinemaFontWhite, fontSize: 20),
            ),

            const SizedBox(height: 8),

            Text(
              widget.movie.screeningDateTime,
              style: const TextStyle(color: cinemaFontWhite, fontSize: 20),
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
              // x axis rather than y
              children: [
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
                SizedBox(width: 16),
                Text(
                  'Adult (${widget.movie.formattedPrice})',
                  style: TextStyle(
                    color: cinemaFontWhite,
                    fontSize: 20,
                  ),
                ),
                SizedBox(width: 24),
                SizedBox(
                  width: 150,
                  height: 36,
                  child: PrimaryButton(
                    label: 'ADD TO ORDER',
                    onPressed: _addToOrder,
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
