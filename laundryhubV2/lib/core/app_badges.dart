import 'package:flutter/material.dart';

class AppBadges {

  static final ValueNotifier<int>
      pendingPickupCount =
      ValueNotifier<int>(0);

  static final ValueNotifier<int>
    pendingPaymentCount =
    ValueNotifier<int>(0);

}