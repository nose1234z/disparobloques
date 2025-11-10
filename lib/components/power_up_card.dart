import 'package:flutter/material.dart';
import 'package:forge2d_game/models/power_up.dart';

class PowerUpCard extends StatelessWidget {
  final PowerUp powerUp;
  final VoidCallback onBuy;

  const PowerUpCard({super.key, required this.powerUp, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(powerUp.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
            Text(powerUp.description),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${powerUp.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(onPressed: onBuy, child: const Text('Buy')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
