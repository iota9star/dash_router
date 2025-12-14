// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash_router_example/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const DashRouterExampleApp());
    await tester.pumpAndSettle();

    // Verify the app loads - check for MaterialApp scaffold
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
