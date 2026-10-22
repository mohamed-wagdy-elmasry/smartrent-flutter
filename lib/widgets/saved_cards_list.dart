import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class SavedCardsList extends StatefulWidget {
  final Function(SavedCard) onCardSelected;
  
  const SavedCardsList({Key? key, required this.onCardSelected}) : super(key: key);
  
  @override
  State<SavedCardsList> createState() => _SavedCardsListState();
}

class _SavedCardsListState extends State<SavedCardsList> {
  List<SavedCard> _cards = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCards();
  }
  
  Future<void> _loadCards() async {
    try {
      final service = PaymentService();
      _cards = await service.getSavedCards();
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_cards.isEmpty) {
      return const Center(
        child: Text('No saved cards'),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return ListTile(
          leading: _getCardIcon(card.cardBrand),
          title: Text(card.displayName),
          subtitle: Text('Expires ${card.expiry}'),
          trailing: card.isDefault
              ? const Chip(label: Text('Default'))
              : null,
          onTap: () => widget.onCardSelected(card),
        );
      },
    );
  }
  
  Widget _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Icon(Icons.credit_card, color: Colors.blue);
      case 'mastercard':
        return const Icon(Icons.credit_card, color: Colors.orange);
      case 'mada':
        return const Icon(Icons.credit_card, color: Colors.green);
      default:
        return const Icon(Icons.credit_card);
    }
  }
}
