import 'package:flutter/material.dart';
import 'package:forge2d_game/components/payment_dialog.dart';
import 'package:forge2d_game/components/power_up_card.dart';
import 'package:forge2d_game/models/power_up.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // Mock data for power-ups
  final List<PowerUp> _powerUps = [
    PowerUp(
      name: 'Extra Life',
      description: 'Grants one additional life for the current game.',
      price: 10.00,
    ),
    PowerUp(
      name: 'Extra Shots',
      description: 'Grants 5 additional shots for the current game.',
      price: 5.00,
    ),
  ];

  void _buyPowerUp(PowerUp powerUp) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => const PaymentDialog(),
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully purchased ${powerUp.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(powerUp); // Use generic pop
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 400,
          height: 500,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Power-Up Shop',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(); // Pop the ShopScreen
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _powerUps.length,
                  itemBuilder: (context, index) {
                    final powerUp = _powerUps[index];
                    return PowerUpCard(
                      powerUp: powerUp,
                      onBuy: () => _buyPowerUp(powerUp),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
