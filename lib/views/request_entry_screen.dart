import 'package:flutter/material.dart';
import 'loading_screen.dart';

class RequestEntryScreen extends StatefulWidget {
  const RequestEntryScreen({
    super.key,
    required this.guestAtEntry,
    required this.guest,
    required this.member,
  });
  final bool? guestAtEntry;
  final Widget guest;
  final Widget member;
  @override
  State<RequestEntryScreen> createState() => _RequestEntryScreenState();
}

class _RequestEntryScreenState extends State<RequestEntryScreen> {
  bool? _guestAtEntry;
  @override
  Widget build(BuildContext context) {
    _guestAtEntry ??= widget.guestAtEntry;
    return switch (_guestAtEntry) {
      null => const LoadingScreen(),
      true => widget.guest,
      false => widget.member,
    };
  }
}
