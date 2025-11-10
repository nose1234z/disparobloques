import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forge2d_game/models/power_up.dart'; // Import PowerUp model

import 'package:forge2d_game/screens/shop_screen.dart'; // Import ShopScreen

class PlayAgainScreen extends StatefulWidget {
  const PlayAgainScreen({super.key});

  @override
  State<PlayAgainScreen> createState() => _PlayAgainScreenState();
}

class _PlayAgainScreenState extends State<PlayAgainScreen> {
  PowerUp? _activePowerUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/colored_grass.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            color: Colors.white.withAlpha((255 * 0.8).round()),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Play Again',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    iconSize: 64,
                    onPressed: () {
                      // Pass the active power-up to the game
                      context.go('/', extra: _activePowerUp);
                    },
                  ),
                  if (_activePowerUp != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Active Power-Up: ${_activePowerUp!.name}',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Shop',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    iconSize: 64,
                    onPressed: () async {
                      final purchasedPowerUp = await showDialog<PowerUp>(
                        context: context,
                        builder: (context) => const ShopScreen(),
                      );
                      if (purchasedPowerUp != null && mounted) {
                        setState(() {
                          _activePowerUp = purchasedPowerUp;
                        });
                        // scaffoldMessenger.showSnackBar(
                        //   SnackBar(
                        //     content: Text(
                        //       'Power-Up "${purchasedPowerUp.name}" is now active for your next game!',
                        //     ),
                        //     backgroundColor: Colors.blue,
                        //   ),
                        // );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
