// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Example user data model for demonstrating body parameters.
///
/// Used to pass user information during navigation without
/// including it in the URL.
class UserData {
  /// Creates user data.
  const UserData({required this.id, required this.displayName});

  /// Unique user identifier.
  final String id;

  /// User display name.
  final String displayName;

  @override
  String toString() => 'UserData($id: $displayName)';
}
